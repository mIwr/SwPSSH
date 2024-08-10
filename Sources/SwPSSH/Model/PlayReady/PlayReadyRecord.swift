//
//  PlayReadyRecord.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

import Foundation

///The PlayReady PSSH record object
public class PlayReadyRecord {
    
    public static let minSize: UInt8 = 4
    
    ///PlayReady record type key
    public let recordType: UInt16
    ///Parsed PlayReady record type
    public var parsedRecordType: PlayReadyRecordType? {
        get {
            return PlayReadyRecordType(rawValue: recordType)
        }
    }
    ///Record value raw data
    public let recordValue: Data
    
    ///Parsed from record value header
    public var recordHeader: PlayReadyRecordHeader? {
        get {
            if (parsedRecordType != .playReadyHeader) {
                return nil
            }
            return PlayReadyRecordHeader.fromSync(record: self)
        }
    }
    
    public init(recordType: UInt16, recordValue: Data) {
        self.recordType = recordType
        self.recordValue = recordValue
    }
    
    ///Serializes PlayReady PSSH record object as raw bytes
    ///- Returns: Raw bytes
    public func serialize() -> [UInt8] {
        var res = PSSHBinaryUtil.getBytes(recordType, bigEndian: false)
        res.append(contentsOf: PSSHBinaryUtil.getBytes(UInt16(recordValue.count), bigEndian: false))
        res.append(contentsOf: recordValue)
        return res
    }
    
    ///Tries to parse PlayReady PSSH record object  from raw bytes data from defined offset
    ///- Parameter recordData: Raw bytes data
    ///- Parameter offset: Raw bytes data start offset
    ///- Returns: PlayReady PSSH record object parse result. Optional
    public static func from(recordData: [UInt8], offset: inout Int) -> PlayReadyRecord? {
        if (recordData.count - offset < PlayReadyRecord.minSize) {
            #if DEBUG
            print("Invalid record data: minimum size is " + String(PlayReadyRecord.minSize) + ", but available offset size was " + String(recordData.count - offset))
            #endif
            return nil
        }
        let type: UInt16 = PSSHBinaryUtil.getVal(recordData, offset: offset, bigEndian: false) ?? 0
        offset += 2
        let valueSize: UInt16 = PSSHBinaryUtil.getVal(recordData, offset: offset, bigEndian: false) ?? 0
        offset += 2
        if (offset + Int(valueSize) > recordData.count) {
            #if DEBUG
            print("Invalid record value size: total record size is " + String(recordData.count) + ", but value size was " + String(valueSize) + ", which is bigger than the record with offset " + String(offset))
            #endif
            return nil
        }
        let valueBytes = [UInt8].init(recordData[offset...offset + Int(valueSize) - 1])
        offset += Int(valueSize)
        return PlayReadyRecord(recordType: type, recordValue: Data(valueBytes))
    }
    
}
