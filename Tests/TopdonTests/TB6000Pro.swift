//
//  TB6000Pro.swift
//
//
//  Created by Alsey Coleman Miller on 3/11/24.
//

import Foundation
import XCTest
import Bluetooth
#if canImport(BluetoothGAP)
import BluetoothGAP
#endif
import GATT
import Telink
@testable import Topdon

final class TB6000ProTests: XCTestCase {
    
    #if canImport(BluetoothGAP)
    func testAdvertisement() throws {
        
        /*
           HCI Event        0x0000  78:5E:E8:90:5A:42  LE - Ext ADV - 1 Report - Normal - Public - 78:5E:E8:90:5A:42  -86 dBm - TB6000Pro - Manufacturer Specific Data - Channel 38
             Parameter Length: 50 (0x32)
             Num Reports: 0X01
             Report 0
                 Event Type: Connectable Advertising - Scannable Advertising - Legacy Advertising PDUs Used - Complete -
                 Address Type: Public
                 Peer Address: 78:5E:E8:90:5A:42
                 Primary PHY: 1M
                 Secondary PHY: No Packets
                 Advertising SID: Unavailable
                 Tx Power: Unavailable
                 RSSI: -86 dBm
                 Periodic Advertising Interval: 0.000000ms (0x0)
                 Direct Address Type: Public
                 Direct Address: 00:00:00:00:00:00
                 Data Length: 24
                 Flags: 0x6
                     LE Limited General Discoverable Mode
                     BR/EDR Not Supported
                 Local Name (Incomplete): TB6000Pro
                 Data: 02 01 06 0A 08 54 42 36 30 30 30 50 72 6F 09 FF 56 00 78 5E E8 90 5A 42
         */
        
        let advertisementData: LowEnergyAdvertisingData = [0x02, 0x01, 0x06, 0x0A, 0x08, 0x54, 0x42, 0x36, 0x30, 0x30, 0x30, 0x50, 0x72, 0x6F, 0x09, 0xFF, 0x56, 0x00, 0x78, 0x5E, 0xE8, 0x90, 0x5A, 0x42]
        
        XCTAssertEqual(advertisementData.localName, "TB6000Pro")
        XCTAssertNil(advertisementData.serviceUUIDs)
        XCTAssertEqual(advertisementData.manufacturerData, GATT.ManufacturerSpecificData(data: Data([0x56, 0x00, 0x78, 0x5E, 0xE8, 0x90, 0x5A, 0x42])))
        //XCTAssertEqual(advertisementData.address.rawValue, "78:5E:E8:90:5A:42")
    }
    #endif
    
    func testVoltageCommand() throws {
        
        let data = Data(hexadecimal: "55AA000DFFF2DD0265EC36A70001C6")!
        
        let message = try SerialPortProtocolMessage(
            command: BT20.Command(
                BatteryVoltageCommand()
            )
        )
        let encodedData = try message.encode()
        XCTAssertEqual(data, encodedData)
    }
    
    func testVoltageNotification() throws {
        
        do {
            let data = Data([0x55, 0xAA, 0x00, 0x0F, 0xFF, 0xF0, 0xDD, 0x03, 0x65, 0xE8, 0x32, 0xAC, 0x30, 0xE6, 0x00, 0x00, 0x1B])
            
            let message = try SerialPortProtocolMessage(from: data)
            let event = try BT20.Event(from: message)
            let notification = try event.decode(BatteryVoltageNotification.self)
            
            XCTAssertEqual(notification.date.description, "2024-03-06 09:09:00 +0000")
            XCTAssertEqual(notification.voltage.rawValue, 12518)
            XCTAssertEqual(notification.voltage.voltage, 12.518)
        }
        
        do {
            let data = Data([0x55, 0xAA, 0x00, 0x0F, 0xFF, 0xF0, 0xDD, 0x03, 0x65, 0xEC, 0x36, 0xB2, 0x30, 0xE0, 0x00, 0x00, 0x03])
            
            let message = try SerialPortProtocolMessage(from: data)
            let event = try BT20.Event(from: message)
            let notification = try event.decode(BatteryVoltageNotification.self)

            XCTAssertEqual(notification.date.description, "2024-03-09 10:15:14 +0000")
            XCTAssertEqual(notification.voltage.rawValue, 12512)
            XCTAssertEqual(notification.voltage.voltage, 12.512)
        }
    }
}
