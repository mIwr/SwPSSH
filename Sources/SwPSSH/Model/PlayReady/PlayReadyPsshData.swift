//
//  PlayReadyPsshData.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

import Foundation

///The PlayReady Object (PRO) from PSSH box
///
///Object schema: https://learn.microsoft.com/en-us/playready/specifications/playready-header-specification
public class PlayReadyPsshData {
    
    public static let minSize: UInt8 = 6
    
    ///PlayReady record objects
    public let records: [PlayReadyRecord]
    
    public init(records: [PlayReadyRecord]) {
        self.records = records
    }
    
    ///Serializes PlayReady PSSH data as raw bytes data
    ///- Returns: Raw bytes data
    public func serialize() -> Data {
        var res = PSSHBinaryUtil.getBytes(UInt16(records.count), bigEndian: false)
        for record in records {
            let bytes = record.serialize()
            res.append(contentsOf: bytes)
        }
        res.insert(contentsOf: PSSHBinaryUtil.getBytes(UInt32(res.count + 4), bigEndian: false), at: 0)
        return Data(res)
    }
    
    ///Tries to parse PlayReady PSSH data  from raw bytes data
    ///- Parameter psshPayload: Raw bytes data
    ///- Returns: PlayReady PSSH data parse result. Optional
    public static func from(psshPayload: Data) -> PlayReadyPsshData? {
        if (psshPayload.count < PlayReadyRecord.minSize) {
            #if DEBUG
            print("Invalid pssh data: minimum size is " + String(PlayReadyPsshData.minSize) + ", but was " + String(psshPayload.count))
            #endif
            return nil
        }
        let payloadBytes = [UInt8].init(psshPayload)
        var offset = 0
        let size: UInt32 = PSSHBinaryUtil.getVal(payloadBytes, offset: offset, bigEndian: false) ?? 0
        offset += 4
        if (size != psshPayload.count) {
            print("Warning: PSSH data size mismatch. Expected " + String(psshPayload.count) + ", but was " + String(size))
        }
        let recordsCount: UInt16 = PSSHBinaryUtil.getVal(payloadBytes, offset: offset, bigEndian: false) ?? 0
        offset += 2
        var records: [PlayReadyRecord] = []
        for _ in 0...recordsCount - 1 {
            guard let safeParsed = PlayReadyRecord.from(recordData: payloadBytes, offset: &offset) else {
                continue
            }
            records.append(safeParsed)
        }
        if (records.count != recordsCount) {
            print("Warning: expected " + String(recordsCount) + " records,  but were parsed " + String(records.count) + ". Possible new format")
        }
        if (offset < payloadBytes.count) {
            print("Warning: remains not used data (Processed " + String(offset) + "/" + String(payloadBytes.count) + "). Possible new format")
        }
        return PlayReadyPsshData(records: records)
    }
}
