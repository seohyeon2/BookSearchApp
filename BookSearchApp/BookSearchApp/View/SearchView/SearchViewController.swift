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
        loadingView.style = UIActivityIndicatorView.Style.large
        return loadingView
    }()
    
    private let viewModel = SearchViewModel()
    private var cancellable = Set<AnyCancellable>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setTableView() {
        searchTableView.delegate = self
        searchTableView.dataSource = self
        view.addSubview(searchTableView)
        view.addSubview(loadingView)
    }
    
    private func bind() {
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
        
        bookSearchBar.searchTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else { return }
                print(value)
                self.viewModel.input.search(value: value)
            }
            .store(in: &cancellable)
        
        viewModel.output.isReloadTableviewPublisher
            .receive(on: DispatchQueue.main)
            .filter({ $0 == true })
            .sink { [weak self] _ in
                guard let self = self else { return }
                self.searchTableView.reloadData()
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
        viewModel.input.setLoadingAnimating(false)
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SearchTableViewCell") as? SearchTableViewCell else {
            return .init()
        }
        
        guard let bookName = viewModel.searchItems[indexPath.row].title,
              let author = viewModel.searchItems[indexPath.row].authorName else {
            return cell
        }

        cell.bookNameLabel.text = bookName
        cell.authorLabel.text = author[0]
        
        guard let imageName = viewModel.searchItems[indexPath.row].coverI,
              let imageData = viewModel.coverItems[imageName.replacingCoverImageName(size: "S")] else {
            return cell
        }
        
        cell.thumbnailImageView.image = UIImage(data: imageData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") else {
            return
        }
        navigationController?.pushViewController(detailViewController, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomPosition = scrollView.contentSize.height - scrollView.bounds.height
        let currentPosition = scrollView.contentOffset.y

        if Int(currentPosition) == Int(bottomPosition) {
            viewModel.input.search(value: nil)
        }
    }
}
