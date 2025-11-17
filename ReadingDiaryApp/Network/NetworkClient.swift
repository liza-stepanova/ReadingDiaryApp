import Foundation

struct NetworkClient: NetworkClientProtocol {

    private let session: URLSession
    private let decoder: JSONDecoder
    private let callbackQueue: DispatchQueue

    init(session: URLSession = .shared, callbackQueue: DispatchQueue = .main) {
        self.session = session
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .useDefaultKeys
        self.decoder = decoder
        self.callbackQueue = callbackQueue
    }

    @discardableResult
    func get<T: Decodable>(_ url: URL, completion: @escaping (Result<T, NetworkError>) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                return callbackQueue.async {
                    completion(.failure(.transport(error)))
                }
            }
            guard let http = response as? HTTPURLResponse else {
                return callbackQueue.async {
                    completion(.failure(.server(statusCode: -1)))
                }
            }

            guard (200..<300).contains(http.statusCode) else {
                return callbackQueue.async {
                    completion(.failure(.server(statusCode: http.statusCode)))
                }
            }
            guard let data = data else {
                return callbackQueue.async {
                    completion(.failure(.server(statusCode: -1)))
                }
            }
            do {
                let decoded = try decoder.decode(T.self, from: data)
                callbackQueue.async {
                    completion(.success(decoded))
                }
            } catch {
                callbackQueue.async {
                    completion(.failure(.decoding(error)))
                }
            }
        }
        task.resume()
        
        return task
    }

    @discardableResult
    func getData(_ url: URL, completion: @escaping (Result<Data, NetworkError>) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 20

        let task = session.dataTask(with: request) { data, response, error in
            if let error = error {
                return callbackQueue.async {
                    completion(.failure(.transport(error)))
                }
            }
            guard
                let http = response as? HTTPURLResponse,
                (200..<300).contains(http.statusCode),
                let data = data
            else {
                let code = (response as? HTTPURLResponse)?.statusCode ?? -1
                return callbackQueue.async {
                    completion(.failure(.server(statusCode: code)))
                }
            }
            callbackQueue.async {
                completion(.success(data))
            }
        }
        task.resume()
        
        return task
    }
    
}
