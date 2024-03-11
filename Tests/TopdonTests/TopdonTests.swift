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
    func testAdvertisement() throws {
        
        let bt20AdvertisementData: LowEnergyAdvertisingData = [0x05, 0x09, 0x42, 0x54, 0x32, 0x30, 0x02, 0x01, 0x05, 0x03, 0x19, 0x80, 0x01, 0x05, 0x02, 0x12, 0x18, 0x0F, 0x18, 0x07, 0x03, 0x78, 0x5E, 0xE8, 0x91, 0x80, 0x14]
        
        let tb6000ProAdvertisementData: LowEnergyAdvertisingData = [0x02, 0x01, 0x06, 0x0A, 0x08, 0x54, 0x42, 0x36, 0x30, 0x30, 0x30, 0x50, 0x72, 0x6F, 0x09, 0xFF, 0x56, 0x00, 0x78, 0x5E, 0xE8, 0x90, 0x5A, 0x42]
        
        let values: [(LowEnergyAdvertisingData, TopdonAccessory)] = [
            (bt20AdvertisementData, .bt20(BT20(address: BluetoothAddress(rawValue: "78:5E:E8:91:80:14")!))),
            (tb6000ProAdvertisementData, .tb6000Pro(TB6000Pro(address: BluetoothAddress(rawValue: "78:5E:E8:90:5A:42")!)))
        ]
        
        for (data, accessory) in values {
            XCTAssertEqual(TopdonAccessory(data), accessory)
        }
    }
    #endif
}
