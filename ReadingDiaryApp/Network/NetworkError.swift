import Foundation

enum NetworkError: Error, LocalizedError {
    
    case emptyQuery
    case invalidURL
    case transport(Error)
    case server(statusCode: Int)
    case decoding(Error)

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Пустой запрос"
        case .invalidURL:
            return "Неверный URL"
        case .transport(let err):
            return "Ошибка сети: \(err.localizedDescription)"
        case .server(let code):
            return "Ошибка сервера (\(code)) "
        case .decoding(let err):
            return "Ошибка декодирования данных: \(err.localizedDescription)"
        }
    }
    
}

extension NetworkError {
    var isCancelled: Bool {
        if case let .transport(err) = self {
            return (err as NSError).code == NSURLErrorCancelled
        }
        return false
    }
}
