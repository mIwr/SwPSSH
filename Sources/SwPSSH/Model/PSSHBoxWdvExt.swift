//
//  PSSHBoxWdvExt.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

extension PSSHBox {
    
    ///Widevine PSSH box flag
    public var widevineSystem: Bool {
        get {
            return sysID == PSSHConstants.widevineSysID
        }
    }
    
    ///Parsed Widevine PSSH data
    public var wdvPayload: WidevinePsshData? {
        get {
            guard let safeInitData = initData else {return nil}
            do {
                let parsed = try WidevinePsshData(serializedBytes: safeInitData)
                return parsed
            } catch {
                #if DEBUG
                print(error)
                #endif
            }
            return nil
        }
    }
}
