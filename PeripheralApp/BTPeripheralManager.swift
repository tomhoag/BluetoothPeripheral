//
//  BTPeripheral.swift
//  BluetoothPeripheral
//
//  Created by Tom on 6/16/21.
//

import Foundation
import SwiftUI
import CoreBluetooth

public class BTPeripheralManager: NSObject, ObservableObject, CBPeripheralManagerDelegate {
    
    public static let serviceUUID = CBUUID.init(string: "b4250400-fb4b-4746-b2b0-93f0e61122c5")
    public static let redCharacteristicUUID   = CBUUID.init(string: "b4250401-fb4b-4746-b2b0-93f0e61122c6")
    public static let greenCharacteristicUUID = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c7")
    public static let blueCharacteristicUUID = CBUUID.init(string: "b4250402-fb4b-4746-b2b0-93f0e61122c8")
    
    @Published var statusMessage:String = ""
    @Published var peripheralState:String = ""
    
    @Published var redValue:Double = 1.0
    @Published var greenValue:Double = 0.5
    @Published var blueValue:Double = 0.5
    
    private var peripheralManager:CBPeripheralManager!
    
    public override init() {
        super.init()
        
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        switch peripheral.state {
        
        case .unknown:
            peripheralState = "device is unknown"
        case .resetting:
            peripheralState = "device is resetting"
        case .unsupported:
            peripheralState = "device is unsupported"
        case .unauthorized:
            peripheralState = "device is unauthorized"
        case .poweredOff:
            peripheralState = "device is powerd off"
        case .poweredOn:
            peripheralState = "device is powered on"
            addServices()
        @unknown default:
            print("BT device in unknown state")
            peripheralState = "device is unknown"
        }
        
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        statusMessage = "Data was written"
        
        for request in requests {
            if let value = request.value {
                if let double = value.to(type: Double.self) {
                    let key = request.characteristic
                    
                    switch key.uuid {
                    
                    case BTPeripheralManager.redCharacteristicUUID:
                        redValue = double
                    case BTPeripheralManager.greenCharacteristicUUID:
                        greenValue = double
                    case BTPeripheralManager.blueCharacteristicUUID:
                        blueValue = double
                    default:
                        print("PM: unknown char uuid")
                    }
                } else {
                    print("PM: could not create dbl from data")
                }
            } else {
                print("PM: could not create value from request")
            }
        }
    }
    
    public func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        statusMessage = "Data was read"
        
        switch request.characteristic.uuid {
        
        case BTPeripheralManager.redCharacteristicUUID:
            request.value = Data(from:redValue)
            peripheral.respond(to: request, withResult: .success)
            
        case BTPeripheralManager.greenCharacteristicUUID:
            request.value = Data(from:greenValue)
            peripheral.respond(to: request, withResult: .success)
            
        case BTPeripheralManager.blueCharacteristicUUID:
            request.value = Data(from:blueValue)
            peripheral.respond(to: request, withResult: .success)
            
        default:
            print("unknown char uuid")
            peripheral.respond(to: request, withResult: .attributeNotFound)
        }
    }
        
    func addServices() {
    
        let redCharacteristic = CBMutableCharacteristic(type: BTPeripheralManager.redCharacteristicUUID, properties: [.notify, .write, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        let greenCharacteristic = CBMutableCharacteristic(type: BTPeripheralManager.greenCharacteristicUUID, properties: [.notify, .write, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        let blueCharacteristic = CBMutableCharacteristic(type: BTPeripheralManager.blueCharacteristicUUID, properties: [.notify, .write, .read, .writeWithoutResponse], value: nil, permissions: [.readable, .writeable])
        
        
        let service = CBMutableService(type: BTPeripheralManager.serviceUUID, primary: true)
        
        service.characteristics = [redCharacteristic, greenCharacteristic, blueCharacteristic]
        
        peripheralManager.add(service)
        
        startAdvertising()
    }
    
    private func startAdvertising() {
        statusMessage = "Advertising Data"
        
        peripheralManager.startAdvertising([CBAdvertisementDataLocalNameKey: "BLEPeripheralApp", CBAdvertisementDataServiceUUIDsKey: [BTPeripheralManager.serviceUUID] ])
        
    }
}


extension Data {
    
    struct HexEncodeingOptions: OptionSet {
        let rawValue:Int
        static let upperCase = HexEncodeingOptions(rawValue: 1 << 0)
    }
    
    func hexEncodedString(options: HexEncodeingOptions = []) -> String {
        let format = options.contains(.upperCase) ? "%02hhX" : "%02hhx"
        return map { String(format: format, $0) }.joined()
    }
    
    init<T>(from value: T) {
        self = Swift.withUnsafeBytes(of: value) { Data($0) }
    }
    
    func to<T>(type: T.Type) -> T? where T: ExpressibleByIntegerLiteral {
        var value: T = 0
        guard count >= MemoryLayout.size(ofValue: value) else { return nil }
        _ = Swift.withUnsafeMutableBytes(of: &value, { copyBytes(to: $0)} )
        return value
    }
    
}
