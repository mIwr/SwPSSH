//
//  PlayReadyRecordType.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

///Type of data stored in the Record Value
public enum PlayReadyRecordType: UInt16 {
    
    ///Indicates that the record contains a PlayReady Header (PRH)
    case playReadyHeader = 1
    ///Reserved
    case reserved = 2
    ///Indicates an Embedded License Store (ELS)
    case embed = 3
    
}
