//
//  SearchTableViewCell.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit
import Combine

final class SearchTableViewCell: UITableViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
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
}
