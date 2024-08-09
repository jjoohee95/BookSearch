//
//  RecentBookCell.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/9/24.
//

import UIKit

protocol RecentBookCellDelegate: AnyObject {
    func didTapRecentBookCell(_ cell: RecentBookCell)
}

class RecentBookCell: UICollectionViewCell {
    weak var delegate: RecentBookCellDelegate?
    
    private let posterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 50
        imageView.layer.masksToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let bookTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        [posterImageView, bookTitle].forEach { contentView.addSubview($0) }

        NSLayoutConstraint.activate([
            posterImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            posterImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            posterImageView.widthAnchor.constraint(equalToConstant: 100),
            posterImageView.heightAnchor.constraint(equalToConstant: 100),

            bookTitle.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 8),
            bookTitle.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            bookTitle.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            bookTitle.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
        ])

        addTapGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        posterImageView.image = nil
        bookTitle.text = nil
    }
    
    private func addTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleTap() {
        delegate?.didTapRecentBookCell(self)
    }
    
    func configure(with book: BookModel) {
        if let url = URL(string: book.thumbnail) {
            posterImageView.loadImage(from: url)
        } else {
            posterImageView.image = UIImage(named: book.thumbnail)
        }
        bookTitle.text = book.title
    }
}

extension UIImageView {
    func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Failed to load image: \(error)")
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                print("No data or image conversion failed")
                return
            }
            DispatchQueue.main.async {
                self?.image = image
            }
        }.resume()
    }
}

