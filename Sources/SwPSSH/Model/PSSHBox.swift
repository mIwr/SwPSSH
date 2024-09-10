//
//  PSSHBox.swift
//  SwPSSH
//
//  Created by developer on 12.07.2024.
//

import Foundation

/// Protection System Specific Header (PSSH) box container
public class PSSHBox {
    
    ///PSSH system ID bytes
    public let sysID: [UInt8]
    ///PSSH version
    public let version: UInt8
    ///PSSH flags (3 bytes)
    public let flags: [UInt8]
    ///PSSH key IDs. Available on PSSH Version 1
    public let keyIDs: [[UInt8]]?
    ///PSSH system raw init data
    public let initData: Data?
    
    public init(sysID: [UInt8], version: UInt8, flags: [UInt8], keyIDs: [[UInt8]]?, initData: Data?) {
        self.sysID = sysID
        self.version = version
        self.flags = flags
        if (version == 0 && keyIDs?.isEmpty == false) {
            print("Warning: PSSH Version 0 doesn't contain PSSH key IDs")
        }
        self.keyIDs = keyIDs
        self.initData = initData
    }
    
    ///Serializes PSSH box instance as base64-encoded string
    ///- Returns: Base64-encoded string
    public func serialize() -> String {
        var bytes: [UInt8] = []
        bytes.append(contentsOf: PSSHConstants.psshHeader)
        bytes.append(version)
        bytes.append(contentsOf: flags)
        bytes.append(contentsOf: sysID)
        if (version == 1) {
            //Serialize key IDs
            let safeKeyIDs = keyIDs ?? []
            bytes.append(contentsOf: PSSHBinaryUtil.getBytes(UInt32(safeKeyIDs.count), bigEndian: true))
            for keyID in safeKeyIDs {
                bytes.append(contentsOf: keyID)
            }
        }
        if let safePayload = initData {
            let payloadSize = UInt32(safePayload.count)
            bytes.append(contentsOf: PSSHBinaryUtil.getBytes(payloadSize, bigEndian: true))
            bytes.append(contentsOf: safePayload)
        } else {
            bytes.append(contentsOf: [UInt8].init(repeating: 0, count: 4))
        }
        bytes.insert(contentsOf: PSSHBinaryUtil.getBytes(UInt32(bytes.count + 4), bigEndian: true), at: 0)
        let data = Data(bytes)
        return data.base64EncodedString()
    }
    
    ///Tries to parse PSSH box instance from base64-encoded string
    ///- Parameter b64EncodedBox: Base64-encoded string from raw bytes data
    ///- Returns: PSSH box parse result. Optional
    public static func from(b64EncodedBox: String) -> PSSHBox? {
        guard let safeData = Data(base64Encoded: b64EncodedBox) else {
            return nil
        }
        return from(boxData: safeData)
    }
    
    ///Tries to parse PSSH box instance from raw data
    ///- Parameter boxData: Raw bytes data
    ///- Returns: PSSH box parse result. Optional
    public static func from(boxData: Data) -> PSSHBox? {
        if (boxData.count < PSSHConstants.psshHeader.count + 4) {
            print("Error: Input box bytes doesn't have PSSH header")
            return nil
        }
        
        let boxBytes = [UInt8].init(boxData)
        var offset = 0
        let boxSize: Int32 = PSSHBinaryUtil.getVal(boxBytes, offset: offset, bigEndian: true) ?? -1
        offset += 4
        if (boxSize != boxBytes.count) {
            print("Warning: Invalid box sizes info. Expected " + String(boxBytes.count) + ", but was " + String(boxSize))
        }
        if (boxBytes[offset] != PSSHConstants.psshHeader[0] || boxBytes[offset + 1] != PSSHConstants.psshHeader[1] || boxBytes[offset + 2] != PSSHConstants.psshHeader[2] || boxBytes[offset + 3] != PSSHConstants.psshHeader[3]) {
            print("Error: Input box bytes doesn't have PSSH header")
            return nil
        }
        offset += 4
        let version: UInt8 = PSSHBinaryUtil.getVal(boxBytes, offset: offset) ?? 0
        offset += 1
        var flags = [UInt8].init(repeating: 0, count: 3)
        for i in 0...2 {
            if (offset + i >= boxBytes.count) {
                break
            }
            flags[i] = boxBytes[offset + i]
        }
        offset += 3
        if (offset + 16 >= boxBytes.count) {
            print("Unexpected PSSH box EOF: No info about System ID (16 bytes)")
            return nil
        }
        let sysID = [UInt8].init(boxBytes[offset...offset + 15])
        offset += 16
        var keyIDs: [[UInt8]]?
        if (version == 1) {
            //Parse PSSH key IDs
            if (offset + 4 >= boxBytes.count) {
                print("Unexpected PSSH box EOF: No info about key IDs count (4 bytes)")
                return nil
            }
            let keyIDsCount: Int32 = PSSHBinaryUtil.getVal(boxBytes, offset: offset, bigEndian: true) ?? -1
            offset += 4
            if (keyIDsCount < 0) {
                #if DEBUG
                print("Warning: Invalid PSSH key IDs count")
                #endif
            } else {
                keyIDs = []
                if (keyIDsCount > 0) {
                    for i in 0...keyIDsCount - 1 {
                        if (offset + 16 >= boxBytes.count) {
                            #if DEBUG
                            print("Unexpected PSSH box EOF: No info about key ID " + String(i + 1) + " (16 bytes)")
                            #endif
                            break
                        }
                        let bytes = [UInt8].init(boxBytes[offset...offset + 15])
                        offset += 16
                        keyIDs?.append(bytes)
                    }
                }
            }
        }
        if (offset + 4 >= boxBytes.count) {
#if DEBUG
            print("PSSH box EOF: No info about init data size (4 bytes)")
#endif
            return PSSHBox(sysID: sysID, version: version, flags: flags, keyIDs: keyIDs, initData: nil)
        }
        let payloadSize: Int32 = PSSHBinaryUtil.getVal(boxBytes, offset: offset, bigEndian: true) ?? -1
        offset += 4
        if (offset >= boxBytes.count || payloadSize <= 0) {
            #if DEBUG
            print("Warning: Nil PSSH box data")
            #endif
            return PSSHBox(sysID: sysID, version: version, flags: flags, keyIDs: keyIDs, initData: nil)
        }
        let payload = [UInt8].init(boxBytes[offset...offset + Int(payloadSize) - 1])
        offset += Int(payloadSize)
        if (boxBytes.count > offset) {
            print("Warning: read position isn't at the end (" + String(offset) + "/" + String(boxBytes.count) + ") . Possible unknown version of PSSH box with new data")
        }
        return PSSHBox(sysID: sysID, version: version, flags: flags, keyIDs: keyIDs, initData: Data(payload))
    }
}
