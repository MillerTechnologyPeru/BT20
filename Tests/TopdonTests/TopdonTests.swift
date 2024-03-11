import Foundation
import XCTest
import Bluetooth
#if canImport(BluetoothGAP)
import BluetoothGAP
#endif
import GATT
import Telink
@testable import Topdon

final class TopdonTests: XCTestCase {
    
    #if canImport(BluetoothGAP)
    func testBT20Advertisement() throws {
        
        /*
         Mar 05 23:27:25.897  HCI Event        0x0000  78:5E:E8:91:80:14  LE - Ext ADV - 1 Report - Normal - Public - 78:5E:E8:91:80:14  -72 dBm - BT20 - Channel 37
             Parameter Length: 53 (0x35)
             Num Reports: 0X01
             Report 0
                 Event Type: Connectable Advertising - Scannable Advertising - Legacy Advertising PDUs Used - Complete -
                 Address Type: Public
                 Peer Address: 78:5E:E8:91:80:14
                 Primary PHY: 1M
                 Secondary PHY: No Packets
                 Advertising SID: Unavailable
                 Tx Power: Unavailable
                 RSSI: -72 dBm
                 Periodic Advertising Interval: 0.000000ms (0x0)
                 Direct Address Type: Public
                 Direct Address: 00:00:00:00:00:00
                 Data Length: 27
                 Local Name: BT20
                 Flags: 0x5
                     LE Limited Discoverable Mode
                     BR/EDR Not Supported
                 Appearance: 0X0180
                 16 Bit UUIDs(Incomplete): 0X1812 0X180F
                 16 Bit UUIDs: 0X5E78 0X91E8 0X1480
                 Data: 05 09 42 54 32 30 02 01 05 03 19 80 01 05 02 12 18 0F 18 07 03 78 5E E8 91 80 14
         */
        
        let advertisementData: LowEnergyAdvertisingData = [0x05, 0x09, 0x42, 0x54, 0x32, 0x30, 0x02, 0x01, 0x05, 0x03, 0x19, 0x80, 0x01, 0x05, 0x02, 0x12, 0x18, 0x0F, 0x18, 0x07, 0x03, 0x78, 0x5E, 0xE8, 0x91, 0x80, 0x14]
        
        XCTAssertEqual(advertisementData.localName, "BT20")
        XCTAssertEqual(advertisementData.serviceUUIDs, [
            .bit16(0x5E78),
            .bit16(0x91E8),
            .bit16(0x1480),
            .humanInterfaceDevice,
            .batteryService
        ])
        XCTAssertNil(advertisementData.manufacturerData)
        
        guard let advertisement = BT20.Advertisement(advertisementData) else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(advertisement.address.rawValue, "78:5E:E8:91:80:14")
    }
    #endif
    
    func testBT20VoltageCommand() throws {
        
        let data = Data(hexadecimal: "55AA000DFFF2DD0265EC36A70001C6")!
        
        let message = try SerialPortProtocolMessage(
            command: BT20.Command(
                BatteryVoltageCommand()
            )
        )
        let encodedData = try message.encode()
        XCTAssertEqual(data, encodedData)
    }
    
    func testBT20VoltageNotification() throws {
        
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
