//
//  NagraPsshData.swift
//  SwPSSH
//
//  Created by developer on 10.09.2024.
//

import Foundation

///The Nagra PSSH data from box container
public class NagraPsshData: Codable {
    
    ///Content ID
    public let contentId: String
    ///Key ID
    public let keyId: String
    
    public init(contentId: String, keyId: String) {
        self.contentId = contentId
        self.keyId = keyId
    }
    
    ///Serializes Nagra PSSH data as raw bytes data
    ///- Returns: Raw bytes data
    public func serialize() -> Data {
        do {
            let jsonData = try JSONEncoder().encode(self)
            let b64JsonData = jsonData.base64EncodedData()
            return b64JsonData
        } catch {
#if DEBUG
            print("Nagra PSSH JSON parse error:", error)
#endif
        }
        return Data()
    }
    
    ///Tries to parse Nagra PSSH data  from raw bytes data
    ///- Parameter psshPayload: Raw bytes data
    ///- Returns: Nagra PSSH data parse result. Optional
    public static func from(psshPayload: Data) -> NagraPsshData? {
        guard let safeDecodedPsshPayload = Data(base64Encoded: psshPayload) else {
            return nil
        }
        do {
            let nagra = try JSONDecoder().decode(NagraPsshData.self, from: safeDecodedPsshPayload)
            return nagra
        } catch {
            #if DEBUG
            print("Nagra PSSH JSON parse error:", error)
            #endif
        }
        return nil
    }
}
