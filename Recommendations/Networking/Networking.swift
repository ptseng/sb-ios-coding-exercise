//
//  Networking.swift
//  Recommendations
//
//  Created by Philip Tseng on 4/24/20.
//  Copyright © 2020 Serial Box. All rights reserved.
//

import UIKit

/// Adopted from objc.io Swift Talk's "Tiny Networking Library"
/// https://talk.objc.io/episodes/S01E1-tiny-networking-library
/// https://talk.objc.io/episodes/S01E8-adding-post-requests

// MARK: HttpMethod
enum HttpMethod<Body> {
    case get
    case post(Body)
}

extension HttpMethod {
    var methodString: String {
        switch self {
        case .get: return "GET"
        case .post: return "POST"
        }
    }

    func map<B>(f: (Body) -> B) -> HttpMethod<B> where B: Encodable {
        switch self {
        case .get: return .get
        case .post(let body): return .post(f(body))
        }
    }
}

// MARK: Resource
struct Resource<A> where A: Decodable {
    let method: HttpMethod<Data>
    let url: URL
    let parse: (Data) -> A? = { data in return try? JSONDecoder().decode(A.self, from: data) }
}

extension Resource {
    init<T>(method: HttpMethod<T>, url: URL) where T: Encodable {
        self.method = method.map { json in try! JSONEncoder().encode(json) }
        self.url = url
    }
}

// MARK: ImageResource
struct ImageResource {
    let url: URL
    let taskDescription: String
    let method: HttpMethod<Data>
    let parse: (Data) -> UIImage?
}

extension ImageResource {
    init(imageUrl: URL, taskDescription: String) {
        self.url = imageUrl
        self.taskDescription = taskDescription
        self.method = .get
        self.parse = { data in return UIImage(data: data) }
    }
}

// MARK: Networking
final class Networking {
    func load<A>(resource: Resource<A>, completion: @escaping (A?, URLRequest?, Error?) -> Void) {
        let request = URLRequest(resource: resource)
        URLSession.shared.dataTask(with: request) { data, _, error in
            if let error = error {
                completion(nil, request, error)
                return
            }
            completion(data.flatMap(resource.parse), request, nil)
        }.resume()
    }

    func loadImage(resource: ImageResource, completion: @escaping (UIImage?, Error?) -> Void) {
        let request = URLRequest(imageResource: resource)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(nil, error)
                return
            }
            completion(data.flatMap(resource.parse), nil)
        }
        task.taskDescription = resource.taskDescription
        task.resume()
    }

    func cancelRequest(for taskDescription: String) {
        URLSession.shared.getAllTasks {
            $0.filter { $0.taskDescription == taskDescription }.forEach { $0.cancel() }
        }
    }
}

// MARK: URLRequest
private extension URLRequest {
    init<A>(resource: Resource<A>) {
        self.init(url: resource.url)
        httpMethod = resource.method.methodString
        if case let .post(body) = resource.method { httpBody = body }
    }
    init(imageResource: ImageResource) {
        self.init(url: imageResource.url)
        httpMethod = imageResource.method.methodString
    }
}
