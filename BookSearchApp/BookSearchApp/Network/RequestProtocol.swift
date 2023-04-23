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
        
        guard let url = components.url else {
            throw NetworkError.noneData
        }

        let urlRequest = URLRequest(url: url)
        return urlRequest
    }
}
