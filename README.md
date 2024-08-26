# SwPSSH - Protection System Specific Header (PSSH) box container swift impl

[![Swift Package Manager compatible](https://img.shields.io/badge/SPM-compatible-brightgreen.svg?style=flat&colorA=28a745&&colorB=4E4E4E)](https://github.com/apple/swift-package-manager)
[![Platform](https://img.shields.io/badge/Platforms-iOS%20%7C%20Android%20%7CmacOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux-4E4E4E.svg?colorA=28a745)](#Setup)


<p align="center">
    <a href="https://github.com/apple/swift">
        <img src="https://img.shields.io/badge/language-swift-orange.svg">
    </a>
    <a href="http://cocoapods.org/pods/SwPSSH">
        <img src="https://img.shields.io/cocoapods/v/SwPSSH.svg?style=flat">
    </a>
    <a href="http://cocoapods.org/pods/SwPSSH">
        <img src="https://img.shields.io/cocoapods/p/SwPSSH.svg?style=flat">
    </a>
    <a href="./LICENSE">
        <img src="https://img.shields.io/cocoapods/l/SwPSSH.svg?style=flat">
    </a>
</p>

## Content

- [Introduction](#Introduction)

- [Setup](#Setup)

- [Getting started](#Getting-started)

## Introduction

The library allows to parse/serialize PSSH boxes with Widevine or PlayReady payload

macOS 10.13+ and iOS 11.0+ are supported by the module code base. Other platforms (watchOS 4.0+, tvOS 11.0+, Windows, Linux, Android) have experimental support

**Notice: XCode 15+ doesn't allow to use iOS 11, tvOS 11 as minimum deployment target during build process. So the mimimum deployment target for these platforms in your project must be 12 in fact.**
**If you want to bypass this limitation, you have to roll back to XCode 14.** More info: [1](https://github.com/Alamofire/Alamofire/pull/3823), [2](https://github.com/realm/realm-swift/issues/8368#issuecomment-1737604011)

### General PSSH box container schema

PSSH is a standardized container that holds metadata specific to the protection system employed for securing digital content. Hence PSSH is a part of DRM signalling.

PSSH DOES NOT contain the enryption key itself (it’s a secret), but it contains the necessary information about encryption, such as the key ID, the encryption scheme, and other information that is needed to obtain the key from a license server

| Field name     | Type                | Description                                                                     | 
|----------------|---------------------|---------------------------------------------------------------------------------|
| Box size       | UInt32 (Big endian) | Box container bytes count including 'box size' 4 bytes                          |
| Magic header   | String (4 bytes)    | Constant box container magic header - "pssh" (0x70, 0x73, 0x73, 0x68)           |
| PSSH version   | UInt8               | There are two versions of PSSH box: 0 (commonly used) and 1 (new 'recommended') |
| Flags          | Bytes array (3)     | PSSH box bit flags                                                              |
| System ID      | Bytes array         | Constant system UUID bytes array (16)                                           |
| Key IDs count  | UInt32 (Big endian) | Common PSSH V1 key IDs count. Optional                                          |
| Key IDs        | Bytes array         | Common PSSH V1 key IDs data. Optional                                           |
| Init data size | UInt32 (Big endian) | PSSH box init data size in bytes                                                |
| Init data      | Bytes array         | PSSH box init data. Contains payload instance raw data according system ID      |

**System ID variants**

| DRM Technology     | Identifier (System ID)               |
|--------------------|--------------------------------------|
| Widevine           | edef8ba9-79d6-4ace-a3c8-27dcd51d21ed |
| PlayReady          | 9a04f079-9840-4286-ab92-e65be0885f95 |
| FairPlay           | 94ce86fb-07ff-4f43-adb8-93d2fa968ca2 |
| Common (Version 1) | 1077efec-c0b2-4d02-ace3-3c1e52e2fb4b |

More details you can find at [Axinom](https://docs.axinom.com/services/drm/technical-articles/pssh/)

### PlayReady PSSH data schema

Microsoft DRM system. PlayReady init data mixes binary (PSSH data and inner records) and XML (Record header) formats

Binary PlayReady PSSH data is a top-level model. Contains next fields:

| Field name     | Type                   | Description                                         | 
|----------------|------------------------|-----------------------------------------------------|
| Init data size | UInt32 (Little endian) | Data bytes count including 'init data size' 4 bytes |
| Records count  | UIn16 (Little endian)  | PlayReady records count                             |
| Records' data  | Bytes array            | Records' data sequence                              |

Each item in records data sequence contains next fields:

| Field name        | Type                   | Description                                                                  | 
|-------------------|------------------------|------------------------------------------------------------------------------|
| Record type       | UInt16 (Little endian) | Record type key: 1 - Record header, 2 - Reserved, 3 - Embedded License Store |
| Record value size | UIn16 (Little endian)  | Record object size in bytes                                                  |
| Value data        | Bytes array            | Record object data. Contains payload instance raw data record type           |

More details you can find at [Microsoft docs](https://learn.microsoft.com/en-us/playready/specifications/playready-header-specification)

### Widevine PSSH data schema

Widevine PSSH data schema used from [protobuf model](https://github.com/devine-dl/pywidevine)

## Setup

### Swift Package Manager

SwPSSH is available with SPM

```
.package(url: "https://github.com/mIwr/SwPSSH.git", .from(from: "1.1.0"))
```

### CocoaPods

SwPSSH is available with CocoaPods. To install a module, just add to the Podfile:

- iOS
```ruby
platform :ios, '11.0'
...
pod 'SwPSSH'
```

- macOS
```ruby
platform :osx, '10.13'
...
pod 'SwPSSH'
```

- tvOS
```ruby
platform :tvos, '11.0'
...
pod 'SwPSSH'
```

- watchOS
```ruby
platform :watchos, '4.0'
...
pod 'SwPSSH'
```

## Getting started

Main class for work with PSSH box containers is [PSSHBox](./Sources/SwPSSH/Model/PSSHBox.swift).
It provides methods for parsing and serializing general data on box containers.
When you successfully parsed the PSSH box, you can transform init data to Widevine or PlayReady

```swift
import SwPSSH
...
let pssh: PSSHBox? = PSSHBox.from(b64EncodedBox: PSSHBoxEncoded)
let playReadyPayload: PlayReadyPsshData? = pssh?.playReadyPayload//Tries to parse PlayReady PSSH data from raw init data
let wdvPayload: WidevinePsshData? = pssh?.wdvPayload//Tries to parse Widevine PSSH data from raw init data
```
