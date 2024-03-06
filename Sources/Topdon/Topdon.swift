import Foundation
import Bluetooth
import GATT

/// Topdon Bluetooth Accessory
public enum TopdonAccessory: String, Equatable, Hashable, Sendable {
    
    case bt20
}

public extension TopdonAccessory {
    
    enum Advertisement: Equatable, Hashable, Sendable {
        
        case bt20(BT20.Advertisement)
    }
}

extension TopdonAccessory.Advertisement: Identifiable {
    
    public var id: BluetoothAddress {
        address
    }
}

public extension TopdonAccessory.Advertisement {
    
    init?<T: AdvertisementData>(_ advertisement: T) {
        if let bt20 = BT20.Advertisement(advertisement) {
            self = .bt20(bt20)
        } else {
            return nil
        }
    }
    
    var type: TopdonAccessory {
        switch self {
        case .bt20:
            return .bt20
        }
    }
    
    var name: String {
        switch self {
        case .bt20:
            return BT20.Advertisement.name
        }
    }
    
    var address: BluetoothAddress {
        switch self {
        case .bt20(let advertisement):
            return advertisement.address
        }
    }
}
