//
//  MainView.swift
//  NetworkIcom
//
//  Created by Mark Erbaugh on 2/8/22.
//

import SwiftUI

let kWaterfallWidth = 475   // set for IC-705
let kWaterfallWidthFloat = CGFloat(kWaterfallWidth)

struct MainView: View {
        
    @ObservedObject var civDecode: CIVDecode
    @ObservedObject var icomVM: IcomVM
    
    init() {
        let civDecode = CIVDecode(hostCivAddr: 0xe0)
        
        let icomVM = IcomVM(mConnectionInfo: ConnectionInfo(),
                            mRxAudio: RxAudio(),
                            mTxAudio: TxAudio(),
                            mCivDecode: civDecode.decode)
        
        self.civDecode = civDecode
        self.icomVM = icomVM
    }
    
    @State var state = false
    @State var state2 = false
    @State var counter = ""
    @State var counter2 = ""
    @State var editingFrequency = false
    @State private var frequencyString: String = ""
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    VStack {
                        Text("\(String(format: "%0.4f", Double(civDecode.frequency) / 1_000_000)) MHz")
                        .font(.largeTitle)
                        .onTapGesture {
                            print("Ask for frequency")
                            editingFrequency = true
                        }
                        Text(civDecode.modeFilter.description)
                        Text("Attenuator: \(civDecode.attenuation.description)")
                        Text("Underrun: \(icomVM.underrunCount)")
                        Text("Overrun: \(icomVM.overrunCount)")
                    }
                    VStack {
                        HStack {
                            Button("-10k") {
                                self.tune(deltaHz: -10000)
                            }
                            Button("-1k") {
                                self.tune(deltaHz: -1000)
                            }
                            Button("-100") {
                                self.tune(deltaHz: -100)
                            }
                            
                            Button("+100") {
                                self.tune(deltaHz: +100)
                            }
                            Button("+1k") {
                                self.tune(deltaHz: +1000)
                            }
                            Button("+10k") {
                                self.tune(deltaHz: +10000)
                            }
                        }
                    }
                }
                VStack {
                    Button("80m") {
                        tuneHz(hz: 3600000)
                    }
                    Button("40m") {
                        tuneHz(hz: 7100000)
                    }
                    Button("20m") {
                        tuneHz(hz: 14100000)
                    }
                    Button("10m") {
                        tuneHz(hz: 28100000)
                    }
                }
                VStack {
                    Button("LSB") {
                        icomVM.setOperatingMode(mode: .lsb, filter: .fil1)
                        civDecode.modeFilter = ModeFilter(mode: .lsb, filter: .fil1)
                    }
                    Button("USB") {
                        icomVM.setOperatingMode(mode: .usb, filter: .fil1)
                        civDecode.modeFilter = ModeFilter(mode: .usb, filter: .fil1)
                    }
                    Button("AM") {
                        icomVM.setOperatingMode(mode: .am, filter: .fil1)
                        civDecode.modeFilter = ModeFilter(mode: .am, filter: .fil1)
                    }
                    
                }
            }
            VStack {
                if #available(macOS 13.0, *) {
                    BandscopeView(data: (civDecode.panadapterMain.panadapter, civDecode.panadapterMain.history))
                        .frame(width: kWaterfallWidthFloat, height: 200)
                        .onTapGesture { cgPoint in
                            let newX = cgPoint.x
                            clickToTune(newX)
                        }
                } else {
                    // Fallback on earlier versions
                    BandscopeView(data: (civDecode.panadapterMain.panadapter, civDecode.panadapterMain.history))
                        .frame(width: kWaterfallWidthFloat, height: 200)
                        .gesture(
                                    DragGesture(minimumDistance: 0, coordinateSpace: .global)
                                        .onChanged { value in
                                            print("got drag")
                                            let newX = value.location.x
                                            clickToTune(newX)
                                        }
                                        
                                )
                }
                HStack {
                    Text("\(String(format: "%0.4f", Double(civDecode.panadapterMain.panLower) / 1_000_000)) MHz")
                        .font(.footnote)
                    Spacer()
                    Text("\(String(format: "%0.4f", Double(civDecode.panadapterMain.panUpper) / 1_000_000)) MHz")
                        .font(.footnote)
                }
                if #available(macOS 13.0, *) {
                    Image(decorative: civDecode.waterfallContexts[0].makeImage()!, scale: 1.0)
                        .frame(width: kWaterfallWidthFloat, height: 100)
                        .background(BGGrid().stroke(.gray, lineWidth: 1.0))
                        .onTapGesture { cgPoint in
                            let newX = cgPoint.x
                            clickToTune(newX)
                        }
                } else {
                    Image(decorative: civDecode.waterfallContexts[0].makeImage()!, scale: 1.0)
                        .frame(width: kWaterfallWidthFloat, height: 100)
                        .background(BGGrid().stroke(.gray, lineWidth: 1.0))
                }
            }
            VStack {
                Button(icomVM.connected ? "Disconnect" : "Connect") {
                    if icomVM.connected {
                        icomVM.disconnectControl()
                    } else {
                        icomVM.connectControl()
                    }
                }
                VStack {
                    HStack {
                        Text("Control State: \(icomVM.controlState)")
                        if icomVM.connected {
                            Text("Latency: \(String(format: "%0.2f", icomVM.controlLatency)) msec")
                        }
                    }
                    Text("Serial State: \(icomVM.serialState)")
                    Text("Audio State: \(icomVM.audioState)")
                }
                .font(.footnote)

            }
        }
        .frame(width: kWaterfallWidthFloat)
        .padding()
    }
    
    func updateFrequency() {
        self.frequencyString = "\(civDecode.frequency)"
    }
    
    fileprivate func clickToTune(_ newX: CGFloat) {
        let xRangeFraction = newX / kWaterfallWidthFloat
        let highF = civDecode.panadapterMain.panUpper
        let lowF = civDecode.panadapterMain.panLower
        let frequencyRange = highF - lowF
        let newFrequency = Int((CGFloat(frequencyRange) * xRangeFraction) + CGFloat(lowF))
        print("newFrequency = \(newFrequency)")
        self.tuneHz(hz: newFrequency)
    }
    
    func tune(deltaHz: Int) {
        var operatingFrequency = civDecode.frequency
        operatingFrequency += deltaHz
        tuneHz(hz: operatingFrequency)
    }
    
    func tuneHz(hz: Int) {
        icomVM.setOperatingFrequency(frequency: hz)
        // assume it worked
        civDecode.frequency = hz
        print("Tuning to: \(hz)")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
