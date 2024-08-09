//
//  BookInfoViewController.swift
//  BookSearch
//
//  Created by Leejh on 8/1/24.
//

import UIKit

protocol BookInfoViewControllerDelegate: AnyObject {
    func didAddBook(_ book: BookModel)
}

class BookInfoViewController: UIViewController {
    
    weak var delegate: BookInfoViewControllerDelegate?
    
    var book: BookModel?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let headerView =  UIView()
    
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 24)
        label.numberOfLines = 2
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let authors: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = .systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let posterImageView: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private let bookPrice: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .boldSystemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let detailLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var cartButton: UIButton = {
        let button = UIButton()
        button.setTitle("담기", for: .normal)
        button.backgroundColor = .systemMint
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var cancelButton: UIButton = {
        let button = UIButton()
        button.setTitle("X", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.systemMint, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.systemMint.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillProportionally
        stackView.alignment = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        configure()
        setupConstraints()
        
        cartButton.addTarget(self, action: #selector(cartButtonTapped), for: .touchUpInside)
    }
    
    private func configure() {
        if let book = book {
            titleLabel.text = book.title
            authors.text = book.authors.joined(separator: ", ")
            bookPrice.text = "\(book.salePrice)원"
            detailLabel.text = book.contents
            
            Task {
                do {
                    if let image = try await NetworkManager.shared.loadImage(from: book.thumbnail) {
                        posterImageView.image = image
                    }
                } catch {
                    print("Failed to load image: \(error.localizedDescription)")
                }
            }
        }
    }
    
    private func setupConstraints() {
        view.addSubview(headerView)
        [titleLabel, authors, posterImageView, bookPrice].forEach { headerView.addSubview($0) }
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(detailLabel)
        
        view.addSubview(buttonStackView)
        [cancelButton, cartButton].forEach { buttonStackView.addArrangedSubview($0) }
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            headerView.heightAnchor.constraint(equalToConstant: 100),
            
            titleLabel.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 40),
            titleLabel.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor),
            
            authors.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            authors.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            authors.heightAnchor.constraint(equalToConstant: 16),
            
            posterImageView.topAnchor.constraint(equalTo: authors.bottomAnchor, constant: 8),
            posterImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            posterImageView.widthAnchor.constraint(equalToConstant: 240),
            posterImageView.heightAnchor.constraint(equalTo: posterImageView.widthAnchor, multiplier: 1.6),
            
            bookPrice.topAnchor.constraint(equalTo: posterImageView.bottomAnchor, constant: 16),
            bookPrice.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            
            scrollView.topAnchor.constraint(equalTo: bookPrice.bottomAnchor, constant: 24),
            scrollView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            scrollView.bottomAnchor.constraint(equalTo: buttonStackView.topAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            detailLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            detailLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            detailLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            detailLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -16),
            
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            buttonStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24),
            buttonStackView.heightAnchor.constraint(equalToConstant: 60),
            
            cancelButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 1/4),
            cancelButton.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor),
            
            cartButton.widthAnchor.constraint(equalTo: buttonStackView.widthAnchor, multiplier: 3/4),
            cartButton.heightAnchor.constraint(equalTo: buttonStackView.heightAnchor)
        ])
    }
    
    @objc private func cartButtonTapped() {
           guard let book = book else { return }
           
           let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
           
           let bookNum = BookNum(context: context)
           bookNum.title = book.title
           bookNum.authors = book.authors.joined(separator: ", ")
           bookNum.bookPrice = Int64(book.salePrice)
           
           do {
               try context.save()

               delegate?.didAddBook(book)
               
               let alert = UIAlertController(title: "성공", message: "책이 담기 목록에 추가되었습니다.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "확인", style: .default))
               self.present(alert, animated: true)
               
           } catch {
               let alert = UIAlertController(title: "오류", message: "책을 저장하는 중 오류가 발생했습니다. 다시 시도해 주세요.", preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "확인", style: .default))
               self.present(alert, animated: true)
           }
       }
}


