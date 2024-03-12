//
//  TB6000ProQuickChargeCommand.swift
//  
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation

public extension TB6000Pro {
    
    struct QuickChargeCommand: Equatable, Hashable, Codable, Sendable, TopdonSerialMessage {
        
        public static var opcode: TopdonSerialMessageOpcode { .tb6000ProQuickChargeCommand }
        
        internal let value0: UInt8
        
        public init() {
            self.value0 = 0xAE
        }
    }
}
