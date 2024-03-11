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
        
        guard let accessory = TopdonAccessory(advertisementData),
            case let .tb6000Pro(advertisement) = accessory else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(accessory.type, .tb6000Pro)
        XCTAssertEqual(accessory.name, "TB6000Pro")
        XCTAssertEqual(accessory.address.rawValue, "78:5E:E8:90:5A:42")
        XCTAssertEqual(type(of: advertisement).type, .tb6000Pro)
        XCTAssertEqual(type(of: advertisement).name, "TB6000Pro")
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
        
        let data = Data(hexadecimal: "55AA001AFFE5BF1265EF40E301035A327E020A0000002C00000008BC")!
        XCTAssertEqual(data.count, 28)
        
        let message = try SerialPortProtocolMessage(from: data)
        let event = try BT20.Event(from: message)
        let notification = try event.decode(TB6000Pro.BatteryVoltageNotification.self)
        
        XCTAssertEqual(notification.date.description, "2024-03-11 17:35:31 +0000")
        XCTAssertEqual(notification.voltage.voltage, 12.926)
        XCTAssertEqual(notification.watts.watts, 6.6394)
        XCTAssertEqual(notification.amperage.amperage, 0.522)
        XCTAssertEqual(notification.voltage.voltage * notification.amperage.amperage, 6.747372)
    }
}
