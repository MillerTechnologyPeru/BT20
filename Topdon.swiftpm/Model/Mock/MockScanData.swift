//
//  MockScanData.swift
//
//
//  Created by Alsey Coleman Miller on 4/12/23.
//

#if DEBUG
import Foundation
import Bluetooth
import GATT

public typealias MockScanData = ScanData<GATT.Peripheral, MockAdvertisementData>

public extension MockScanData {
    
    static let beacon = MockScanData(
        peripheral: .beacon,
        date: Date(timeIntervalSinceReferenceDate: 10_001),
        rssi: -20,
        advertisementData: .beacon,
        isConnectable: true
    )
    
    static let savantThermostat = MockScanData(
        peripheral: .smartThermostat,
        date: Date(timeIntervalSinceReferenceDate: 10_102),
        rssi: -127,
        advertisementData: .savantThermostat,
        isConnectable: true
    )
    
    static let bt20 = MockScanData(
        peripheral: .bt20,
        date: Date(timeIntervalSinceReferenceDate: 10_103),
        rssi: -127,
        advertisementData: .bt20,
        isConnectable: true
    )
    
    static let tb6000Pro = MockScanData(
        peripheral: .tb6000Pro,
        date: Date(timeIntervalSinceReferenceDate: 10_104),
        rssi: -127,
        advertisementData: .tb6000Pro,
        isConnectable: true
    )
}

public extension MockCentral.Peripheral {
    
    static var random: MockCentral.Peripheral {
        Peripheral(id: BluetoothAddress(bytes: (
            .random(in: .min ... .max),
            .random(in: .min ... .max),
            .random(in: .min ... .max),
            .random(in: .min ... .max),
            .random(in: .min ... .max),
            .random(in: .min ... .max)))
        )
    }
    
    static var beacon: Peripheral {
        Peripheral(id: BluetoothAddress(rawValue: "00:AA:AB:03:10:01")!)
    }
    
    static var smartThermostat: Peripheral {
        Peripheral(id: BluetoothAddress(rawValue: "00:1A:7D:DA:71:13")!)
    }
    
    static var bt20: Peripheral {
        Peripheral(id: BluetoothAddress(rawValue: "78:5E:E8:91:80:14")!)
    }
    
    static var tb6000Pro: Peripheral {
        Peripheral(id: BluetoothAddress(rawValue: "78:5E:E8:90:5A:42")!)
    }
}

public extension MockCentral.Peripheral.ID {
    
    static var random: MockCentral.Peripheral.ID {
        return MockCentral.Peripheral.random.id
    }
}

#endif
