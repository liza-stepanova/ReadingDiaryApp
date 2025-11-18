import Foundation

protocol NetworkClientProtocol {
    
    @discardableResult
    func get<T: Decodable>(_ url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) -> URLSessionDataTask
    @discardableResult
    func getData(_ url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask
    
}
