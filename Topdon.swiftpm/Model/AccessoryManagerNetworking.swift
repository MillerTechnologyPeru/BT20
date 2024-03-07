//
//  AccessoryManagerNetworking.swift
//
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation

internal extension AccessoryManager {
    
    func loadURLSession() -> URLSession {
        URLSession(configuration: .ephemeral)
    }
}

public extension AccessoryManager {
    
    @discardableResult
    func downloadAccessoryInfo() async throws -> TopdonAccessoryInfo.Database {
        // fetch from server
        let value = try await urlSession.downloadTopdonAccessoryInfo()
        // write to disk
        try saveAccessoryInfoFile(value)
        return value
    }
}
