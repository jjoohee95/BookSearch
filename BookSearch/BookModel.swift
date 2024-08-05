//
//  BookModel.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/4/24.
//

import Foundation

struct BookModel: Codable { // ❤️
    let title: String
    let contents: String
    let authors: [String]
    let salePrice: Int
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case contents
        case authors
        case salePrice = "sale_price"
        case thumbnail
    }
}
