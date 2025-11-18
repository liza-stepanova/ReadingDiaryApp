import Foundation

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
