//
//  SearchTableViewCell.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit
import Combine
import Kingfisher

final class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!

    static let identifier = "SearchTableViewCell"

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

    override func prepareForReuse() {
        thumbnailImageView.image = UIImage(systemName: "book.closed.fill")
        bookNameLabel.text = "제목 미상"
        authorLabel.text = "작가 미상"
    }
    
    func configureLabel(doc: Doc) {
        bookNameLabel.text = doc.title ?? "제목 미상"
        authorLabel.text = doc.authorName?.first ?? "작가 미상"
    }
    
    func configureImageView(doc: Doc, imageSize: String) {
        guard let imageId = doc.coverI else {
            return thumbnailImageView.image = UIImage(systemName: "book.closed.fill")
        }

        let url = URL(string: "https://covers.openlibrary.org/b/id/\(imageId)-\(imageSize).jpg")

        thumbnailImageView.kf.setImage(with: url)
    }
}
