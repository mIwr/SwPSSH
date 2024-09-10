//
//  PSSHBox+Nagra.swift
//  SwPSSH
//
//  Created by developer on 10.09.2024.
//

extension PSSHBox {
    
    ///Nagra PSSH box flag
    public var nagraSystem: Bool {
        get {
            return sysID == PSSHConstants.nagraSysID
        }
    }
    
    ///Parsed Nagra PSSH data
    public var nagraPayload: NagraPsshData? {
        get {
            guard let safeInitData = initData else {return nil}
            return NagraPsshData.from(psshPayload: safeInitData)
        }
    }
}
