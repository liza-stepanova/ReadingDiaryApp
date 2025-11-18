import Foundation

struct OpenLibrarySearchResponseDTO: Decodable {
    
    let numFound: Int?
    let start: Int?
    let docs: [OpenLibraryDocDTO]

    enum CodingKeys: String, CodingKey {
        case numFound = "num_found"
        case start
        case docs
    }
    
}

struct OpenLibraryDocDTO: Decodable {
    
    let key: String?
    let title: String?
    let authorName: [String]?
    let coverId: Int?
    let firstPublishYear: Int?

    enum CodingKeys: String, CodingKey {
        case key, title
        case authorName = "author_name"
        case coverId = "cover_i"
        case firstPublishYear = "first_publish_year"
    }
    
}

struct Book: Hashable {
    
    let id: String
    let title: String
    let author: String
    let coverId: Int?
    let firstPublishYear: Int?

    func coverURL() -> URL? {
        guard let coverId = coverId else { return nil }
        var comps = URLComponents()
        comps.scheme = "https"
        comps.host = "covers.openlibrary.org"
        comps.path = "/b/id/\(coverId)-L.jpg"
        return comps.url
    }
    
}

extension OpenLibraryDocDTO {
    
    func toDomain() -> Book? {
        let rawKey = key ?? ""
        let workId = rawKey.replacingOccurrences(of: "/works/", with: "")
        let title = (self.title ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
        let author = (self.authorName?.first ?? "—").trimmingCharacters(in: .whitespacesAndNewlines)

        guard !workId.isEmpty, !title.isEmpty else { return nil }

        return Book(
            id: workId,
            title: title,
            author: author,
            coverId: coverId,
            firstPublishYear: firstPublishYear
        )
    }
    
}
