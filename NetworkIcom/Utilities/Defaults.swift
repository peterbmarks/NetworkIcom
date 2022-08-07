//
//  Defaults.swift
//  NetworkIcom
//
//  Created by Mark Erbaugh on 4/20/22.
//

import Foundation

struct Defaults {
    // ConnectionInfo
    static let radioAddr = "IC-705.local"
    static let controlPort = UInt16(50001)
    static let serialPort = UInt16(50002)
    static let audioPort = UInt16(50003)
    static let user = "admin"
    static let password = "password"
    static let computer = "MAC-MINI"
    static let raiodCIV = UInt8(0x98)
    static let hostCIV = UInt8(0xe0)

    // RxAudio
    static let rxRate: UInt16 = 48000
    static let rxChannels: UInt8 = 1
    static let rxSize: UInt8 = 2
    static let rxULaw: Bool = false
    static let rxEnable: Bool = true
    
    // TxAudio
    static let txRate: UInt16 = 8000
    static let txSize: UInt8 = 1
    static let txULaw: Bool = false
    static let txEnable: Bool = true
}

