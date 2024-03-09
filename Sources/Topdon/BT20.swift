//
//  BT20.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Bluetooth
import GATT
import Telink

public enum BT20 {
    
    public struct Advertisement: Equatable, Hashable, Sendable {
        
        public static var name: String { "BT20" }
        
        public static var services: Set<BluetoothUUID> {
            [
                .humanInterfaceDevice,
                .batteryService
            ]
        }
        
        public let address: BluetoothAddress
    }
}

extension BT20.Advertisement: Identifiable {
    
    public var id: BluetoothAddress {
        address
    }
}

extension BT20.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        guard let localName = advertisement.localName,
              Self.name == localName else {
            return nil
        }
        guard let serviceUUIDs = advertisement.serviceUUIDs,
              serviceUUIDs.count == 5 else {
            return nil
        }
        let macBytes = serviceUUIDs
            .filter { Self.services.contains($0) == false }
            .compactMap {
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
    
    struct Command: Equatable, Hashable, Codable, Sendable, Telink.SerialPortProtocolCommand {
        
        public static var type: SerialPortProtocolType { .topdonBM2 }
        
        public let opcode: TopdonSerialMessageOpcode
        
        public let payload: Data
    }
    
    struct Event: Equatable, Hashable, Codable, Sendable, Telink.SerialPortProtocolEvent {
        
        public static var type: SerialPortProtocolType { .topdonBM2 }
        
        public let opcode: TopdonSerialMessageOpcode
        
        public let payload: Data
    }
}
/*
public extension BT20 {
    
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

public protocol DataConstant: RawRepresentable where RawValue == String { }

public extension DataConstant {
    
    var data: Data {
        guard let data = Data(hexadecimal: rawValue) else {
            assertionFailure()
            return Data()
        }
        return data
    }
}
*/
