//
//  DetailViewModel.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

import Foundation
import Combine
import UIKit

protocol DetailViewModelInputInterface { }

protocol DetailViewModelOutputInterface {
    func getBookInformation() -> (UIImage?,[String])
}

protocol DetailViewModelInterface {
    var input: DetailViewModelInputInterface { get }
    var output: DetailViewModelOutputInterface { get }
}

final class DetailViewModel: DetailViewModelInputInterface, DetailViewModelOutputInterface {
    
    init(doc: Doc, image: UIImage?) {
        self.doc = doc
        self.image = image
    }
    
    var input: DetailViewModelInputInterface { self }
    var output: DetailViewModelOutputInterface { self }
    
    private var doc: Doc
    private var image: UIImage?
    
    func getBookInformation() -> (UIImage?,[String]) {
        let bookName = doc.title ?? "제목 미상"
        let authorName = doc.authorName?.first ?? "작가 미상"
        let bookInfo = [bookName,authorName]
        
        return (image,bookInfo)
    }
}
