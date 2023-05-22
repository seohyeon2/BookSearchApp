//
//  SearchViewController.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import UIKit
import Combine

final class SearchViewController: UIViewController {
    @IBOutlet weak var bookSearchBar: UISearchBar!
    @IBOutlet weak var searchTableView: UITableView!

    enum Section { case main }
    
    private typealias DataSource = UITableViewDiffableDataSource<Section, Doc>
    private typealias Snapshot = NSDiffableDataSourceSnapshot<Section, Doc>
        
    private var dataSource: DataSource?
    private var cancellable = Set<AnyCancellable>()
    
    private lazy var loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.center = self.view.center
        loadingView.style = UIActivityIndicatorView.Style.large
        return loadingView
    }()
    
    private let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        configureDataSource()
        bind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.isNavigationBarHidden = true
    }
    
    private func setTableView() {
        view.addSubview(searchTableView)
        view.addSubview(loadingView)

        searchTableView.dataSource = dataSource
        searchTableView.delegate = self
    }
    
    private func bind() {
        viewModel.output.isLoadingPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] isLoading in
                guard let self = self else {
                    return
                }
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
                guard let self = self else {
                    return
                }
                self.showCustomAlert(
                    title: nil,
                    message: error
                )
            }
            .store(in: &cancellable)
        
        viewModel.output.searchResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] docs in
                guard let self = self else {
                    return
                }
                self.reloadData(with: docs, animation: .automatic)
            }
            .store(in: &cancellable)
        
        viewModel.output.paginationResultPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] docs in
                guard let self = self else {
                    return
                }
                self.addData(with: docs, animation: .automatic)
            }
            .store(in: &cancellable)
        
        bookSearchBar.searchTextField.textPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] value in
                guard let self = self else {
                    return
                }
                self.viewModel.input.search(value: value)
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

// MARK: - UITableViewDataSource
extension SearchViewController {
    private func configureDataSource() {
        dataSource = DataSource(
            tableView: searchTableView,
            cellProvider: { tableView, indexPath, doc in
                guard let cell = tableView.dequeueReusableCell(
                    withIdentifier: SearchTableViewCell.identifier,
                    for: indexPath) as? SearchTableViewCell else {
                    return UITableViewCell()
                }
                cell.configureLabel(doc: doc)
                cell.configureImageView(doc: doc, imageSize: "S")

                return cell
            })
    }
    
    private func reloadData(
        with data: [Doc],
        animation: UITableView.RowAnimation
    ) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        appendDataSource(
            with: data,
            snapshot: snapshot,
            animation: animation)
    }
    
    private func addData (
        with data: [Doc],
        animation: UITableView.RowAnimation
    ) {
        appendDataSource(
            with: data,
            snapshot: dataSource?.snapshot() ?? Snapshot(),
            animation: animation)
    }
    
    private func appendDataSource(
        with data: [Doc],
        snapshot: SearchViewController.Snapshot,
        animation: UITableView.RowAnimation
    ) {
        var bookInfoSnapshot = snapshot
        bookInfoSnapshot.appendItems(data)
        dataSource?.apply(bookInfoSnapshot, animatingDifferences: true)
        dataSource?.defaultRowAnimation = animation
    }
}

// MARK: - Pagination
extension SearchViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let bottomPosition = scrollView.contentSize.height - scrollView.bounds.height
        let currentPosition = scrollView.contentOffset.y

        if Int(currentPosition) == Int(bottomPosition) {
            viewModel.input.bringNextPage()
        }
    }
}
