//
//  DetailViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/23.
//

import UIKit
import Combine

final class DetailViewController: UIViewController {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    var viewModel: DetailViewModel?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false

        configureCell()
    }

    private func configureCell() {
        let bookInformation = viewModel?.output.getBookInformation()
        thumbnailImageView.image = bookInformation?.0
        bookNameLabel.text = bookInformation?.1.first ?? "제목 미상"
        authorLabel.text = bookInformation?.1.last ?? "작가 미상"
    }
}
