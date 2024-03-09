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
        
    public let symbol: String
    
    public let image: String
        
    public let manual: String?
        
    public let website: String?
}

public extension TopdonAccessoryInfo {
    
    struct Database: Equatable, Hashable, Sendable {
        
        public let accessories: [TopdonAccessory: TopdonAccessoryInfo]
    }
}

public extension TopdonAccessoryInfo.Database {
    
    subscript(type: TopdonAccessory) -> TopdonAccessoryInfo? {
        accessories[type]
    }
}

public extension TopdonAccessoryInfo.Database {
    
    internal static let encoder: PropertyListEncoder = {
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .xml
        return encoder
    }()
    
    internal static let decoder: PropertyListDecoder = {
        let decoder = PropertyListDecoder()
        return decoder
    }()
    
    init(propertyList data: Data) throws {
        self = try Self.decoder.decode(TopdonAccessoryInfo.Database.self, from: data)
    }
    
    func encodePropertyList() throws -> Data {
        try Self.encoder.encode(self)
    }
}

extension TopdonAccessoryInfo.Database: Codable {
    
    public init(from decoder: Decoder) throws {
        let accessories = try [String: TopdonAccessoryInfo].init(from: decoder)
        self.accessories = try accessories.mapKeys {
            guard let key = TopdonAccessory(rawValue: $0) else {
                throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Invalid key \($0)"))
            }
            return key
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        try accessories
            .mapKeys { $0.rawValue }
            .encode(to: encoder)
    }
}
