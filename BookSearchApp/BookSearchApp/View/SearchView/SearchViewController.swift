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

        viewModel.output.isReloadTableviewPublisher
            .receive(on: DispatchQueue.main)
            .filter({ $0 == true })
            .sink { [weak self] _ in
                guard let self = self else {
                    return
                }
                self.searchTableView.reloadData()
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
                    for: indexPath
                ) as? SearchTableViewCell else {
                    return nil
                }
                cell.configureLabel(doc: doc)
                return cell
            })
    }
    
    private func reloadData(
        with data: [Doc],
        animation: UITableView.RowAnimation
    ) {
        var snapshot = Snapshot()
        snapshot.appendSections([.main])
        snapshot.appendItems(data)
        dataSource?.apply(snapshot, animatingDifferences: true)
        dataSource?.defaultRowAnimation = animation
    }
}

// extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return dataSource?.snapshot().numberOfItems ?? 0
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        viewModel.input.setLoadingAnimating(false)
//
//        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.identifier) as? SearchTableViewCell else {
//            return .init()
//        }
//
//        if let doc = dataSource?.snapshot().itemIdentifiers[indexPath.row] {
//            cell.configureLabel(doc: doc)
//        }
//
//        return cell
//    }

//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        tableView.deselectRow(at: indexPath, animated: true)
//        guard let detailViewController = storyboard?.instantiateViewController(withIdentifier: "DetailViewController") as? DetailViewController else {
//            return
//        }
//
//        var imageData = Data()
//        if let imageName = viewModel.searchItems[indexPath.row].coverI {
//            imageData = viewModel.coverItems[imageName.replacingCoverImageName(size: "S")] ?? Data()
//        }
//
//        weak var sendDataDelegate:(SendDataDelegate)? = detailViewController
//        sendDataDelegate?.sendData((imageData, viewModel.searchItems[indexPath.row]))
//
//        navigationController?.pushViewController(detailViewController, animated: true)
//    }
    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let bottomPosition = scrollView.contentSize.height - scrollView.bounds.height
//        let currentPosition = scrollView.contentOffset.y
//
//        if Int(currentPosition) == Int(bottomPosition) {
//            viewModel.input.search(value: nil)
//        }
//    }
// }
