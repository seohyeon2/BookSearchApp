//
//  SearchViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import Combine

protocol SearchViewModelInputInterface {
    func getBookList(key: String, value: String, pageNumber: Int) -> AnyPublisher<[(Data,String)], NetworkError>
    func setLoadingAnimating(_ isAnimating: Bool)
    func showErrorAlert(message: String)
}

protocol SearchViewModelOutputInterface {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
}

protocol SearchViewModelInterface {
    var input: SearchViewModelInputInterface { get }
    var output: SearchViewModelOutputInterface { get }
}

class SearchViewModel: SearchViewModelInputInterface, SearchViewModelOutputInterface {
    var input: SearchViewModelInputInterface { self }
    var output: SearchViewModelOutputInterface { self }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }

    var searchItems = [Doc]()
    var coverItems = [String: Data]()
    var pageNumber = 1
    
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let networkManager = NetworkManager()
    private var cancellable = Set<AnyCancellable>()

    func getBookList(key: String, value: String, pageNumber: Int) -> AnyPublisher<[(Data,String)], NetworkError> {
        return networkManager.getSearchRequest(key: key, value: value, pageNumber: pageNumber)
            .map { [weak self] searchList -> [AnyPublisher<(Data, String), NetworkError>] in
                guard let self = self else {
                    return []
                }
                
                self.searchItems += searchList.docs
                
                let fetchImageTasks = searchList.docs.map { doc -> AnyPublisher<(Data, String), NetworkError> in
                    guard let id = doc.coverI else {
                        return Empty<(Data, String), NetworkError>().eraseToAnyPublisher()
                    }
                    return ImageCache.shared.load(imageId: id, imageSize: "S").eraseToAnyPublisher()
                }
                
                return fetchImageTasks
            }
            .flatMap(maxPublishers: .max(1)) { publishers -> AnyPublisher<[(Data,String)], NetworkError> in
                Publishers.MergeMany(publishers)
                    .map { $0 }
                    .collect()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func setLoadingAnimating(_ isAnimating: Bool) {
        isLoadingSubject.send(isAnimating)
    }

    func showErrorAlert(message: String) {
        alertSubject.send(message)
    }

}
