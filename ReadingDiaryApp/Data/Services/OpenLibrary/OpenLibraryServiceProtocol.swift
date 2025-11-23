import Foundation

protocol OpenLibraryServiceProtocol {
    
    @discardableResult
    func searchBooks(query: String,
                     page: Int,
                     limit: Int,
                     completion: @escaping (Result<[Book], NetworkError>) -> Void) -> URLSessionDataTask?
    
}
