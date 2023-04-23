//
//  DetailViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

import Foundation
import Combine

protocol DetailViewModelInputInterface {
    func setBookInformation(_ data: (Data,Doc))
}

protocol DetailViewModelOutputInterface {
    var detailInformationPublisher: AnyPublisher<(Data,Doc), Never> { get }
}

protocol DetailViewModelInterface {
    var input: DetailViewModelInputInterface { get }
    var output: DetailViewModelOutputInterface { get }
}

final class DetailViewModel: DetailViewModelInputInterface, DetailViewModelOutputInterface {
    var input: DetailViewModelInputInterface { self }
    var output: DetailViewModelOutputInterface { self }
    
    var detailInformationPublisher: AnyPublisher<(Data,Doc), Never> {
        return detailInformationSubject.eraseToAnyPublisher()
    }
    
    private var detailInformationSubject = PassthroughSubject<(Data,Doc), Never>()
    
    func setBookInformation(_ data: (Data,Doc)) {
        detailInformationSubject.send(data)
    }
}
