//
//  BookRequest.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

enum BookRequest: RequestProtocol {
    case search(String, String, Int)
    case cover(Int, String)
    
    var host: String {
        switch self {
        case .cover:
            return APIConstants.coverHost + APIConstants.host
        default:
            return APIConstants.host
        }
    }

    var path: String {
        switch self {
        case .search:
            return APIConstants.searchPath
        case .cover(let imageId, let imageSize):
            return APIConstants.coverPath + imageId.replacingCoverImageName(size: imageSize)
        }
    }
    
    var queries: [String : String] {
        switch self {
        case .search(let key, let value, let pageNumber):
            return [
                key: value.replacingSpacesWithPlus(),
                APIConstants.page: "\(pageNumber)"
            ]
        default:
            return [:]
        }
    }
}
