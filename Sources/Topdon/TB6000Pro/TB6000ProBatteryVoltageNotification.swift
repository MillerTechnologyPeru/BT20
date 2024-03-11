//
//  TB6000ProVoltageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation
import Bluetooth
import GATT

public extension TB6000Pro {
    
    struct BatteryVoltageNotification: Equatable, Hashable, Sendable, Codable, BT20Message {
        
        public static var opcode: TopdonSerialMessageOpcode { .tb6000ProBatteryVoltageNotification }
        
        public let timestamp: UInt32
        
        public var watts: Energy {
            Energy(rawValue: UInt32(bigEndian: UInt32(bytes: (0x00, watts0.bigEndian.bytes.0, watts0.bigEndian.bytes.1, watts1))))
        }
        
        internal let watts0: UInt16
        
        internal let watts1: UInt8
        
        public let voltage: Voltage
        
        public let amperage: Amperage
    }
}

public extension TB6000Pro.BatteryVoltageNotification {
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
}

// MARK: - Identifiable

extension TB6000Pro.BatteryVoltageNotification: Identifiable {
    
    public var id: UInt32 {
        timestamp
    }
}

// MARK: - Supporting Types

public extension TB6000Pro.BatteryVoltageNotification {
    
    struct Voltage: RawRepresentable, Equatable, Hashable, Codable, Sendable {
                
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

public extension TB6000Pro.BatteryVoltageNotification.Voltage {
    
    var voltage: Float {
        Float(rawValue) / 1000
    }
}

extension TB6000Pro.BatteryVoltageNotification.Voltage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension TB6000Pro.BatteryVoltageNotification.Voltage: CustomStringConvertible {
    
    public var description: String {
        return "\(voltage)V"
    }
}

public extension TB6000Pro.BatteryVoltageNotification {
    
    struct Energy: RawRepresentable, Equatable, Hashable, Codable, Sendable {
                
        public let rawValue: UInt32
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

public extension TB6000Pro.BatteryVoltageNotification.Energy {
    
    var watts: Float {
        Float(rawValue) / 1_0000
    }
}

extension TB6000Pro.BatteryVoltageNotification.Energy: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

extension TB6000Pro.BatteryVoltageNotification.Energy: CustomStringConvertible {
    
    public var description: String {
        return "\(watts)W"
    }
}

public extension TB6000Pro.BatteryVoltageNotification {
    
    struct Amperage: RawRepresentable, Equatable, Hashable, Codable, Sendable {
                
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

public extension TB6000Pro.BatteryVoltageNotification.Amperage {
    
    var amperage: Float {
        Float(rawValue) / 1000
    }
}

extension TB6000Pro.BatteryVoltageNotification.Amperage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension TB6000Pro.BatteryVoltageNotification.Amperage: CustomStringConvertible {
    
    public var description: String {
        return "\(amperage)A"
    }
}
