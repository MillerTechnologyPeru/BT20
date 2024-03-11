import Foundation
import Bluetooth
import GATT

/// Topdon Bluetooth Accessory Type
public enum TopdonAccessoryType: String, Equatable, Hashable, Sendable, Codable {
    
    case bt20 = "BT20"
    case tb6000Pro = "TB6000Pro"
}

/// Topdon Bluetooth Accessory
public enum TopdonAccessory: Equatable, Hashable, Sendable {
    
    case bt20(BT20)
    case tb6000Pro(TB6000Pro)
}

extension TopdonAccessory: Identifiable {
    
    public var id: BluetoothAddress {
        address
    }
}

public extension TopdonAccessory {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        if let bt20 = BT20(advertisement) {
            self = .bt20(bt20)
        } else if let tb6000Pro = TB6000Pro(advertisement) {
            self = .tb6000Pro(tb6000Pro)
        } else {
            return nil
        }
    }
    
    var type: TopdonAccessoryType {
        switch self {
        case .bt20:
            return .bt20
        case .tb6000Pro:
            return .tb6000Pro
        }
    }
    
    var name: String {
        type.rawValue
    }
    
    var address: BluetoothAddress {
        switch self {
        case let .bt20(advertisement):
            return advertisement.address
        case let .tb6000Pro(advertisement):
            return advertisement.address
        }
    }
}
