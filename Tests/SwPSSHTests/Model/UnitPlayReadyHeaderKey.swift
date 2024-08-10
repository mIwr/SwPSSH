//
//  UnitPlayReadyHeaderKey.swift
//  SwPSSHTests
//
//  Created by developer on 10.08.2024.
//

import XCTest
@testable import SwPSSH

final class UnitPlayReadyHeaderKey: XCTestCase {
    
    let seed = [UInt8].init(repeating: 1, count: Int(PlayReadyRecordHeaderKey.keySeedSize))
    let keyID = [UInt8].init(repeating: 2, count: Int(PlayReadyRecordHeaderKey.keySize))
    
    func testZeroContentKeyGenerator() {
        let keySeed = [UInt8].init(repeating: 0, count: Int(PlayReadyRecordHeaderKey.keySeedSize))
        let kid = [UInt8].init(repeating: 0, count: Int(PlayReadyRecordHeaderKey.keySize))
        let contentKey = PlayReadyRecordHeaderKey.generatePlayReadyContentKey(keySeed: keySeed, keyID: kid)
        XCTAssertGreaterThan(contentKey.count, 0, "Invalid PlayReady content key generator")
        XCTAssertEqual(contentKey, TestConstants.zeroContentKey, "Invalid PlayReady content key generator")
    }
    
    func testContenKeyGenerator() {
        let contentKey = PlayReadyRecordHeaderKey.generatePlayReadyContentKey(keySeed: seed, keyID: keyID)
        XCTAssertGreaterThan(contentKey.count, 0, "Invalid PlayReady content key generator")
    }
    
    func testAesCbcChecksum() {
        let contentKey = PlayReadyRecordHeaderKey.generatePlayReadyContentKey(keySeed: seed, keyID: keyID)
        let checksum = PlayReadyRecordHeaderKey.calculatePlayReadyKeyChecksum(algID: PlayReadyRecordHeaderKeyAlgo.aesCbcKey, keyID: keyID, contentKey: contentKey)
        XCTAssertTrue(checksum.isEmpty, "Invalid PlayReady AESCBC checksum generator")
    }
    
    func testAesCtrChecksum() {
        let contentKey = PlayReadyRecordHeaderKey.generatePlayReadyContentKey(keySeed: seed, keyID: keyID)
        let checksum = PlayReadyRecordHeaderKey.calculatePlayReadyKeyChecksum(algID: PlayReadyRecordHeaderKeyAlgo.aesCtrKey, keyID: keyID, contentKey: contentKey)
        XCTAssertTrue(!checksum.isEmpty, "Invalid PlayReady AESCTR checksum generator")
    }
    
    func testCocktailChecksum() {
        let contentKey = PlayReadyRecordHeaderKey.generatePlayReadyContentKey(keySeed: seed, keyID: keyID)
        let checksum = PlayReadyRecordHeaderKey.calculatePlayReadyKeyChecksum(algID: PlayReadyRecordHeaderKeyAlgo.cocktailKey, keyID: keyID, contentKey: contentKey)
        XCTAssertTrue(!checksum.isEmpty, "Invalid PlayReady AESCTR checksum generator")
    }
}
