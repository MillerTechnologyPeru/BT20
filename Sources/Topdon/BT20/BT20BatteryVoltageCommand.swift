//
//  BT20BatteryVoltageCommand.swift
//
//
//  Created by Alsey Coleman Miller on 3/10/24.
//

import Foundation

public extension BT20 {
    
    struct BatteryVoltageCommand: Equatable, Hashable, Codable, Sendable, TopdonSerialMessage {
        
        public static var opcode: TopdonSerialMessageOpcode { .bt20BatteryVoltageCommand }

        internal let value0: UInt16
        
        internal let value1: UInt16
        
        internal let value2: UInt16
        
        internal let value3: UInt8
        
        public init() {
            self.value0 = 0x65EC
            self.value1 = 0x36A7
            self.value2 = 0x0001
            self.value3 = 0xC6
        }
    }
}
