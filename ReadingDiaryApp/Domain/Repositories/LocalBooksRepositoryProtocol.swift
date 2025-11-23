import Foundation

protocol LocalBooksRepositoryProtocol {
    
    func fetchFavorites(completion: @escaping (Result<[LocalBook], Error>) -> Void)
    func fetchMyBooks(filter: MyBooksFilter, completion: @escaping (Result<[LocalBook], Error>) -> Void)
    
    func upsert(_ book: LocalBook, completion: @escaping (Result<Void, Error>) -> Void)
    func updateStatus(bookId: String, status: ReadingStatus, completion: @escaping (Result<Void, Error>) -> Void)
    func toggleFavorite(bookId: String, isFavorite: Bool, completion: @escaping (Result<Void, Error>) -> Void)
    func delete(bookId: String, completion: @escaping (Result<Void, Error>) -> Void)
    
    func fetch(byIDs ids: [String], completion: @escaping (Result<[String: LocalBook], Error>) -> Void)
    func updateCoverData(bookId: String, data: Data?, completion: @escaping (Result<Void, Error>) -> Void)
    
}
