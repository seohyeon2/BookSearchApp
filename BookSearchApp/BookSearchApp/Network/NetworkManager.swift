//
//  NetworkManager.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit

final class NetworkManager {

    private func perform(request: URLRequest) async throws -> Data {
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.failToResponse
        }

        guard 200..<300 ~= httpResponse.statusCode else {
            throw NetworkError.outOfRange
        }
        
        return data
    }
    
    func fetchSearch(key: String, value: String, pageNumber: Int) async throws -> Search {
        guard let request = try? BookRequest.search(
            key,
            value,
            pageNumber
        ).createURLRequest() else {
            throw NetworkError.failToResponse
        }
        
        let data = try await perform(request: request)
        
        do {
            return try JSONDecoder().decode(Search.self, from: data)
        } catch {
            throw NetworkError.failToDecoding
        }
    }
    
    func fetchCoverImage(imageId: Int, imageSize: String) async throws -> Data {
        guard let request = try? BookRequest.cover(
            imageId,
            imageSize
        ).createURLRequest() else {
            throw NetworkError.failToResponse
        }
        
        return try await perform(request: request)
    }
}
