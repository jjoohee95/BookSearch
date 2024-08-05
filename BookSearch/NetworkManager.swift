//
//  NetworkManager.swift
//  BookSearch
//
//  Created by t2024-m0153 on 8/4/24.
//

import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    
    private let apiKey = "f818bff85f9c42507dcd642544d3b7d9"
    private let baseUrl = "https://dapi.kakao.com/v3/search/book"
    
    private init() {}
    
    func fetchData(query: String) async throws -> [BookModel] {

        let urlString = "\(baseUrl)?query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        guard let url = URL(string: urlString) else {
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
}

enum NetworkError: Error {
    case invalidURL
    case invalidResponse
    case noData
}

struct BookResponse: Codable {
    let documents: [BookModel]
}
