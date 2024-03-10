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
    
    public let voltage: UInt16
}

public extension BatteryVoltageNotification {
    
    var date: Date { Date(timeIntervalSince1970: TimeInterval(timestamp)) }
    
    
}

extension BatteryVoltageNotification {
    
    public var id: UInt32 {
        timestamp
    }
}
