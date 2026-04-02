//
//  NagraPsshData+WDVConverter.swift
//  SwPSSH
//
//  Created by developer on 10.09.2024.
//

import Foundation

extension NagraPsshData {
    
    /// Transforms Nagra PSSH payload data as Widevine payload
    public func asWidevinePsshData() -> WidevinePsshData {
        var wdvPsshData = WidevinePsshData()
        wdvPsshData.algorithm = .aesctr
        wdvPsshData.keyIds = [keyId.replacingOccurrences(of: "-", with: "").data(using: .utf8) ?? Data()]
        wdvPsshData.contentID = contentId.data(using: .utf8) ?? Data()
        return wdvPsshData
    }
    
}
