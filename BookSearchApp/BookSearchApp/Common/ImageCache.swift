//
//  ImageCache.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import UIKit.UIImage
import Combine

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let cachedImages = NSCache<NSString, UIImage>()
    private var cancellable = Set<AnyCancellable>()
    
    private func matchImage(name: NSString) -> UIImage? {
        return cachedImages.object(forKey: name)
    }
    
    private func saveCachedImage(name: String, image: UIImage) {
        cachedImages.setObject(image, forKey: name as NSString)
    }
    
    func load(imageName: String) -> Future<(UIImage, String), NetworkError> {
        if let image = matchImage(name: imageName as NSString) {
            return Future { promise in
                promise(.success((image, imageName)))
            }
        } else {
            return Future { [weak self] promise in
                guard let self = self else { return }
                NetworkManager().getCoverRequest(imageName: imageName)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { [weak self] imageData in
                        guard let image = UIImage(data: imageData) else {
                            promise(.failure(NetworkError.noneData))
                            return
                        }
                        self?.saveCachedImage(name: imageName, image: image)

                        promise(.success((image, imageName)))
                    })
                    .store(in: &self.cancellable)
            }
        }
    }
}
