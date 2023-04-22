//
//  SearchViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit
import Combine

class SearchViewController: UIViewController {
    
    @IBOutlet weak var bookSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!

    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.center = self.view.center
        loadingView.startAnimating()
        loadingView.style = UIActivityIndicatorView.Style.large
        loadingView.isHidden = false
        return loadingView
    }()
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        bind()
    }
    
    private func setTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        view.addSubview(searchTableView)
        view.addSubview(loadingView)
    }
    
    private func bind() {
        viewModel.output.searchItemPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] searchItem in
                guard let self = self else { return }
                self.viewModel.searchItems = searchItem.docs
                self.searchTableView.reloadData()
                
                print(self.viewModel.searchItems)
            }
            .store(in: &cancellable)

        viewModel.output.isLoadingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self = self else { return }
                if isLoading {
                    self.loadingView.isHidden = false
                    self.loadingView.startAnimating()
                } else {
                    self.loadingView.isHidden = true
                    self.loadingView.stopAnimating()
                }
            }
            .store(in: &cancellable)

        viewModel.output.alertPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] error in
                guard let self = self else { return }
                self.showCustomAlert(
                    title: nil,
                    message: error
                )
            }
            .store(in: &cancellable)
    }
    
    private func showCustomAlert(title: String?, message: String) {
        let okTitle = "확인"
        let alertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: .alert
        )
        let okButton = UIAlertAction(
            title: okTitle,
            style: .default
        )

        alertController.addAction(okButton)
        
        present(alertController, animated: true)
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.searchItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as? SearchTableViewCell else {
            return .init()
        }
        
        guard let bookName = viewModel.searchItems[indexPath.row].title,
              let author = viewModel.searchItems[indexPath.row].authorName else {
            return cell
        }
        
        cell.bookNameLabel.text = bookName
        cell.authorLabel.text = author[0]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
