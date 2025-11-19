import Foundation

final class OpenLibraryService: OpenLibraryServiceProtocol {
    
    struct Dependencies {
        let client: NetworkClientProtocol
    }

    private let client: NetworkClientProtocol

    init(dependencies: Dependencies) {
        self.client = dependencies.client
    }

    @discardableResult
    func searchBooks(query: String,
                     page: Int,
                     limit: Int,
                     completion: @escaping (Result<[Book], NetworkError>) -> Void) -> URLSessionDataTask? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            completion(.failure(.emptyQuery))
            return nil
        }

        guard let url = OpenLibraryEndpoint
            .search(query: trimmed, page: page, limit: limit)
            .url()
        else {
            completion(.failure(.invalidURL))
            return nil
        }

        return client.get(url) { (result: Result<OpenLibrarySearchResponseDTO, NetworkError>) in
            switch result {
            case .success(let dto):
                let books = dto.docs.compactMap { $0.toDomain() }
                completion(.success(books))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
}
