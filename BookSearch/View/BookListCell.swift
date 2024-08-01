//
//  BookListCell.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/1/24.
//


// 컬렉션뷰셀 -  책 제목, 저자, 가격
// 셀 클릭시 상세페이지 모달 띄우기

import UIKit

class BookListCell: UICollectionViewCell {
    
    let bookTitle: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 20)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let authors: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let bookPrice: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = .black
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [bookTitle,authors,bookPrice].forEach { contentView.addSubview($0) }
        
        contentView.layer.borderColor = UIColor.lightGray.cgColor
                contentView.layer.borderWidth = 1.0 // 보더라인 두께
        
        NSLayoutConstraint.activate([
            // bookTitle 제약 조건
            bookTitle.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            bookTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            bookTitle.trailingAnchor.constraint(equalTo: authors.leadingAnchor, constant: -8),
            
            // authors 제약 조건
            authors.centerYAnchor.constraint(equalTo: bookTitle.centerYAnchor),
            authors.trailingAnchor.constraint(equalTo: bookPrice.leadingAnchor, constant: -8),
            authors.widthAnchor.constraint(equalToConstant: 80), // 필요에 따라 조정
            
            // bookPrice 제약 조건
            bookPrice.centerYAnchor.constraint(equalTo: bookTitle.centerYAnchor),
            bookPrice.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            bookPrice.widthAnchor.constraint(equalToConstant: 60) // 필요에 따라 조정
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
