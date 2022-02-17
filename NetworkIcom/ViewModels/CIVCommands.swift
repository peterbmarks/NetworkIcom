//
//  CIVCommands.swift
//  NetworkIcom
//
//  Created by Mark Erbaugh on 2/15/22.
//

import Foundation

extension IcomVM {
    // +/-
    enum ΔFrequencySpan: UInt8 {
        case kHz5 = 0xa1
        case kHz10
        case kHz20
        case kHz50
        case kHz100
        case kHz500
        case mHz
    }
    
    enum TuneStep: UInt8 {
        case off = 0
        case hz100
        case kHz
        case kHz5
        case kHz9
        case kHz10
        case kHz12_5
        case kHz20
        case kHz25
    }
    
    enum Speech: UInt8 {
        case all  = 0
        case frequency
        case mode
    }
    
    enum Level0x14: UInt8 {
        case afGain = 1
        case rfGain
        case squelch
        case apf = 5
        case nr
        case pbtInner
        case pbtOuter
        case cwPitch
        case rfPower
        case micGain
        case keySpeed
        case notch
        case comp
        case breakInDelay
        case nb = 0x12
        case digSel
        case driveGain
        case monitor
        case voxGain
        case antiVox
        case backlight = 0x19
    }
    
    enum Meter: UInt8 {
        case sMeterSquelch = 1
        case sMeter
        case toneSquelch = 5
        case overflow = 7
        case po = 0x11
        case swr
        case alc
        case comp
        case voltage
        case current
    }
    
    func readBandEdgeFrequencies() {
        serial?.send(command: 0x02)
    }
    
    func readOperatingFrequency() {
        serial?.send(command: 0x03)
    }
    func readOperatingMode() {
        serial?.send(command: 0x04)
    }
    
    func setOperatingFrequency(frequency: Int) {
        serial?.send(command: 0x05, data: frequency.frequencyBuffer)
    }
    
    func setOperatingMode(mode: Mode, filter: Filter) {
        serial?.send(command: 0x06, data: ModeFilter(mode: mode, filter: filter).buffer)
    }
    
    func exchangeMainSub() {
        serial?.send(command: 0x07, subCommand: 0xb0)
    }
    
    func equalizeMainSub() {
        serial?.send(command: 0x07, subCommand: 0xb1)
    }
    
    func dualWatch(on: Bool? = nil) {
        serial?.send(command: 0x07, subCommand: 0xc2, data: on?.data)
    }
    
    func subBand(on: Bool? = nil) {
        serial?.send(command: 0x07, subCommand: 0xd2, data: on?.data)
    }
    
    // 1 .. 99, 100 (P1), 101 (P2)
    func selectMemory(channel: UInt8) {
        serial?.send(command: 0x08, data: channel.buffer2)
    }
    
    func memoryWrite() {
        serial?.send(command: 0x09)
    }
    
    func memoryToVFO() {
        serial?.send(command: 0x0a)
    }
    
    func memoryClear() {
        serial?.send(command: 0x0b)
    }
    
    func cancelScan() {
        serial?.send(command: 0x0e, subCommand: 0x00)
    }
    
    func startPgmMemoryScan() {
        serial?.send(command: 0x0e, subCommand: 0x01)
    }

    func startProgramScan() {
        serial?.send(command: 0x0e, subCommand: 0x02)
    }
    
    func startΔFrequencyScan() {
        serial?.send(command: 0x0e, subCommand: 0x03)
    }
    
    func startFineProgramScan() {
        serial?.send(command: 0x0e, subCommand: 0x12)
    }
    
    func startFineΔFrequencyScan() {
        serial?.send(command: 0x0e, subCommand: 0x13)
    }

    func startMemoryScan() {
        serial?.send(command: 0x0e, subCommand: 0x22)
    }

    func startSelectMemoryScan() {
        serial?.send(command: 0x0e, subCommand: 0x23)
    }
    
    func selectΔFrequencySpan(span: ΔFrequencySpan) {
        serial?.send(command: 0x0e, subCommand: span.rawValue)
    }
    
    func clearSelectChannel() {
        serial?.send(command: 0x0e, subCommand: 0xb0)
    }
    
    // channel: 1, 2, 3
    func setAsSelectChannel(channel: UInt8? = nil) {
        serial?.send(command: 0x0e, subCommand: 0xb1, data: channel?.data)
    }
    
    // channel: 0 (all), 1, 2, 3
    func setSelectMemoryChannel(channel: UInt8? = nil) {
        serial?.send(command: 0x0e, subCommand: 0xb2, data: channel?.data)
    }
    
    func setScanResume(off: Bool) {
        serial?.send(command: 0x0e, subCommand: off ? 0xd0 : 0xd3)
    }
    
    func readSetSplit(on: Bool? = nil) {
        serial?.send(command: 0x0f, data: on?.data)
    }
    
    func readSetTuneStep(step: TuneStep? = nil) {
        serial?.send(command: 0x10, data: step?.rawValue.data)
    }
    
    func readSetAttenuation(attn: Attenuation? = nil) {
        serial?.send(command: 0x11, data: attn?.rawValue.data)
    }
    
    func readSetRxAnt(ant2: Bool? = nil, rxOn: Bool? = nil) {
        serial?.send(command: 0x12, subCommand: ant2?.data.uint8, data: rxOn?.data)
    }
    
    func speak(speech: Speech) {
        serial?.send(command: 0x13, subCommand: speech.rawValue)
    }
    
    func readSetLevel0x14(which: Level0x14, value: UInt8? = nil) {
        serial?.send(command: 0x14, subCommand: which.rawValue, data: value?.buffer2)
    }
    
    func readMeter(which: Meter) {
        serial?.send(command: 0x15, subCommand: which.rawValue)
    }
    
    // 0, 1, 2
    func readSetPreamp(which: UInt8? = nil) {
        serial?.send(command: 0x16, subCommand: 0x02, data: which?.data)
    }
    
    // 1, 2, 3
    func readSetAGC(which: UInt8? = nil) {
        serial?.send(command: 0x16, subCommand: 0x12, data: which?.data)
    }
    
    func readSsbRxHpfLpf()        { serial?.send(command: 0x1a, subCommand: 0x05, selector: 0x01) }
}
