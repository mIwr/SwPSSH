//
//  PlayReadyRecordHeader.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

import Foundation

///PlayReady Header (PRH) is used by a client to locate or acquire a license for the piece of content it is stored in
///
///Raw data is encoded using UTF-16LE
public class PlayReadyRecordHeader {
    
    ///Header version
    public let version: String
    ///Header keys
    public let keys: [PlayReadyRecordHeaderKey]
    ///License acquisition url (LA_UR)
    public let licenseAcquisitionUrl: String
    ///License UI url (LUI_URL)
    public let licenseUIUrl: String
    ///Domain service UUID bytes
    public let domainServiceIdBytes: [UInt8]
    ///Base64-encoded Domain service UUID bytes
    public var domainServiceId: String {
        get {
            let data = Data(domainServiceIdBytes)
            return data.base64EncodedString()
        }
    }
    
    public init(version: String, keys: [PlayReadyRecordHeaderKey], licenseAcquisitionUrl: String, licenseUIUrl: String, domainServiceIdBytes: [UInt8]) {
        self.version = version
        self.keys = keys
        self.licenseAcquisitionUrl = licenseAcquisitionUrl
        self.licenseUIUrl = licenseUIUrl
        self.domainServiceIdBytes = domainServiceIdBytes
    }
    
    public init(version: String, keys: [PlayReadyRecordHeaderKey], licenseAcquisitionUrl: String, licenseUIUrl: String, domainServiceIdB64: String) {
        self.version = version
        self.keys = keys
        self.licenseAcquisitionUrl = licenseAcquisitionUrl
        self.licenseUIUrl = licenseUIUrl
        let data = Data(base64Encoded: domainServiceIdB64) ?? Data()
        self.domainServiceIdBytes = [UInt8].init(data)
    }
    
    ///Tries to parse PlayReady header from record object
    ///- Parameter record: PlayReady Record Object
    ///- Parameter parseCallback: PlayReady Record Object parse completion handler
    public static func from(record: PlayReadyRecord, parseCallback: @escaping (PlayReadyRecordHeader?) -> ()) {
        _ = PlayReadyRecordHeaderXmlParser(xmlData: record.recordValue, parsedCallback: parseCallback)
    }
    
    ///Tries to parse PlayReady header from record object
    ///- Parameter record: PlayReady Record Object
    ///- Returns: PlayReady Record Header parse result
    public static func fromSync(record: PlayReadyRecord) -> PlayReadyRecordHeader? {
        var res: PlayReadyRecordHeader?
        var finish = false
        _ = PlayReadyRecordHeaderXmlParser(xmlData: record.recordValue) { header in
            res = header
            finish = true
        }
        while !finish {
            Thread.sleep(forTimeInterval: 0.1)
        }
        return res
    }
}
