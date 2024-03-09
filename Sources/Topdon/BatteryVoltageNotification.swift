//
//  BatteryVoltageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation

public struct BatteryVoltageNotification: Equatable, Hashable, Codable, Sendable {
    
    public let timestamp: UInt16
    
    public let voltage: UInt16
    
    public init?(data: Data) {
        guard data.count >= 17 else {
            return nil
        }
        self.timestamp = UInt16(bigEndian: UInt16(bytes: (data[10], data[11])))
        self.voltage = UInt16(bigEndian: UInt16(bytes: (data[12], data[13])))
    }
}
