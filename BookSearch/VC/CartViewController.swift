//
//  CartViewController.swift
//  BookSearch
//
//  Created by Leejh on 8/1/24.
//
//

import UIKit
import CoreData

class CartViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CartListCellDelegate {
    
    private var collectionView: UICollectionView!
    var books: [BookModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNav()
        setupCollectionView()
        view.backgroundColor = .white
        
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadBooksFromCoreData()
    }
    
    private func setupCollectionView() {
        let layout = createFlowLayout()
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        
        collectionView.register(CartListCell.self, forCellWithReuseIdentifier: "CartListCell")
        collectionView.register(CollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: CollectionHeaderView.reuseIdentifier)
        view.addSubview(collectionView)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func setupNav() {
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(trashButtonTapped))
        navigationItem.title = "담은 책"
        navigationItem.rightBarButtonItem = addButton
        navigationItem.leftBarButtonItem = trashButton
    }
    
    @objc private func addButtonTapped() {
        print("추가버튼 클릭됨") // 구현필요
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
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CartListCell", for: indexPath) as! CartListCell
        let book = books[indexPath.item]
        cell.configure(with: book)
        cell.delegate = self
        return cell
    }
    
    private func loadBooksFromCoreData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<BookNum> = BookNum.fetchRequest()
        
        do {
            let bookEntities = try managedContext.fetch(fetchRequest)
            books = bookEntities.map { bookEntity in
                BookModel(
                    isbn: "",
                    title: bookEntity.title ?? "",
                    contents: "",
                    authors: bookEntity.authors?.components(separatedBy: ", ") ?? [],
                    salePrice: Int(bookEntity.bookPrice),
                    thumbnail: ""
                )
            }
            collectionView.reloadData()
        } catch let error as NSError {
            handleError(error)
        }
    }
    
    @objc private func trashButtonTapped() {
        let alertController = UIAlertController(title: "모든 책 삭제", message: "정말로 모든 책을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteAllBooks()
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func deleteAllBooks() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest: NSFetchRequest<BookNum> = BookNum.fetchRequest()
        
        do {
            let bookEntities = try managedContext.fetch(fetchRequest)
            for bookEntity in bookEntities {
                managedContext.delete(bookEntity)
            }
            try managedContext.save()
            
            books.removeAll()
            collectionView.reloadData()
        } catch let error as NSError {
            handleError(error)
        }
    }
    
    private func deleteBook(at indexPath: IndexPath) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<BookNum> = BookNum.fetchRequest()
        
        do {
            let bookEntities = try managedContext.fetch(fetchRequest)
            let bookToDelete = bookEntities[indexPath.item]
            managedContext.delete(bookToDelete)
            try managedContext.save()
            
            books.remove(at: indexPath.item)
            collectionView.deleteItems(at: [indexPath])
        } catch let error as NSError {
            handleError(error)
        }
    }
    
    private func showDeleteConfirmation(for indexPath: IndexPath) {
        let alertController = UIAlertController(title: "책 삭제", message: "이 책을 삭제하시겠습니까?", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.deleteBook(at: indexPath)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    func didSwipeCell(_ cell: CartListCell) {
        if let indexPath = collectionView.indexPath(for: cell) {
            showDeleteConfirmation(for: indexPath)
        }
    }
    
    private func handleError(_ error: NSError) {
        print("Error: \(error.localizedDescription)")
    }
}
