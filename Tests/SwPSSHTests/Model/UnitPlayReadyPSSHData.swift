//
//  UnitPlayReadyPSSHData.swift
//  SwPSSHTests
//
//  Created by developer on 09.08.2024.
//

import XCTest
@testable import SwPSSH

final class UnitPlayReadyPSSHData: XCTestCase {
    
    func testPlayReadyHeaderAsyncParse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.playReadyPSSHBoxEncoded)
        if let playReadyRecord = pssh?.playReadyPayload?.records.first {
            let exp = self.expectation(description: "Request time-out expectation")
            PlayReadyRecordHeader.from(record: playReadyRecord) { header in
                XCTAssertNotNil(header, "Invalid PlayReady PSSH parser")
                exp.fulfill()
            }
            waitForExpectations(timeout: 10) { error in
                if let g_error = error
                {
                    print(g_error)
                    XCTAssert(false, "Timeout error: " + g_error.localizedDescription)
                }
            }
        }
    }
    
    func testPlayReadyHeaderSyncParse() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.playReadyPSSHBoxEncoded)
        let playReadyPayload = pssh?.playReadyPayload
        let playReadyHeader = playReadyPayload?.records.first?.recordHeader
        XCTAssertNotNil(playReadyHeader, "Invalid PlayReady PSSH parser")
    }
    
    func testPlayReadyData_4_0Parse() {
        let data = Data(base64Encoded: TestConstants.playReadyPSSHDataEncoded_4_0) ?? Data()
        let playReadyPayload = PlayReadyPsshData.from(psshPayload: data)
        let playReadyHeader = playReadyPayload?.records.first?.recordHeader
        XCTAssertNotNil(playReadyHeader, "Invalid PlayReady PSSH parser")
        XCTAssertEqual(playReadyHeader?.keys.count, 1, "Invalid PlayReady PSSH parser")
    }
    
    func testPlayReadyData_4_1Parse() {
        let data = Data(base64Encoded: TestConstants.playReadyPSSHDataEncoded_4_1) ?? Data()
        let playReadyPayload = PlayReadyPsshData.from(psshPayload: data)
        let playReadyHeader = playReadyPayload?.records.first?.recordHeader
        XCTAssertNotNil(playReadyHeader, "Invalid PlayReady PSSH parser")
        XCTAssertEqual(playReadyHeader?.keys.count, 1, "Invalid PlayReady PSSH parser")
    }
    
    func testPlayReadyData_4_3Parse() {
        let data = Data(base64Encoded: TestConstants.playReadyPSSHDataEncoded_4_3) ?? Data()
        let playReadyPayload = PlayReadyPsshData.from(psshPayload: data)
        let playReadyHeader = playReadyPayload?.records.first?.recordHeader
        XCTAssertNotNil(playReadyHeader, "Invalid PlayReady PSSH parser")
        XCTAssertEqual(playReadyHeader?.keys.count, 2, "Invalid PlayReady PSSH parser")
    }
    
    func testPSSHSerializeWithPlayReadyData() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.playReadyPSSHBoxEncoded)
        let playReadyPayload = pssh?.playReadyPayload
        let rebuiltPlayReadyPayloadData = playReadyPayload?.serialize()
        let rebuiltPssh = PSSHBox(sysID: pssh?.sysID ?? [], version: pssh?.version ?? 0, flags: pssh?.flags ?? [], initData: rebuiltPlayReadyPayloadData)
        let serialized = rebuiltPssh.serialize()
        XCTAssertEqual(serialized, TestConstants.playReadyPSSHBoxEncoded, "Invalid PSSH serializer")
    }
    
}
