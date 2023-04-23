//
//  SearchViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import Combine

protocol SearchViewModelInputInterface {
    func setLoadingAnimating(_ isAnimating: Bool)
    func search(value: String?)
}

protocol SearchViewModelOutputInterface {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var isReloadTableviewPublisher: AnyPublisher<Bool, Never> { get }
}

protocol SearchViewModelInterface {
    var input: SearchViewModelInputInterface { get }
    var output: SearchViewModelOutputInterface { get }
}

final class SearchViewModel: SearchViewModelInputInterface, SearchViewModelOutputInterface {
    var input: SearchViewModelInputInterface { self }
    var output: SearchViewModelOutputInterface { self }
    
    var isLoadingPublisher: AnyPublisher<Bool, Never> {
        return isLoadingSubject.eraseToAnyPublisher()
    }

    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    
    var isReloadTableviewPublisher: AnyPublisher<Bool, Never> {
        return isReloadTableviewSubject.eraseToAnyPublisher()
    }

    var searchItems = [Doc]()
    var coverItems = [String: Data]()
    
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let isReloadTableviewSubject = PassthroughSubject<Bool, Never>()
    private let networkManager = NetworkManager()
    private var cancellable = Set<AnyCancellable>()
    private var previousSearchValue = ""
    private var pageNumber = 1

    func setLoadingAnimating(_ isAnimating: Bool) {
        isLoadingSubject.send(isAnimating)
    }

    func search(value: String?) {
        var searchValue = previousSearchValue
        pageNumber += 1

        if let value = value {
            searchValue = value
            pageNumber = 1
        }

        isLoadingSubject.send(true)
        getBookList(
            key: "q",
            value: searchValue,
            pageNumber: pageNumber
        )
        .receive(on: RunLoop.main)
        .sink { [weak self] completion in
            guard let self = self else {
                return
            }
            switch completion {
            case .finished:
                return
            case .failure(let error):
                self.alertSubject.send(error.message)
            }
        } receiveValue: { [weak self] coverList in
            guard let self = self else {
                return
            }
            
            if coverList.isEmpty {
                self.isLoadingSubject.send(false)
                self.alertSubject.send("검색 결과가 없습니다.")
                return
            }

            coverList.forEach { coverData, coverName in
                self.coverItems[coverName] = coverData
            }
            
            self.isReloadTableviewSubject.send(true)
        }
        .store(in: &cancellable)
    }
    
    private func getBookList(key: String, value: String, pageNumber: Int) -> AnyPublisher<[(Data,String)], NetworkError> {
        return networkManager.getSearchRequest(
            key: key,
            value: value,
            pageNumber: pageNumber
        )
        .map { [weak self] searchList -> [AnyPublisher<(Data, String), NetworkError>] in
            guard let self = self else {
                return []
            }

            if self.previousSearchValue == value {
                self.searchItems += searchList.docs
            } else {
                self.searchItems = searchList.docs
                self.previousSearchValue = value
            }

            let fetchImageTasks = searchList.docs.map { doc -> AnyPublisher<(Data, String), NetworkError> in
                guard let id = doc.coverI else {
                    return Empty<(Data, String), NetworkError>().eraseToAnyPublisher()
                }
                return ImageCache.shared.load(
                    imageId: id,
                    imageSize: "S"
                ).eraseToAnyPublisher()
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
}
