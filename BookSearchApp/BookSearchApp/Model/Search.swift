//
//  Search.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation

struct Search: Decodable {
    let numFound: Int
    let start: Int
    let docs: [Doc]

    enum CodingKeys: String, CodingKey {
        case numFound = "num_found"
        case start
        case docs
    }
}

struct Doc: Decodable {
    let coverI: Int?
    let hasFullText: Bool?
    let editionCount: Int?
    let title: String?
    let authorName: [String]?
    let firstPublishYear: Int?
    let key: String?
    let ia: [String]?
    let authorKey: [String]?
    let publicScanB: Bool?

    enum CodingKeys: String, CodingKey {
        case coverI = "cover_i"
        case hasFullText = "has_fulltext"
        case editionCount = "edition_count"
        case title
        case authorName = "author_name"
        case firstPublishYear = "first_publish_year"
        case key
        case ia
        case authorKey = "author_key"
        case publicScanB = "public_scan_b"
    }
}
