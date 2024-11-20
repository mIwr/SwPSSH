//
//  CryptoUtil.swift
//  SwPSSH
//
//  Created by Developer on 07.09.2023.
//

import Foundation
#if canImport(CommonCrypto)
import CommonCrypto //SwiftPM can't import it
#else
import CryptoSwift
#endif

final class PSSHCryptoUtil {
    
    fileprivate init() {}
    
    #if canImport(CommonCrypto)
    static func sha1(buffer: [UInt8]) -> [UInt8] {
        var digest: [UInt8] = [UInt8].init(repeating: 0, count: Int(CC_SHA1_DIGEST_LENGTH))
        let data = Data(buffer)
        data.withUnsafeBytes{ (unsafePointer) -> Void in
            guard let addr = unsafePointer.baseAddress else {return}
            let bufferPointer: UnsafePointer<UInt8> = addr.assumingMemoryBound(to: UInt8.self)
            let rawPtr = UnsafeRawPointer(bufferPointer)
            CC_SHA1(rawPtr, CC_LONG(data.count), &digest)
        }
        return digest
        
    }
    #else
    static func sha1(buffer: [UInt8]) -> [UInt8] {
        let sha1Eng = SHA1()
        let digest = sha1Eng.calculate(for: buffer)
        return digest
    }
    #endif
    static func sha1String(buffer: [UInt8]) -> String {
        let digest: [UInt8] = sha1(buffer: buffer)
        var digestHex = ""
        for index in 0..<Int(digest.count) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
    
#if canImport(CommonCrypto)
    static func sha256(buffer: [UInt8]) -> [UInt8] {
        var digest: [UInt8] = [UInt8].init(repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        let data = Data(buffer)
        data.withUnsafeBytes{ (unsafePointer) -> Void in
            guard let addr = unsafePointer.baseAddress else {return}
            let bufferPointer: UnsafePointer<UInt8> = addr.assumingMemoryBound(to: UInt8.self)
            let rawPtr = UnsafeRawPointer(bufferPointer)
            CC_SHA256(rawPtr, CC_LONG(data.count), &digest)
        }
        return digest
    }
#else
    static func sha256(buffer: [UInt8]) -> [UInt8] {
        let sha2Eng = SHA2(variant: .sha256)
        let digest = sha2Eng.calculate(for: buffer)
        return digest
    }
#endif
    static func sha256String(buffer: [UInt8]) -> String {
        let digest: [UInt8] = sha256(buffer: buffer)
        var digestHex = ""
        for index in 0..<Int(digest.count) {
            digestHex += String(format: "%02x", digest[index])
        }
        return digestHex
    }
    
#if canImport(CommonCrypto)
    static func aesEcb128Encrypt(msg: [UInt8], key: [UInt8]) -> [UInt8] {
        let msgData = Data(msg)
        let keyData = Data(key)
        var cryptData = Data(count: msg.count + kCCBlockSizeAES128)
        let cryptDataCount = cryptData.count
        var numBytesEncrypted: size_t = 0
        let cryptStatus = cryptData.withUnsafeMutableBytes{ encryptedPtr in
            guard let encAddr = encryptedPtr.baseAddress else {return CCCryptorStatus(kCCParamError)}
            let encBuffPtr: UnsafeMutablePointer<UInt8> = encAddr.assumingMemoryBound(to: UInt8.self)
            let encryptedRawPtr = UnsafeMutableRawPointer(encBuffPtr)
            return msgData.withUnsafeBytes { msgPtr in
                guard let msgAddr = msgPtr.baseAddress else {return CCCryptorStatus(kCCParamError)}
                let msgBuffPtr: UnsafePointer<UInt8> = msgAddr.assumingMemoryBound(to: UInt8.self)
                let msgRawPtr = UnsafeRawPointer(msgBuffPtr)
                let ivData = Data()
                return ivData.withUnsafeBytes { ivPtr in
                    guard let ivAddr = ivPtr.baseAddress else {return CCCryptorStatus(kCCParamError)}
                    let ivBuffPtr: UnsafePointer<UInt8> = ivAddr.assumingMemoryBound(to: UInt8.self)
                    let ivRawPtr = UnsafeRawPointer(ivBuffPtr)
                    return keyData.withUnsafeBytes { keyPtr in
                        guard let keyAddr = keyPtr.baseAddress else {return CCCryptorStatus(kCCParamError)}
                        let keyBuffPtr: UnsafePointer<UInt8> = keyAddr.assumingMemoryBound(to: UInt8.self)
                        let keyRawPtr = UnsafeRawPointer(keyBuffPtr)
                        return CCCrypt(CCOperation(kCCEncrypt), CCAlgorithm(kCCAlgorithmAES), CCOptions(kCCOptionECBMode + kCCOptionPKCS7Padding), keyRawPtr, size_t(kCCKeySizeAES128), ivRawPtr, msgRawPtr, msgData.count, encryptedRawPtr, cryptDataCount, &numBytesEncrypted)
                    }
                }
            }
        }
        if (Int(cryptStatus) == kCCSuccess) {
            cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        } else {
            print("AES-ECB-128 encrypt error: \(cryptStatus)")
        }

        return [UInt8].init(cryptData)
    }
#else
    static func aesEcb128Encrypt(msg: [UInt8], key: [UInt8]) -> [UInt8] {
        do {
            let aesEng = try AES(key: key, blockMode: ECB(), padding: .pkcs7)
            let enc = try aesEng.encrypt(msg)
            return enc
        } catch {
            print(error)
        }
        return []
    }
#endif
}
