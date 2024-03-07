//
//  BluetoothUUID.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Bluetooth

public extension BluetoothUUID {
    
    static var topdonService: BluetoothUUID {
        BluetoothUUID(rawValue: "00010203-0405-0607-0809-0A0B0C0D1910")!
    }
    
    static var topdonNotificationCharacteristic: BluetoothUUID {
        BluetoothUUID(rawValue: "00010203-0405-0607-0809-0A0B0C0D2B10")!
    }
    
    static var topdonCommandCharacteristic: BluetoothUUID {
        BluetoothUUID(rawValue: "00010203-0405-0607-0809-0A0B0C0D2B11")!
    }
}
