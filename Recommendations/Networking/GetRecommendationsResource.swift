//
//  GetRecommendationsResource.swift
//  Recommendations
//
//  Created by Philip Tseng on 4/24/20.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import Foundation

struct Recommendation: Decodable {
    let title: String
    let is_released: Bool
    let rating: Double?
    let tagline: String
    let image: String
}

struct GetRecommendationsResponse: Decodable {
    let titles: [Recommendation]
    let skipped: [String]
    let titles_owned: [String]

    static func resource() -> Resource<GetRecommendationsResponse> {
        let components = URLComponents(string: Stub.stubbedURL_doNotChange)!
        return Resource<GetRecommendationsResponse>(method: .get, url: components.url!)
    }

    static func imageResource(for recommendation: Recommendation) -> ImageResource {
        let components = URLComponents(string: recommendation.image)!
        return ImageResource(imageUrl: components.url!, taskDescription: recommendation.image)
    }
}
