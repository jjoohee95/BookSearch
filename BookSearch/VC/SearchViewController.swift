//
//  SearchViewController.swift
//  BookSearch
//
//  Created by Leejh on 8/1/24.
//

import UIKit

struct Book {
    let title: String
    let author: String
    let price: String
}

class SearchViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate{
    
    
    private var collectionView: UICollectionView!
    
    private var books: [Book] = [
        Book(title: "책 제목 1", author: "저자 1", price: "14,000₩"),
        Book(title: "책 제목 2", author: "저자 2", price: "15,000₩"),
        Book(title: "책 제목 3", author: "저자 3", price: "20,000₩"),
        // 더미 데이터 추가
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        setupCollectionView()
        view.backgroundColor = .white
    }
    
    private func setupCollectionView() {
        let layout = createCompositionalLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.register(BookListCell.self, forCellWithReuseIdentifier: "BookListCell")
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: "header", withReuseIdentifier: CollectionHeaderView.reuseIdentifier) // 여기서 등록
        
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
        let searchBar: UISearchBar = {
            let search = UISearchBar()
            search.placeholder = "검색어를 입력하세요"
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
        print("검색버튼이 클릭되었습니다")
    }
    
    
    private func createCompositionalLayout() -> UICollectionViewLayout {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60))
        let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerSize, elementKind: "header", alignment: .topTrailing)
        
        // 아이템 3가지 정의
        let bookTitleItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let bookTitleItem = NSCollectionLayoutItem(layoutSize: bookTitleItemSize)
        
        let authorsItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(70))
        let authorsItem = NSCollectionLayoutItem(layoutSize: authorsItemSize)
        
        let bookPriceItemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(100))
        let bookPriceItem = NSCollectionLayoutItem(layoutSize: bookPriceItemSize)
        
        
        // 그룹 크기 및 섹션 설정
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(120))
        let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [bookTitleItem, authorsItem, bookPriceItem])
        
        group.interItemSpacing = NSCollectionLayoutSpacing.fixed(10)
        
        let section = NSCollectionLayoutSection(group: group)
        
        section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24)
        
        //        section.interGroupSpacing = 20
        
        section.boundarySupplementaryItems = [header]
        
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BookListCell", for: indexPath) as! BookListCell
        
        let book = books[indexPath.item]
        cell.bookTitle.text = book.title
        cell.authors.text = book.author
        cell.bookPrice.text = book.price
        
        return cell
    }
    
    func    collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == "header" {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: CollectionHeaderView.reuseIdentifier, for: indexPath) as! CollectionHeaderView
            headerView.configure(with: "검색 결과")
            return headerView
        }
        fatalError("Unexpected element kind")
    }
    
}
