//
//  BT20BatteryVoltageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation

public extension BT20 {
    
    struct BatteryVoltageNotification: Equatable, Hashable, Codable, Sendable, TopdonSerialMessage {
        
        public static var opcode: TopdonSerialMessageOpcode { .bt20BatteryVoltageNotification }
        
        public let timestamp: UInt32
        
        public let voltage: BatteryVoltage
    }
}

public extension BT20.BatteryVoltageNotification {
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
}

// MARK: - Identifiable

extension BT20.BatteryVoltageNotification: Identifiable {
    
    public var id: UInt32 {
        timestamp
    }
}

// MARK: - Supporting Types

public extension BT20.BatteryVoltageNotification {
    
    struct BatteryVoltage: RawRepresentable, Equatable, Hashable, Codable, Sendable {
                
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

public extension BT20.BatteryVoltageNotification.BatteryVoltage {
    
    var voltage: Float {
        Float(rawValue) / 1000
    }
}

extension BT20.BatteryVoltageNotification.BatteryVoltage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension BT20.BatteryVoltageNotification.BatteryVoltage: CustomStringConvertible {
    
    public var description: String {
        return "\(voltage)V"
    }
}
