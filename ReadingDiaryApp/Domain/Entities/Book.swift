import Foundation

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
