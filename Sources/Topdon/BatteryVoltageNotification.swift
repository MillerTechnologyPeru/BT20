//
//  BatteryVoltageNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/7/24.
//

import Foundation

public struct BatteryVoltageNotification: Equatable, Hashable, Codable, Sendable {
    
    public static var opcode: TopdonSerialMessageOpcode { .batteryVoltageNotification }
    
    public let timestamp: UInt32
    
    public let voltage: UInt16
}
