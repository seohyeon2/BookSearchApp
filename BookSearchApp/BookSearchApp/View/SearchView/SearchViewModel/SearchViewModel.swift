//
//  SearchViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import Combine
import UIKit

protocol SearchViewModelInputInterface {
    func search(value: String)
    func didSelectCell(doc: Doc, image: UIImage?)
}

protocol SearchViewModelOutputInterface {
    var isLoadingPublisher: AnyPublisher<Bool, Never> { get }
    var alertPublisher: AnyPublisher<String, Never> { get }
    var searchResultPublisher: AnyPublisher<[Doc], Never> { get }
    var paginationResultPublisher: AnyPublisher<[Doc], Never> { get }
    
    func bringNextPage()
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
    
    var searchResultPublisher: AnyPublisher<[Doc], Never> {
        return searchResultSubject.eraseToAnyPublisher()
    }
    
    var paginationResultPublisher: AnyPublisher<[Doc], Never> {
        return paginationResultSubject.eraseToAnyPublisher()
    }
    
    weak var viewController: UIViewController?
    
    private let isLoadingSubject = PassthroughSubject<Bool, Never>()
    private let alertSubject = PassthroughSubject<String, Never>()
    private let searchResultSubject = PassthroughSubject<[Doc], Never>()
    private let paginationResultSubject = PassthroughSubject<[Doc], Never>()
    private let networkManager = NetworkManager()

    private var previousSearchValue = ""
    private var pageNumber = 1
    private var searchTask: Task<Void, Never>?
    
    func search(value: String) {
        searchTask?.cancel()
        searchTask = Task {
            isLoadingSubject.send(true)
            
            pageNumber = 1
            previousSearchValue = value
            
            guard let docs = await sendBookList(
                key: "q",
                value: value,
                pageNumber: pageNumber
            ) else {
                return
            }

            searchResultSubject.send(docs)
            isLoadingSubject.send(false)
        }
    }
    
    func bringNextPage() {
        searchTask = Task {
            isLoadingSubject.send(true)
            
            let searchValue = previousSearchValue
            pageNumber += 1

            guard let docs = await sendBookList(
                key: "q",
                value: searchValue,
                pageNumber: pageNumber
            ) else {
                return
            }
            
            paginationResultSubject.send(docs)
            isLoadingSubject.send(false)
        }
    }
    
    func didSelectCell(doc: Doc, image: UIImage?) {
        let storyboard = UIStoryboard(
            name: "DetailView",
            bundle: nil
        )
        
        guard let detailViewController = storyboard.instantiateInitialViewController() as? DetailViewController else { return }
        
        detailViewController.viewModel = DetailViewModel(
            doc: doc,
            image: image
        )
        
        if let navigationController = viewController?.navigationController {
            navigationController.pushViewController(
                detailViewController,
                animated: true
            )
        }
    }

    private func sendBookList(key: String, value: String, pageNumber: Int) async -> [Doc]? {
        do {
            let searchData = try await networkManager.fetchSearch(
                key: key,
                value: value,
                pageNumber: pageNumber)
            
            if searchData.docs.isEmpty {
                isLoadingSubject.send(false)
                alertSubject.send("검색 결과가 없습니다.")
                return nil
            }
            
            return searchData.docs
        } catch {
            guard let error = error as? URLError, error.code != URLError.cancelled else {
                return nil
            }
            isLoadingSubject.send(false)
            alertSubject.send("요청하신 작업을 수행할 수 없습니다.")
            return nil
        }
    }
}
