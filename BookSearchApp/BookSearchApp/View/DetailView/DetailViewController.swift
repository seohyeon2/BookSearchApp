//
//  DetailViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/23.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var bookNameLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.isNavigationBarHidden = false
    }
}
