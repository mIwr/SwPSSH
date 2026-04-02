//
//  PlayReadyRecordHeaderParser.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

import Foundation
//Non-Apple platforms XML support
#if canImport(FoundationXML)
import FoundationXML
#endif

///PlayReady record header parser
final class PlayReadyRecordHeaderXmlParser: NSObject, XMLParserDelegate {
    
    //4.3.0 fields
    ///Outermost element of the header object. It can contain one DATA element and must contain one version attribute. The version for the header is "4.3.0.0". Every time Microsoft defines new mandatory tags or attributes, a new version number is associated with those tags or attributes. If the version is greater than that for which the client code was written, then the client code must fail, because it implies that the header contains mandatory tags that the client does not understand. If the version is less than or equal to that for which the client code was written, than the client code can safely skip any tags or attributes that it does not understand
    public static let tlHeaderKey = "WRMHEADER"
    ///Container element for header data, including third-party tags. No more than one DATA element may be included in the WRMHEADER element
    public static let headerDataKey = "DATA"
    ///Specifies zero or one KIDS element. No more than one PROTECTINFO element may be included in the DATA element. Optionally includes the LICENSEREQUESTED attribute
    public static let dataProtectInfoKey = "PROTECTINFO"
    ///Specifies whether license acquisition is requesting at least one license or not. Must be set to "true" or "false" if present and is assumed to be set to "true" if not present. This attribute is ignored by PlayReady versions before 4.5. The PlayReady Server SDK application is free to ignore this attribute; it is informational only
    public static let protectInfoLicReqKey = "LICENSEREQUESTED"
    ///Specifies one or more KID elements that may be used for creating decryptor objects for the associated content. Either one or zero KIDS elements may exist under the PROTECTINFO node
    public static let protectInfoKidsKey = "KIDS"
    ///Contains all key data for a given license. If the KIDS node is present, one or more KID element must exist under the KIDS node. The KID element contains the following attributes
    public static let protectInfoKidKey = "KID"
    ///Specifies the encryption algorithm. May be set to either: "AESCTR", "AESCBC", or "COCKTAIL". Optional
    public static let kidAlgIdKey = "ALGID"
    ///Only for AESCTR keys. Contains a checksum calculated by using the KID VALUE attribute and content key. Refer to the Key Checksum Algorithm section of this document for details. Optional
    ///
    ///If this node exists in the WRMHeader XML then its data value must be empty.
    public static let kidChecksumKey = "CHECKSUM"
    ///Contains a base64-encoded key ID GUID value. Note that this GUID (DWORD, WORD, WORD, 8-BYTE array) value must be little endian byte order. Required
    public static let kidValueKey = "VALUE"
    ///Contains the URL for the license acquisition Web service. Only absolute URLs are allowed. No more than one LA_URL element may be included in the DATA element.
    ///
    ///If this node exists in the WRMHeader XML then its data value must not be empty
    public static let dataLaUrlKey = "LA_URL"
    ///Contains the URL for a non-silent license acquisition Web page. Only absolute URLs are allowed. No more than one LUI_URL element may be included in the DATA element.
    ///
    ///If this node exists in the WRMHeader XML then its data value must not be empty
    public static let dataLuiUrlKey = "LUI_URL"
    ///Service ID for the domain service. Only up to one DS_ID element may be included in the DATA element.
    ///
    ///If this node exists in the WRMHeader XML then its data value must not be empty
    public static let dataDsIdKey = "DS_ID"
    ///The content author can add custom XML inside this element. Microsoft code does not act on any data contained inside this element. No more than one CUSTOMATTRIBUTES element may be included in the DATA element.
    ///
    ///If this node exists in the WRMHeader XML then its data value must not be empty
    public static let dataCustomAttributesKey = "CUSTOMATTRIBUTES"
    ///This tag may only contain the value "ONDEMAND". When this tag present in the DATA node and its value is set to "ONDEMAND" then it indicates to an application that it should not expect the full license chain for the content to be available for acquisition, or already present on the client machine, prior to setting up the media graph. If this tag is not set then it indicates that an application can enforce the license to be acquired, or already present on the client machine, prior to setting up the media graph. Only up to one DECRYPTORSETUP element may be included in the DATA element
    public static let dataDecryptorSetupKey = "DECRYPTORSETUP"
    
    //4.0.0 legacy fields
    ///Specifies the size of the content key. Must be set to 16 if ALGID is set to "AESCTR" and 7 if ALGID is set to "COCKTAIL"
    public static let kidKeyLenKey = "KEYLEN"
    
#if swift(>=5.5)
    ///Event-driven xml parse result callback
    fileprivate let _parsedCallback: @Sendable (PlayReadyRecordHeader?) -> ()
#else
    ///Event-driven xml parse result callback
    fileprivate let _parsedCallback: (PlayReadyRecordHeader?) -> ()
#endif
    
    
    ///Header version
    nonisolated(unsafe) fileprivate var _version: String
    ///Header keys
    nonisolated(unsafe) fileprivate var _keys: [PlayReadyRecordHeaderKey]
    ///Legacy header version key algorithm key
    nonisolated(unsafe) fileprivate var _singleKeyAlgo: String
    ///Legacy header version base64-encoded key ID
    nonisolated(unsafe) fileprivate var _singleKeyId: String
    ///Legacy header version key length
    nonisolated(unsafe) fileprivate var _singleKeyLen: UInt8
    ///Legacy header version base64-encoded content key and key ID checksum
    nonisolated(unsafe) fileprivate var _singleKeyChecksum: String
    ///License acquisition Url
    nonisolated(unsafe) fileprivate var _laUrl: String
    ///License UI Url
    nonisolated(unsafe) fileprivate var _luiUrl: String
    ///Base64-encoded domain service UUID
    nonisolated(unsafe) fileprivate var _dsId: String
    ///Header custom attributes from author
    nonisolated(unsafe) fileprivate var _customAttributes: [String: Any]
    
    ///Processing element name
    nonisolated(unsafe) fileprivate var _elementName: String
    ///Processing element value
    nonisolated(unsafe) fileprivate var _elementData: String
    
#if swift(>=5.5)
    public init (xmlData: Data, parsedCallback: @escaping @Sendable (PlayReadyRecordHeader?) -> ()) {
        let utf16Str = String(data: xmlData, encoding: .utf16LittleEndian)
        let data = utf16Str?.data(using: .utf8) ?? xmlData
        let parser = XMLParser(data: data)
        _parsedCallback = parsedCallback
        _version = ""
        _keys = []
        _singleKeyAlgo = ""
        _singleKeyId = ""
        _singleKeyLen = 0
        _singleKeyChecksum = ""
        _laUrl = ""
        _luiUrl = ""
        _dsId = ""
        _customAttributes = [:]
        _elementName = ""
        _elementData = ""
        super.init()
        parser.delegate = self
        parser.parse()
    }
#else
    public init (xmlData: Data, parsedCallback: @escaping (PlayReadyRecordHeader?) -> ()) {
        let utf16Str = String(data: xmlData, encoding: .utf16LittleEndian)
        let data = utf16Str?.data(using: .utf8) ?? xmlData
        let parser = XMLParser(data: data)
        _parsedCallback = parsedCallback
        _version = ""
        _keys = []
        _singleKeyAlgo = ""
        _singleKeyId = ""
        _singleKeyLen = 0
        _singleKeyChecksum = ""
        _laUrl = ""
        _luiUrl = ""
        _dsId = ""
        _customAttributes = [:]
        _elementName = ""
        _elementData = ""
        super.init()
        parser.delegate = self
        parser.parse()
    }
#endif
    
    
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if (!_singleKeyId.isEmpty) {
            _keys.append(PlayReadyRecordHeaderKey(algID: _singleKeyAlgo, checksumB64: _singleKeyChecksum, keyIDB64: _singleKeyId))
        }
        if (_keys.isEmpty) {
            _parsedCallback(nil)
            return
        }
        let parsed = PlayReadyRecordHeader(version: _version, keys: _keys, licenseAcquisitionUrl: _laUrl, licenseUIUrl: _luiUrl, domainServiceIdB64: _dsId)
        _parsedCallback(parsed)
    }

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        _elementName = elementName
        switch(elementName) {
        case PlayReadyRecordHeaderXmlParser.tlHeaderKey:
            if let safeVersion = attributeDict["version"], !safeVersion.isEmpty {
                _version = safeVersion
            }
            break
        case PlayReadyRecordHeaderXmlParser.protectInfoKidKey:
            guard let safeKeyID = attributeDict[PlayReadyRecordHeaderXmlParser.kidValueKey] else {
                break
            }
            let algoID = attributeDict[PlayReadyRecordHeaderXmlParser.kidAlgIdKey] ?? ""
            let checksum = attributeDict[PlayReadyRecordHeaderXmlParser.kidChecksumKey]
            _keys.append(PlayReadyRecordHeaderKey(algID: algoID, checksumB64: checksum, keyIDB64: safeKeyID))
            break
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        _elementData = string
        switch(_elementName) {
        case PlayReadyRecordHeaderXmlParser.dataLaUrlKey:
            _laUrl = string
            break
        case PlayReadyRecordHeaderXmlParser.dataLuiUrlKey:
            _luiUrl = string
            break
        case PlayReadyRecordHeaderXmlParser.dataDsIdKey:
            _dsId = string
            break
        case PlayReadyRecordHeaderXmlParser.kidAlgIdKey:
            _singleKeyAlgo = string
            break
        case PlayReadyRecordHeaderXmlParser.protectInfoKidKey:
            _singleKeyId = string
            break
        case PlayReadyRecordHeaderXmlParser.kidKeyLenKey:
            _singleKeyLen = UInt8(string) ?? 0
            break
        case PlayReadyRecordHeaderXmlParser.kidChecksumKey:
            _singleKeyChecksum = string
            break
        default: break
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        _elementName = ""
        _elementData = ""
    }
}

#if swift(>=5.5)
extension PlayReadyRecordHeaderXmlParser: Sendable {}
#endif
