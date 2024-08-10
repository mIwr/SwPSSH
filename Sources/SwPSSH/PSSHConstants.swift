//
//  PSSHConstants.swift
//  SwPSSH
//
//  Created by developer on 09.08.2024.
//

public final class PSSHConstants {
    ///PSSH box MAGIC header
    public static let psshHeader: [UInt8] = [ 0x70, 0x73, 0x73, 0x68 ]
    ///PSSH box Version 1 system ID
    public static let commonSysID: [UInt8] = [ 0x10,0x77,0xef,0xec,0xc0,0xb2,0x4d,0x02,0xac,0xe3,0x3c,0x1e,0x52,0xe2,0xfb,0x4b ]//1077efec-c0b2-4d02-ace3-3c1e52e2fb4b
    ///PSSH box Widevine system ID
    public static let widevineSysID: [UInt8] = [ 0xed,0xef,0x8b,0xa9,0x79,0xd6,0x4a,0xce,0xa3,0xc8,0x27,0xdc,0xd5,0x1d,0x21,0xed ]//edef8ba9-79d6-4ace-a3c8-27dcd51d21ed
    ///PSSH box PlayReady system ID
    public static let playReadySysID: [UInt8] = [ 0x9a,0x04,0xf0,0x79,0x98,0x40,0x42,0x86,0xab,0x92,0xe6,0x5b,0xe0,0x88,0x5f,0x95 ]//9a04f079-9840-4286-ab92-e65be0885f95
    ///PSSH box FairPlay system ID
    public static let fairPlaySysID: [UInt8] = [ 0x94,0xce,0x86,0xfb,0x07,0xff,0x4f,0x43,0xad,0xb8,0x93,0xd2,0xfa,0x96,0x8c,0xa2 ]//94ce86fb-07ff-4f43-adb8-93d2fa968ca2
}