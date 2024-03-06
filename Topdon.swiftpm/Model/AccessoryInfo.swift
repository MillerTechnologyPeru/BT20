//
//  AccessoryInfo.swift
//
//
//  Created by Alsey Coleman Miller on 3/6/24.
//

import Foundation
import Topdon

/// Topdon Accessory Info
public struct TopdonAccessoryInfo: Equatable, Hashable, Codable, Sendable {
    
    public static var type: TopdonAccessory { .bt20 }
    
    public let symbol: String
    
    public let image: URL
    
    public let thumbnail: URL
    
    public let manual: URL?
        
    public let website: URL?
}

public extension TopdonAccessoryInfo {
    
    struct Database: Equatable, Hashable, Sendable {
        
        public let accessories: [TopdonAccessory: TopdonAccessoryInfo]
    }
}

extension TopdonAccessoryInfo.Database: Codable {
    
    public init(from decoder: Decoder) throws {
        self.accessories = try [TopdonAccessory: TopdonAccessoryInfo].init(from: decoder)
    }
    
    public func encode(to encoder: Encoder) throws {
        try accessories.encode(to: encoder)
    }
}
