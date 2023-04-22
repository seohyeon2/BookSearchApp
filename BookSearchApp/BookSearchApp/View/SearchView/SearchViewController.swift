//
//  SearchViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit

class SearchViewController: UIViewController {
    
    @IBOutlet weak var bookSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
    }
    
    private func setTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        view.addSubview(searchTableView)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as? SearchTableViewCell else {
            return .init()
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
