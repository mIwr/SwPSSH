//
//  UnitPSSHBox.swift
//  SwPSSHTests
//
//  Created by developer on 09.08.2024.
//

import XCTest
@testable import SwPSSH

final class UnitPSSHBox: XCTestCase {
    
    func testCommonPSSHV1Parse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.commonPSSHBoxV1Encoded)
        XCTAssertNotNil(pssh, "Invalid PSSH parser")
        XCTAssertEqual(pssh?.keyIDs?.count, 2, "Invalid PSSH parser")
    }
    
    func testCommonPSSHV1Serialize() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.commonPSSHBoxV1Encoded)
        let serialized = pssh?.serialize()
        XCTAssertEqual(serialized, TestConstants.commonPSSHBoxV1Encoded, "Invalid PSSH serializer")
    }
    
    func testWidevinePSSHParse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.wdvPSSHBoxEncoded)
        XCTAssertNotNil(pssh, "Invalid PSSH parser")
        XCTAssertTrue(pssh?.widevineSystem == true, "Invalid Widevine PSSH data or parser")
        let wdvPayload = pssh?.wdvPayload
        XCTAssertNotNil(wdvPayload, "Invalid Widevine PSSH data or parser")
    }
    
    func testWidevinePSSHSerialize() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.wdvPSSHBoxEncoded)
        let serialized = pssh?.serialize()
        XCTAssertEqual(serialized, TestConstants.wdvPSSHBoxEncoded, "Invalid PSSH serializer")
    }
    
    func testPlayReadyPSSHParse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.playReadyPSSHBoxEncoded)
        XCTAssertNotNil(pssh, "Invalid PSSH parser")
        XCTAssertTrue(pssh?.playReadySystem == true, "Invalid PlayReady PSSH data or parser")
        let playReadyPayload = pssh?.playReadyPayload
        XCTAssertNotNil(playReadyPayload, "Invalid PlayReady PSSH data or parser")
    }
    
    func testPlayReadyPSSHSerialize() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.playReadyPSSHBoxEncoded)
        let serialized = pssh?.serialize()
        XCTAssertEqual(serialized, TestConstants.playReadyPSSHBoxEncoded, "Invalid PSSH serializer")
    }
    
    func testNagraPSSHParse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.nagraPSSHBoxEncoded)
        XCTAssertNotNil(pssh, "Invalid PSSH parser")
        XCTAssertTrue(pssh?.nagraSystem == true, "Invalid Nagra PSSH data or parser")
        let nagraPayload = pssh?.nagraPayload
        XCTAssertNotNil(nagraPayload, "Invalid Nagra PSSH data or parser")
    }
    
    func testNagraPSSHSerialize() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.nagraPSSHBoxEncoded)
        let serialized = pssh?.serialize()
        XCTAssertEqual(serialized, TestConstants.nagraPSSHBoxEncoded, "Invalid PSSH serializer")
    }
}
