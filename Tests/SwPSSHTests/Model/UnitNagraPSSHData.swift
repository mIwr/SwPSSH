//
//  UnitNagraPSSH.swift
//  SwPSSHTests
//
//  Created by developer on 10.09.2024.
//

import Foundation

import XCTest
@testable import SwPSSH

final class UnitNagraPSSHData: XCTestCase {
    
    func testPSSHSerializeWithNagraData() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.nagraPSSHBoxEncoded)
        let nagraPayload = pssh?.nagraPayload
        let rebuiltNagraPayloadData = nagraPayload?.serialize()
        let rebuiltPssh = PSSHBox(sysID: pssh?.sysID ?? [], version: pssh?.version ?? 0, flags: pssh?.flags ?? [], keyIDs: nil, initData: rebuiltNagraPayloadData)
        let serialized = rebuiltPssh.serialize()
        XCTAssertEqual(serialized, TestConstants.nagraPSSHBoxEncoded, "Invalid PSSH serializer")
    }
    
    func testWdvConvertFromNagraData() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.nagraPSSHBoxEncoded)
        let nagraPayload = pssh?.nagraPayload
        let wdvPayload = nagraPayload?.asWidevinePsshData()
        XCTAssertNotNil(wdvPayload, "Invalid Nagra->Widevine converter")
        let rebuiltPssh = PSSHBox(sysID: PSSHConstants.widevineSysID, version: pssh?.version ?? 0, flags: pssh?.flags ?? [], keyIDs: nil, initData: try? wdvPayload?.serializedData())
        let serialized = rebuiltPssh.serialize()
        let wdvPssh = PSSHBox.from(b64EncodedBox: serialized)
        XCTAssertNotNil(wdvPssh, "Invalid PSSH parser")
        XCTAssertTrue(wdvPssh?.widevineSystem == true, "Invalid Widevine PSSH data or parser")
        let wdvPayload2 = wdvPssh?.wdvPayload
        XCTAssertNotNil(wdvPayload2, "Invalid Widevine PSSH data or parser")
        XCTAssertEqual(wdvPayload?.keyIds.count, wdvPayload2?.keyIds.count, "Invalid Widevine PSSH data or parser")
        XCTAssertEqual(wdvPayload?.contentID, wdvPayload2?.contentID, "Invalid Widevine PSSH data or parser")
    }
    
}
