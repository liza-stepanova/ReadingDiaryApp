import UIKit

protocol ImageLoaderProtocol: AnyObject {
    
    @discardableResult
    func load(_ url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) -> URLSessionDataTask?

    func cachedImage(for url: URL) -> UIImage?
    func cancel(task: URLSessionDataTask)
    
}

final class ImageLoader: ImageLoaderProtocol {
    
    struct Limits {
        let count: Int
        let totalCost: Int
        static let `default` = Limits(count: 300, totalCost: 64 * 1024 * 1024)
    }
    
    private let client: NetworkClientProtocol
    private let cache = NSCache<NSURL, UIImage>()

    init(client: NetworkClientProtocol, limits: Limits = .default) {
        self.client = client
        cache.countLimit = limits.count
        cache.totalCostLimit = limits.totalCost
    }

    func cachedImage(for url: URL) -> UIImage? {
        cache.object(forKey: url as NSURL)
    }

    @discardableResult
    func load(_ url: URL, completion: @escaping (Result<UIImage, NetworkError>) -> Void) -> URLSessionDataTask? {
        if let img = cachedImage(for: url) {
            completion(.success(img))
            return nil
        }
        return client.getData(url) { [weak self] result in
            switch result {
            case .success(let data):
                if let image = UIImage(data: data) {
                    let cost = ImageLoader.cost(for: image)
                    self?.cache.setObject(image, forKey: url as NSURL, cost: cost)
                    completion(.success(image))
                } else {
                    completion(.failure(.decoding(NSError(domain: "image", code: 0))))
                }
            case .failure(let err):
                completion(.failure(err))
            }
        }
    }

    func cancel(task: URLSessionDataTask) {
        task.cancel()
    }
    
    private static func cost(for image: UIImage) -> Int {
        let width = Int(image.size.width * image.scale)
        let height = Int(image.size.height * image.scale)
        return width * height * 4
    }
    
}
