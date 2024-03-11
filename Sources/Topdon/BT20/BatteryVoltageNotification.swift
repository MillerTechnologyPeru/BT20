//
//  BatteryVoltageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation

public struct BatteryVoltageNotification: Equatable, Hashable, Codable, Sendable, BT20Message {
    
    public static var opcode: TopdonSerialMessageOpcode { .batteryVoltageNotification }
    
    public let timestamp: UInt32
    
    public let voltage: BatteryVoltage
}

public extension BatteryVoltageNotification {
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
}

extension BatteryVoltageNotification: Identifiable {
    
    public var id: UInt32 {
        timestamp
    }
}

public extension BatteryVoltageNotification {
    
    struct BatteryVoltage: RawRepresentable, Equatable, Hashable, Codable, Sendable {
                
        public let rawValue: UInt16
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
}

public extension BatteryVoltageNotification.BatteryVoltage {
    
    var voltage: Float {
        Float(rawValue) / 1000
    }
}

extension BatteryVoltageNotification.BatteryVoltage: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt16) {
        self.init(rawValue: value)
    }
}

extension BatteryVoltageNotification.BatteryVoltage: CustomStringConvertible {
    
    public var description: String {
        return "\(voltage)V"
    }
}
