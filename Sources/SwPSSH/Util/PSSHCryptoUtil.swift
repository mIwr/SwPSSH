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
}
