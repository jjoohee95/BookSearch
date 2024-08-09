//
//  SearchViewController.swift
//  BookSearch
//
//  Created by Leejh on 8/1/24.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate, BookListCellDelegate, RecentBookCellDelegate {
    
    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar!
    
    var books: [BookModel] = []
    var recentBooks: [BookModel] = [] {
        didSet {
            saveRecentBooks()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        loadRecentBooks()
        view.backgroundColor = .white
        
    }
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: "BookListCell")
        collectionView.register(RecentBookCell.self, forCellWithReuseIdentifier: "RecentBookCell")
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        view.addSubview(collectionView)
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupSearchBar() {
        searchBar = UISearchBar()
        searchBar.placeholder = "검색어를 입력하세요"
        searchBar.delegate = self
        
        let searchButton = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = searchButton
    }
    
    @objc private func searchButtonTapped() {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else {
            showAlert(title: "검색어 입력 필요", message: "검색어를 입력해 주세요.")
            return
        }
        searchBooks(query: query)
    }

    private func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
    
        present(alertController, animated: true, completion: nil)
    }
    
    func searchBooks(query: String) {
        Task {
            do {
                let fetchedBooks = try await NetworkManager.shared.fetchData(query: query)
                await MainActor.run {
                    self.books = fetchedBooks
                    self.collectionView.reloadSections(IndexSet(integer: 1))
                }
            } catch {
                await MainActor.run {
                    print("오류 발생 : \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("셀 선택됨")
        if indexPath.section == 0, let recentBookCell = collectionView.cellForItem(at: indexPath) as? RecentBookCell {
            didTapRecentBookCell(recentBookCell)
        } else if indexPath.section == 1, let bookListCell = collectionView.cellForItem(at: indexPath) as? BookListCell {
            didTapCell(bookListCell)
        }
    }
    
    func didTapCell(_ cell: BookListCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        print("상세정보 확인페이지 나와야함")
        let selectedBook = books[indexPath.item]
        
        let infoVC = BookInfoViewController()
        infoVC.book = selectedBook
        infoVC.modalPresentationStyle = .pageSheet
        self.present(infoVC, animated: true, completion: nil)
        
        updateRecentBooks(with: selectedBook)
    }
    
    
    func didTapRecentBookCell(_ cell: RecentBookCell) {
        guard let indexPath = collectionView.indexPath(for: cell) else { return }
        
        let selectedBook = recentBooks[indexPath.item]
        
        let infoVC = BookInfoViewController()
        infoVC.book = selectedBook
        infoVC.modalPresentationStyle = .pageSheet
        self.present(infoVC, animated: true, completion: nil)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
    
        let horizontalItemSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
        let horizontalItem = NSCollectionLayoutItem(layoutSize: horizontalItemSize)
        horizontalItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let horizontalGroupSize = NSCollectionLayoutSize(widthDimension: .absolute(150), heightDimension: .absolute(150))
        let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: horizontalGroupSize, subitems: [horizontalItem])
        horizontalGroup.interItemSpacing = .fixed(10)

        let horizontalSection = NSCollectionLayoutSection(group: horizontalGroup)
        horizontalSection.orthogonalScrollingBehavior = .continuous
        horizontalSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
        let horizontalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let horizontalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: horizontalHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        horizontalSection.boundarySupplementaryItems = [horizontalHeader]
        

        let verticalItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let verticalItem = NSCollectionLayoutItem(layoutSize: verticalItemSize)
        verticalItem.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16)

        let verticalGroupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80))
        let verticalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: verticalGroupSize, subitems: [verticalItem])
        verticalGroup.interItemSpacing = .fixed(10)

        let verticalSection = NSCollectionLayoutSection(group: verticalGroup)
        verticalSection.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        let verticalHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let verticalHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: verticalHeaderSize, elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
        verticalSection.boundarySupplementaryItems = [verticalHeader]


        return UICollectionViewCompositionalLayout { sectionIndex, layoutEnvironment in
            if sectionIndex == 0 {
                return horizontalSection
            } else if sectionIndex == 1 {
                return verticalSection
            } else {
                return nil
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if section == 0 {
            return recentBooks.count
        } else if section == 1 {
            return  books.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let identifier = indexPath.section == 0 ? "RecentBookCell" : "BookListCell"
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        if let bookListCell = cell as? BookListCell {
            if indexPath.section == 1 {
                let book = books[indexPath.item]
                bookListCell.configure(with: book)
                bookListCell.delegate = self
            }
        } else if let recentBookCell = cell as? RecentBookCell {
            if indexPath.section == 0 {
                let recentBook = recentBooks[indexPath.item]
                recentBookCell.configure(with: recentBook)
                recentBookCell.delegate = self
            }
        }
        
        return cell
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
            if indexPath.section == 0 {
                headerView.configure(with: "최근 본 책")
            } else if indexPath.section == 1 {
                headerView.configure(with: "검색 결과")
            }
            return headerView
        }
        fatalError("Unexpected element kind: \(kind)")
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        
        guard let query = searchBar.text, !query.isEmpty else {
            showAlert2(title: "검색어 입력 필요", message: "검색어를 입력해 주세요.")
            return
        }
        searchBooks(query: query)
    }

    private func showAlert2(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "확인", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func saveRecentBooks() {
        do {
            let data = try JSONEncoder().encode(recentBooks)
            UserDefaults.standard.set(data, forKey: "recentBooks")
        } catch {
            print("Failed to save recent books: \(error)")
        }
    }
    
    private func loadRecentBooks() {
        if let data = UserDefaults.standard.data(forKey: "recentBooks") {
            do {
                recentBooks = try JSONDecoder().decode([BookModel].self, from: data)
            } catch {
                print("Failed to load recent books: \(error)")
            }
        } else {
            print("No recent books found in UserDefaults.")
        }
    }
    
    func updateRecentBooks(with book: BookModel) {
        if !recentBooks.contains(where: { $0.isbn == book.isbn }) {
            recentBooks.append(book)
            collectionView.reloadSections(IndexSet(integer: 0))
        } else {
            collectionView.reloadSections(IndexSet(integer: 0))
        }
    }
}
