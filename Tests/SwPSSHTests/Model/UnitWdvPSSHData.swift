//
//  UnitWdvPSSHData.swift
//  SwPSSHTests
//
//  Created by developer on 09.08.2024.
//

import XCTest
@testable import SwPSSH

final class UnitWdvPSSHData: XCTestCase {
    
    func testPSSHSerializeWithWdvData() {
        let pssh = PSSHBox.from(b64EncodedBox: TestConstants.wdvPSSHBoxEncoded)
        let wdvPayload = pssh?.wdvPayload
        let rebuiltWdvPayloadData = try? wdvPayload?.serializedData()
        let rebuiltPssh = PSSHBox(sysID: pssh?.sysID ?? [], version: pssh?.version ?? 0, flags: pssh?.flags ?? [], initData: rebuiltWdvPayloadData)
        let serialized = rebuiltPssh.serialize()
        XCTAssertEqual(serialized, TestConstants.wdvPSSHBoxEncoded, "Invalid PSSH serializer")
    }
    
}
