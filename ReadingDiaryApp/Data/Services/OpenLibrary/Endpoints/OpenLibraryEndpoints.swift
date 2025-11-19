import Foundation

enum OpenLibraryEndpoint {
    
    case search(query: String, page: Int, limit: Int)

    func url() -> URL? {
        switch self {
        case let .search(query, page, limit):
            var comps = URLComponents()
            comps.scheme = "https"
            comps.host = "openlibrary.org"
            comps.path = "/search.json"
            comps.queryItems = [
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "page", value: String(max(1, page))),
                URLQueryItem(name: "limit", value: String(max(1, limit))),
                URLQueryItem(name: "fields", value: "key,title,author_name,cover_i,first_publish_year")
            ]
            return comps.url
        }
    }
    
}
