//
//  MacPeripheralAppApp.swift
//  MacPeripheralApp
//
//  Created by Tom on 6/18/21.
//

import SwiftUI

@main
struct MacPeripheralAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(BTPeripheralManager())
        }
    }
}
