//
//  DetailViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/23.
//

import UIKit
import Combine

class DetailViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    private var viewModel = DetailViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
    }

    private func bind() {
        viewModel.output.detailInformationPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] imageData, bookInformation in
                guard let self = self else { return }
                
                var bookName = "제목 미상"
                var authorName = "작가 미상"
                
                if let name = bookInformation.title {
                    bookName = name
                }
                
                if let author = bookInformation.authorName {
                    authorName = author[0]
                }
                
                if !imageData.isEmpty {
                    self.thumbnailImageView.image = UIImage(data: imageData)
                }

                self.bookNameLabel.text = bookName
                self.authorLabel.text = authorName
            }
            .store(in: &cancellable)
    }
}

extension DetailViewController: SendDataDelegate {
    func sendData<T>(_ data: T) {
        guard let data = data as? (Data, Doc) else {
            return
        }
        bind()
        viewModel.input.setBookInformation(data)
    }
}
