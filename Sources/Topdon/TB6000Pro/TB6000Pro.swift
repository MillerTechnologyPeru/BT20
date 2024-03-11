//
//  TB6000Pro.swift
//
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation
import Bluetooth
import GATT

/// Topdon TB6000Pro Battery Charger
public struct TB6000Pro: Equatable, Hashable, Sendable {
    
    public static var type: TopdonAccessoryType { .tb6000Pro }
    
    public static var name: String { type.rawValue }
    
    public let address: BluetoothAddress
}

// MARK: - Identifiable

extension TB6000Pro: Identifiable {
    
    public var id: BluetoothAddress {
        address
    }
}

// MARK: - Advertisement

public extension TB6000Pro {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        guard let localName = advertisement.localName,
              Self.name == localName else {
            return nil
        }
        guard let manufacturerData = advertisement.manufacturerData,
              manufacturerData.companyIdentifier == .topdon, 
              manufacturerData.additionalData.count == 6 else {
            return nil
        }
        self.address = BluetoothAddress(
            bigEndian:
                BluetoothAddress(
                    bytes: (
                        manufacturerData.additionalData[0],
                        manufacturerData.additionalData[1],
                        manufacturerData.additionalData[2],
                        manufacturerData.additionalData[3],
                        manufacturerData.additionalData[4],
                        manufacturerData.additionalData[5]
                    )
                )
        )
    }
}
