//
//  ImageCache.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation
import Combine

final class ImageCache {
    static let shared = ImageCache()
    private init() {}
    
    private let cachedImagesData = NSCache<NSString, NSData>()
    private var cancellable = Set<AnyCancellable>()
    
    private func matchImage(name: NSString) -> Data? {
        return cachedImagesData.object(forKey: name) as Data?
    }
    
    private func saveCachedImage(name: String, imageData: Data) {
        cachedImagesData.setObject(
            imageData as NSData,
            forKey: name as NSString
        )
    }
    
    func load(imageId: Int, imageSize: String) -> Future<(Data, String), NetworkError> {
        let imageName = imageId.replacingCoverImageName(size: imageSize)
        if let image = matchImage(name: imageName as NSString) {
            return Future { promise in
                promise(.success((image, imageName)))
            }
        } else {
            return Future { [weak self] promise in
                guard let self = self else { return }
                NetworkManager().getCoverRequest(imageId: imageId, imageSize: imageSize)
                    .sink(receiveCompletion: { completion in
                        switch completion {
                        case .finished:
                            break
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }, receiveValue: { [weak self] imageData in
                        self?.saveCachedImage(name: imageName, imageData: imageData)

                        promise(.success((imageData, imageName)))
                    })
                    .store(in: &self.cancellable)
            }
        }
    }
}
