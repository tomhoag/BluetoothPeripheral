//
//  ContentView.swift
//  BluetoothPeripheral
//
//  Created by Tom on 6/16/21.
//

import SwiftUI
import CoreBluetooth

struct ContentView: View {
    
    @EnvironmentObject var peripheral:BTPeripheralManager
    
    var body: some View {
        VStack(alignment: .center) {
            Text("BLE Peripheral App")
                .font(.largeTitle)
            Spacer()
            Color(.sRGB, red: peripheral.redValue, green: peripheral.greenValue, blue: peripheral.blueValue, opacity: 1)
                .border(Color.black)
                .frame(width: 300, height: 300, alignment: .center)
                .padding()
            
            Text(String(format: "red: %1.2f green: %1.2f blue: %1.2f", peripheral.redValue, peripheral.greenValue, peripheral.blueValue))
                .font(.system(size: 24))
            Spacer()
        }
        .frame(width: 400, height: 600, alignment: .center)
//        #if targetEnvironment(simulator)
//        #endif
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environmentObject(BTPeripheralManager())
    }
}
