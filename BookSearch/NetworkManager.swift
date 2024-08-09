//
//  NetworkManager.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/4/24.
//

import Foundation
import UIKit

class NetworkManager {
    static let shared = NetworkManager()
    
    private let apiKey = "f818bff85f9c42507dcd642544d3b7d9"
    private let baseUrl = "https://dapi.kakao.com/v3/search/book"
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private init() {}
    
    func fetchData(query: String) async throws -> [BookModel] {
        var components = URLComponents(string: baseUrl)
        components?.queryItems = [URLQueryItem(name: "query", value: query)]
        
        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.addValue("KakaoAK \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let (data, urlResponse) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = urlResponse as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.invalidResponse
        }
        
        let bookResponse = try JSONDecoder().decode(BookResponse.self, from: data)
        return bookResponse.documents
    }
    
    func loadImage(from urlString: String) async throws -> UIImage? {
        guard let url = URL(string: urlString) else {
            return nil
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        guard let image = UIImage(data: data) else {
            print("Failed to create image from data.")
            return nil
        }
        
        return image
    }
    
}

struct BookResponse: Codable {
    let documents: [BookModel]
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
    case decodingError
}
