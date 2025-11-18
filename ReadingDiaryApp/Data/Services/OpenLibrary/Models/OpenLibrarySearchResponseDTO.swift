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
