//
//  PSSHBoxPlayReadyExt.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

extension PSSHBox {
    
    ///PlayReady PSSH box flag
    public var playReadySystem: Bool {
        get {
            return sysID == PSSHConstants.playReadySysID
        }
    }
    
    ///Parsed PlayReady PSSH data
    public var playReadyPayload: PlayReadyPsshData? {
        get {
            guard let safeInitData = initData else {return nil}
            return PlayReadyPsshData.from(psshPayload: safeInitData)
        }
    }
}
