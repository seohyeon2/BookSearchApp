//
//  RequestProtocol.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation

protocol RequestProtocol {
    var host: String { get }
    var path: String { get }
    var queries: [String: String] { get }
    
    func createURLRequest() throws -> URLRequest
}

extension RequestProtocol {
    var scheme: String {
        return APIConstants.scheme
    }
    
    func createURLRequest() throws -> URLRequest {
        var components = URLComponents()
        components.scheme = scheme
        components.host = host
        components.path = path
        
        if queries.isNotEmpty {
            components.queryItems = queries.map(URLQueryItem.init(name:value:))
        }
        
        guard let url = components.url else { throw NetworkError.noneData }

        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
}

enum BookRequest: RequestProtocol {
    case search(String, String, Int)
    case cover(Int, String)
    
    var host: String {
        switch self {
        case .cover:
            return APIConstants.coverHost + APIConstants.host
        default:
            return APIConstants.host
        }
    }

    var path: String {
        switch self {
        case .search:
            return APIConstants.searchPath
        case .cover(let imageId, let imageSize):
            return APIConstants.coverPath + imageId.replacingCoverImageName(size: imageSize)
        }
    }
    
    var queries: [String : String] {
        switch self {
        case .search(let key, let value, let pageNumber):
            return [
                key: value.replacingSpacesWithPlus(),
                APIConstants.page: "\(pageNumber)"
            ]
        default:
            return [:]
        }
    }
}

extension String {
    func replacingSpacesWithPlus() -> String {
        return self.replacingOccurrences(of: " ", with: "+")
    }
}
    
extension Int {
    func replacingCoverImageName(size: String) -> String {
        return "\(self)-\(size).jpg"
    }
}

extension Dictionary {
    var isNotEmpty: Bool {
        return !self.isEmpty
    }
}
