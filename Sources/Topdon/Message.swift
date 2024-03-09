//
//  Message.swift
//
//
//  Created by Alsey Coleman Miller on 3/8/24.
//

import Foundation

/// Topdon Serial Message Opcode
public struct TopdonSerialMessageOpcode: Equatable, Hashable, Codable, Sendable {
    
    public let rawValue: UInt32
    
    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }
}

// MARK: - ExpressibleByIntegerLiteral

extension TopdonSerialMessageOpcode: ExpressibleByIntegerLiteral {
    
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

// MARK: - CustomStringConvertible

extension TopdonSerialMessageOpcode: CustomStringConvertible {
    
    public var description: String {
        "0x" + rawValue.toHexadecimal()
    }
}

// MARK: - Constants

public extension TopdonSerialMessageOpcode {
    
    static var batteryVoltageNotification: TopdonSerialMessageOpcode { 0xFFF0DD03 }
    
    static var loggingIntervalCommand: TopdonSerialMessageOpcode { 0xFFF6DD0B }
    
    //static var confirmation: TopdonSerialMessageOpcode { 0xFFF7 }
    
    static var versionCommand: TopdonSerialMessageOpcode { 0xFFF8DD09 }
    
    
}
