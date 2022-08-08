//
//  MainView.swift
//  NetworkIcom
//
//  Created by Mark Erbaugh on 2/8/22.
//

import SwiftUI

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
    
    var body: some View {
        VStack {
            VStack {
//                Text("Control")
//                    .font(.title)
                // Text("Retransmit Count: \(icomVM.controlRetransmitCount)")
                // Text("CI-V Addr: \(String(format: "0x%02x", icomVM.radioCivAddr))")
            }
//            Divider()
            HStack {
                VStack {
                    VStack {
    //                    Text("Serial")
    //                        .font(.title)
                        // Text("State: \(icomVM.serialState)")
                        // Text("Latency: \(icomVM.serialLatency)")
                        // Text("Retransmit Count: \(icomVM.serialRetransmitCount)")
                        Text("\(String(format: "%0.4f", Double(civDecode.frequency) / 1_000_000)) MHz")
                            .font(.largeTitle)
    //                        .onTapGesture {
    //                            civDecode.frequency = 0
    //                        }
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
            }
            VStack {
//                Text("Pan Timing: \(civDecode.panadapterMain.2)")
                BandscopeView(data: (civDecode.panadapterMain.panadapter, civDecode.panadapterMain.history))
                    .frame(width: 475, height: 200)
                HStack {
                    Text("\(String(format: "%0.4f", Double(civDecode.panadapterMain.panLower) / 1_000_000)) MHz")
                        .font(.footnote)
                    Spacer()
                    Text("\(String(format: "%0.4f", Double(civDecode.panadapterMain.panUpper) / 1_000_000)) MHz")
                        .font(.footnote)
                }
                Image(decorative: civDecode.waterfallContexts[0].makeImage()!, scale: 1.0)
                    .frame(width: 475, height: 100)
                    .background(BGGrid().stroke(.gray, lineWidth: 1.0))
                
//                Text("Pan Timing: \(civDecode.panadapterSub.2)")
//                BandscopeView(data: (civDecode.panadapterSub.0, civDecode.panadapterSub.1))
//                    .frame(width: 694, height: 200)
//                Image(decorative: civDecode.waterfallContexts[1].makeImage()!, scale: 1.0)
//                    .frame(width: 689, height: 100)
            }
            VStack {
                Button(icomVM.connected ? "Disconnect" : "Connect") {
                    if icomVM.connected {
                        icomVM.disconnectControl()
                    } else {
                        icomVM.connectControl()
                    }
                }
//                Button("Audio Info") {
//                    print(Audio.getOutputDevices())
//                    print(Audio.getInputDevices())
//                }
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
        .frame(width: 475)
        .padding()
    }
    
    func tune(deltaHz: Int) {
        var operatingFrequency = civDecode.frequency
        operatingFrequency += deltaHz
        icomVM.setOperatingFrequency(frequency: operatingFrequency)
        // assume it worked
        civDecode.frequency = operatingFrequency
        print("Tuning to: \(operatingFrequency)")
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
