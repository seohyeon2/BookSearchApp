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
    var isReloadTableviewPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var searchResultPublisher: AnyPublisher<[Doc], Never> { get }
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
    
    var isReloadTableviewPublisher: AnyPublisher<Bool, Never> {
        return isReloadTableviewSubject.eraseToAnyPublisher()
    }

    var alertPublisher: AnyPublisher<String, Never> {
        return alertSubject.eraseToAnyPublisher()
    }
    
    var searchResultPublisher: AnyPublisher<[Doc], Never> {
        return searchResultSubject.eraseToAnyPublisher()
    }
    
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let isReloadTableviewSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let searchResultSubject = PassthroughSubject<[Doc], Never>()
    private let networkManager = NetworkManager()

    private var previousSearchValue = ""
    private var pageNumber = 1

    func setLoadingAnimating(_ isAnimating: Bool) {
        isLoadingSubject.send(isAnimating)
    }

    func search(value: String?) {
        Task {
            var searchValue = previousSearchValue
            pageNumber += 1

            if let value = value {
                searchValue = value
                pageNumber = 1
            }

            isLoadingSubject.send(true)

            await sendBookList(
                key: "q",
                value: searchValue,
                pageNumber: pageNumber
            )
            
            isLoadingSubject.send(false)
        }
    }
    
    func getCoverImage(doc: Doc, imageSize: String) async -> Data? {
        guard let imageId = doc.coverI else {
            return nil
        }
        return try? await networkManager.fetchCoverImage(
            imageId: imageId,
            imageSize: imageSize)
    }
    
    private func sendBookList(key: String, value: String, pageNumber: Int) async {
        do {
            let searchData = try await networkManager.fetchSearch(
                key: key,
                value: value,
                pageNumber: pageNumber)
            isReloadTableviewSubject.send(true)
            
            if searchData.docs.isEmpty {
                alertSubject.send("검색 결과가 없습니다.")
                return
            }

            searchResultSubject.send(searchData.docs)
        } catch {
            alertSubject.send("요청하신 작업을 수행할 수 없습니다.")
        }
    }
}
