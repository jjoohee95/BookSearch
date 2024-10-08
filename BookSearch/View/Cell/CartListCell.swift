//
//  BookListCell.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/1/24.
//

// 컬렉션뷰셀 -  책 제목, 저자, 가격
// 셀 클릭시 상세페이지 모달 띄우기
import UIKit

protocol CartListCellDelegate: AnyObject {
    func didSwipeCell(_ cell: CartListCell)
}

class CartListCell: UICollectionViewCell {
    
    weak var delegate: CartListCellDelegate?
    
    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 16)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let authors: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = .gray
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bookPrice: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 12)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        addSwipeGestureRecognizer() // Add swipe gesture recognizer
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        [bookTitle, authors, bookPrice].forEach { contentView.addSubview($0) }
        
        contentView.layer.borderColor = UIColor.lightGray.cgColor
        contentView.layer.borderWidth = 1.0
        
        NSLayoutConstraint.activate([
            bookTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bookTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bookTitle.trailingAnchor.constraint(equalTo: authors.leadingAnchor, constant: -8),
            
            authors.centerYAnchor.constraint(equalTo: bookTitle.centerYAnchor),
            authors.trailingAnchor.constraint(equalTo: bookPrice.leadingAnchor, constant: -8),
            authors.widthAnchor.constraint(equalToConstant: 80),
            
            bookPrice.centerYAnchor.constraint(equalTo: bookTitle.centerYAnchor),
            bookPrice.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bookPrice.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    private func addSwipeGestureRecognizer() {
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe))
        swipeGesture.direction = .left // Set swipe direction (e.g., left swipe)
        contentView.addGestureRecognizer(swipeGesture)
    }
    
    @objc private func handleSwipe() {
        delegate?.didSwipeCell(self)
    }
    
    func configure(with book: BookModel) {
        bookTitle.text = book.title
        authors.text = book.authors.joined(separator: ", ")
        bookPrice.text = "\(book.salePrice)원"
    }
}
