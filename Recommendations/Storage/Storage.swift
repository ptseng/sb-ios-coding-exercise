//
//  Storage.swift
//  Recommendations
//
//  Created by Philip Tseng on 4/26/20.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

final class Storage {
    let jsonPathComponent = "recommendations.json"
    
    typealias StorageOperationSuccess = Bool
    @discardableResult
    func save(_ recommendations: [Recommendation]) -> StorageOperationSuccess {
        let encoder = JSONEncoder()
        if let url = cacheDirectoryURL()?.appendingPathComponent(jsonPathComponent),
            let data = try? encoder.encode(recommendations),
            let _ = try? data.write(to: url, options: []) {
            return true
        }
        return false
    }

    func retrieveRecommendations() -> [Recommendation] {
        let decoder = JSONDecoder()
        if let url = cacheDirectoryURL()?.appendingPathComponent(jsonPathComponent),
            let data = try? Data(contentsOf: url, options: []),
            let recommendations = try? decoder.decode([Recommendation].self, from: data) {
            return recommendations
        }
        return []
    }

    private func cacheDirectoryURL() -> URL? {
        return FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first
    }
}
