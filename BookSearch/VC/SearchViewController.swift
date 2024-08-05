//
//  SearchViewController.swift
//  BookSearch
//
//  Created by Leejh on 8/1/24.
//

import UIKit

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UISearchBarDelegate {
    
    
    private var collectionView: UICollectionView!
    private var searchBar: UISearchBar! // 클래스 변수로 선언
    
    
    
    var books: [BookModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        view.backgroundColor = .white
        
    }
    
    private func setupCollectionView() {
        let layout = createFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: "BookListCell")
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
        searchBar = {
            let search = UISearchBar()
            search.placeholder = "검색어를 입력하세요"
            search.delegate = self
            return search
        }()
        
        let searchButton: UIBarButtonItem = {
            let button = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchButtonTapped))
            return button
        }()
        
        navigationItem.titleView = searchBar
        navigationItem.rightBarButtonItem = searchButton
    }
    
    
    @objc private func searchButtonTapped() {
        guard let query = searchBar.text, !query.isEmpty else { return
            
            print("검색어를 입력해 주세요")
        }
        searchBooks(query: query)
    }
    
    func searchBooks(query : String) {
        Task {
            do {
                let fetchedBooks = try await NetworkManager.shared.fetchData(query: query)
                await MainActor.run {
                    self.books = fetchedBooks
                    self.collectionView.reloadData()
                }
            } catch {
                await MainActor.run {
                    print("오류 발생 : \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    private func createFlowLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: view.frame.width - 48, height: 80)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        layout.headerReferenceSize = CGSize(width: view.frame.width, height: 60)
        layout.minimumLineSpacing = 10
        return layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCell", for: indexPath) as! BookListCell
        
        let book = books[indexPath.item]
        cell.configure(with: book)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
            headerView.configure(with: "검색 결과")
            return headerView
        }
        fatalError("Unexpected element kind: \(kind)")
    }
    
}

