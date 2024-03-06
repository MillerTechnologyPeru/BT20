//
//  BT20.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Bluetooth
import GATT

public struct BT20 {
    
    struct Advertisement: Equatable, Hashable, Sendable {
        
        public static var name: String { "BT20" }
        
        public static var services: [BluetoothUUID] {
            [
                .humanInterfaceDevice,
                .batteryService
            ]
        }
        
        public let address: BluetoothAddress
    }
}

extension BT20.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        guard let localName = advertisement.localName,
              Self.name == localName, 
              let serviceUUIDs = advertisement.serviceUUIDs,
              serviceUUIDs.count == 5, serviceUUIDs.suffix(2) == Self.services else {
            return nil
        }
        let macBytes = serviceUUIDs.prefix(3).compactMap {
            switch $0 {
            case let .bit16(value):
                return value
            default:
                return nil
            }
        }
        guard macBytes.count == 3 else {
            return nil
        }
        self.address = BluetoothAddress(
            bigEndian:
                BluetoothAddress(
                    bytes: (
                        macBytes[0].littleEndian.bytes.0,
                        macBytes[0].littleEndian.bytes.1,
                        macBytes[1].littleEndian.bytes.0,
                        macBytes[1].littleEndian.bytes.1,
                        macBytes[2].littleEndian.bytes.0,
                        macBytes[2].littleEndian.bytes.1
                    )
                )
        )
    }
}

public extension BT20 {
    
    struct BatteryVoltageNotification: Equatable, Hashable, Sendable {
        
        let timestamp: UInt16
        
        let voltage: UInt16
        
        init?(data: Data) {
            guard data.count >= 17, Data(data.prefix(11)) == BT20.Notification.batteryVoltagePrefix.data else {
                return nil
            }
            let suffix = Data(data.suffix(from: 12))
            self.timestamp = 0
            self.voltage = 0
        }
    }
}

internal extension BT20 {
    
    enum Command: String, DataConstant {
        
        case version = "55AA0007FFF8DD09D4"
        
        case loggingIntervalSecond = "55AA0009FFF6DD0B003CEA"
        
        case loggingIntervalMinute = "55AA0009FFF6DD0B0001D7"
        
        case loggingIntervalDay = "55AA0009FFF6DD0B0E10C8"
    }
    
    enum Notification: String, DataConstant {
        
        // Ackowledgement
        case confirmation = "55AA0008FFF7DD0B00D6"
        
        case batteryVoltagePrefix = "55AA000FFFF0DD0365E8"
        
        
    }
}

protocol DataConstant: RawRepresentable where RawValue == String { }

extension DataConstant {
    
    var data: Data {
        guard let data = Data(hexadecimal: rawValue) else {
            assertionFailure()
            return Data()
        }
        return data
    }
}
