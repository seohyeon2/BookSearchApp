//
//  SearchViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import Combine

protocol SearchViewModelInputInterface {
    func getBookList(key: String, value: String)
}

protocol SearchViewModelOutputInterface {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var searchItemPublisher: AnyPublisher<Search, Never> { get }
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
    
    var searchItemPublisher: AnyPublisher<Search, Never> {
        return searchItemSubject.eraseToAnyPublisher()
    }
    
    var searchItems = [Doc]()
    
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let searchItemSubject = PassthroughSubject<Search, Never>()
    private let networkManager = NetworkManager()
    private var cancellable = Set<AnyCancellable>()
    
    func getBookList(key: String, value: String) {
        networkManager.getSearchRequest(key: key, value: value)
            .decode(type: Search.self, decoder: JSONDecoder())
            .sink { [weak self] completion in
                switch completion {
                case .finished:
                    return
                case .failure(let error):
                    guard let error = error as? NetworkError else { return }
                    self?.alertSubject.send(error.message)
                }
            } receiveValue: { [weak self] searchData in
                guard let self = self else { return }
                self.isLoadingSubject.send(true)
                self.searchItemSubject.send(searchData)
                self.isLoadingSubject.send(false)
            }
            .store(in: &cancellable)
    }
}
