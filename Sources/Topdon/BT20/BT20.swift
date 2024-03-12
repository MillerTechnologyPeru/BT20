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

/// Topdon BT20 Battery Monitor
public struct BT20: Equatable, Hashable, Sendable {
    
    public static var type: TopdonAccessoryType { .bt20 }
    
    public static var name: String { type.rawValue }
    
    public static var services: Set<BluetoothUUID> {
        [
            .humanInterfaceDevice,
            .batteryService
        ]
    }
    
    public let address: BluetoothAddress
}

// MARK: - Identifiable

extension BT20: Identifiable {
    
    public var id: BluetoothAddress {
        address
    }
}

// MARK: - Advertisement

public extension BT20 {
    
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

