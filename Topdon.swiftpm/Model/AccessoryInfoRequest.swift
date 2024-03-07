//
//  AccessoryInfoRequest.swift
//
//
//  Created by Alsey Coleman Miller  on 3/6/24.
//

import Foundation

public extension URLClient {
    
    func downloadTopdonAccessoryInfo() async throws -> TopdonAccessoryInfo.Database {
        let url = URL(string: "https://raw.githubusercontent.com/MillerTechnologyPeru/Topdon/master/Topdon.swiftpm/Topdon.plist")!
        let (data, urlResponse) = try await self.data(for: URLRequest(url: url))
        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw URLError(.unknown)
        }
        guard httpResponse.statusCode == 200 else {
            throw URLError(.resourceUnavailable)
        }
        let decoder = PropertyListDecoder()
        return try decoder.decode(TopdonAccessoryInfo.Database.self, from: data)
    }
}
