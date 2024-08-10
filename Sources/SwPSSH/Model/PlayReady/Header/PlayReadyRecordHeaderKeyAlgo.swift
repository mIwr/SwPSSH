//
//  PlayReadyRecordHeaderKeyAlgo.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

///Header key encryption base64-encoded
public enum PlayReadyRecordHeaderKeyAlgo: UInt8 {
    ///AES-CBC-128
    case aesCbc
    ///AES-CTR-128
    case aesCtr
    ///Cocktail algo
    case cocktail
}

extension PlayReadyRecordHeaderKeyAlgo {
    
    static let aesCbcKey = "AESCBC"
    static let aesCtrKey = "AESCTR"
    static let cocktailKey = "COCKTAIL"
    
    public static func from(apiKey: String) -> PlayReadyRecordHeaderKeyAlgo? {
        switch(apiKey) {
            case PlayReadyRecordHeaderKeyAlgo.aesCbcKey: return .aesCbc
            case PlayReadyRecordHeaderKeyAlgo.aesCtrKey: return .aesCtr
            case PlayReadyRecordHeaderKeyAlgo.cocktailKey: return .cocktail
            default: return nil
        }
    }
    
    public var apiKey: String {
        switch(self) {
            case .aesCbc: return PlayReadyRecordHeaderKeyAlgo.aesCbcKey
            case .aesCtr: return PlayReadyRecordHeaderKeyAlgo.aesCtrKey
            case .cocktail: return PlayReadyRecordHeaderKeyAlgo.cocktailKey
        }
    }
    
    public var keyLength: Int {
        switch(self) {
            case .aesCbc: return 16
            case .aesCtr: return 16
            case .cocktail: return 7
        }
    }
    
}
