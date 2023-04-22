//
//  NetworkManager.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit
import Combine

final class NetworkManager {
    
    private var cancellable = Set<AnyCancellable>()

    private func requestToServer(request: URLRequest) -> AnyPublisher<Data, NetworkError> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
            .tryMap() { data, response in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NetworkError.failToResponse
                }

                guard 200..<300 ~= httpResponse.statusCode else {
                    throw NetworkError.outOfRange
                }

                guard !data.isEmpty else {
                    throw NetworkError.noneData
                }

                return data
            }
            .mapError { error in
                if let error = error as? NetworkError {
                    return error
                } else {
                    return NetworkError.noneData
                }
            }
            .eraseToAnyPublisher()
    }
    
    func getSearchRequest(key: String, value: String) -> AnyPublisher<Data, NetworkError> {
        guard let request = try? BookRequest.search(key, value).createURLRequest() else {
            return Fail(error: NetworkError.failToResponse).eraseToAnyPublisher()
        }

        return requestToServer(request: request)
    }
    
    func getCoverRequest(imageName: String) -> AnyPublisher<Data, NetworkError> {
        guard let request = try? BookRequest.cover(imageName).createURLRequest() else {
            return Fail(error: NetworkError.failToResponse).eraseToAnyPublisher()
        }

        return requestToServer(request: request)
    }
}

