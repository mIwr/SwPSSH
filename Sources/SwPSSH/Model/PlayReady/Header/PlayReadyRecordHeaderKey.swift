//
//  PlayReadyRecordHeaderKey.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

import Foundation
import CryptoSwift

///Key data for given license
public class PlayReadyRecordHeaderKey {
    
    static let keySize: UInt8 = 16
    static let keySeedSize: UInt8 = 30
    
    ///Encryption algorithm key
    public let algID: String
    ///Parsed encryption algorithm type
    public var parsedAlgID: PlayReadyRecordHeaderKeyAlgo? {
        get {
            return PlayReadyRecordHeaderKeyAlgo.from(apiKey: algID)
        }
    }
    ///Encryption algorithm key length
    public var algKeyLength: Int? {
        get {
            return parsedAlgID?.keyLength
        }
    }
    ///Key ID and content key checksum bytes
    public let checksumBytes: [UInt8]?
    ///Base64-encoded key ID and content key checksum bytes
    public var checksum: String? {
        get {
            guard let safeChecksumBytes = checksumBytes else {
                return nil
            }
            let data = Data(safeChecksumBytes)
            return data.base64EncodedString()
        }
    }
    ///Key ID bytes
    public let keyIDBytes: [UInt8]
    ///Base64-encoded key ID bytes
    public var keyID: String {
        get {
            let data = Data(keyIDBytes)
            return data.base64EncodedString()
        }
    }
    
    public init(algID: String, checksumBytes: [UInt8]?, keyIDBytes: [UInt8]) {
        self.algID = algID
        self.checksumBytes = checksumBytes
        self.keyIDBytes = keyIDBytes
    }
    
    public init(algID: String, checksumB64: String?, keyIDB64: String) {
        self.algID = algID
        var data = Data(base64Encoded: keyIDB64) ?? Data()
        self.keyIDBytes = [UInt8].init(data)
        guard let safeChecksumB64 = checksumB64 else {
            self.checksumBytes = nil
            return
        }
        data = Data(base64Encoded: safeChecksumB64) ?? Data()
        self.checksumBytes = [UInt8].init(data)
    }
    
    ///https://learn.microsoft.com/en-us/playready/specifications/playready-key-seed
    public static func generatePlayReadyContentKey(keySeed: [UInt8], keyID: [UInt8]) -> [UInt8] {
        if (keySeed.count < PlayReadyRecordHeaderKey.keySeedSize) {
            print("Invalid key seed size: expected at least " + String(PlayReadyRecordHeaderKey.keySeedSize) + ", but was " + String(keySeed.count))
            return []
        }
        let keySizeInt = Int(PlayReadyRecordHeaderKey.keySize)
        if (keyID.count < keySizeInt) {
            print("Invalid key ID size: expected " + String(keySizeInt) + ", but was " + String(keyID.count))
            return []
        }
        let truncatedKeySeed = [UInt8].init(keySeed[0...Int(keySeedSize) - 1])
        let truncatedKeyID = [UInt8].init(keyID[0...Int(keySizeInt) - 1])
        var data = [UInt8].init(truncatedKeySeed)
        data.append(contentsOf: truncatedKeyID)
        let digestA = PSSHCryptoUtil.sha256(buffer: data)
        data.append(contentsOf: truncatedKeySeed)
        let digestB = PSSHCryptoUtil.sha256(buffer: data)
        data.append(contentsOf: truncatedKeyID)
        let digestC = PSSHCryptoUtil.sha256(buffer: data)
        
        var contentKey = [UInt8].init(repeating: 0, count: keySizeInt)
        for i in 0...keySizeInt - 1 {
            let calculated = digestA[i] ^ digestA[i + keySizeInt] ^ digestB[i] ^ digestB[i + keySizeInt] ^ digestC[i] ^ digestC[i + keySizeInt]
            contentKey[i] = calculated
        }
        return contentKey
    }
    
    ///https://learn.microsoft.com/en-us/playready/specifications/playready-header-specification#5-key-checksum-algorithm
    public static func calculatePlayReadyKeyChecksum(algo: PlayReadyRecordHeaderKeyAlgo, keyID: [UInt8], contentKey: [UInt8]) -> [UInt8] {
        return calculatePlayReadyKeyChecksum(algID: algo.apiKey, keyID: keyID, contentKey: contentKey)
    }
    
    ///https://learn.microsoft.com/en-us/playready/specifications/playready-header-specification#5-key-checksum-algorithm
    public static func calculatePlayReadyKeyChecksum(algID: String, keyID: [UInt8], contentKey: [UInt8]) -> [UInt8] {
        if (keyID.count < PlayReadyRecordHeaderKey.keySize) {
            print("Invalid key ID size: expected " + String(PlayReadyRecordHeaderKey.keySize) + ", but was " + String(keyID.count))
            return []
        }
        if (contentKey.count < PlayReadyRecordHeaderKey.keySize) {
            print("Invalid content key size: expected " + String(PlayReadyRecordHeaderKey.keySize) + ", but was " + String(keyID.count))
            return []
        }
        switch (algID) {
        case PlayReadyRecordHeaderKeyAlgo.aesCbcKey:
            print("AES-CBC has no checksum algorithm defined")
            return []
        case PlayReadyRecordHeaderKeyAlgo.aesCtrKey:
            //For an ALGID value set to "AESCTR", the 16-byte Key ID is encrypted with a 16-byte AES content key using ECB mode. The first 8 bytes of the buffer is extracted and base64 encoded.
            do {
                let aesEng = try AES(key: contentKey, blockMode: ECB(), padding: .pkcs7)
                let enc = try aesEng.encrypt(keyID)
                let checksumBytes = [UInt8].init(enc[0...7])
                return checksumBytes
            } catch {
                print(error)
            }
            return []
        case PlayReadyRecordHeaderKeyAlgo.cocktailKey:
            //A 21-byte buffer is created. The content key is put in the buffer and the rest of the buffer is filled with zeros.
            //For five iterations: buffer = SHA-1 (buffer)
            //The first 7 bytes of the buffer are extracted
            var buff: [UInt8] = [UInt8].init(contentKey[0...Int(PlayReadyRecordHeaderKey.keySize) - 1])
            buff.append(contentsOf: [UInt8].init(repeating: 0, count: 5))
            for _ in 0...4 {
                buff = PSSHCryptoUtil.sha1(buffer: buff)
            }
            let checksumBytes = [UInt8].init(buff[0...6])
            return checksumBytes
        default:
            print("Unknown algorithm ID '" + algID + "'")
            return []
        }
    }
    
}
