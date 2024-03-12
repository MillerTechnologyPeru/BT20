//
//  BluetoothUUID.swift
//
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation
import Bluetooth

public extension BluetoothUUID {
    
    static var tb6000ProService: BluetoothUUID {
        .bit16(0xFEE7)
    }
    
    static var tb6000ProCharacteristic1: BluetoothUUID {
        .bit16(0xFEC1)
    }
    
    static var tb6000ProCharacteristic2: BluetoothUUID {
        .bit16(0xFF00)
    }
}
