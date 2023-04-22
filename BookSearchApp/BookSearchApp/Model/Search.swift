//
//  Search.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/22.
//

import Foundation

struct Search: Decodable {
    let numFound, start: Int
    let docs: [Doc]

    enum CodingKeys: String, CodingKey {
        case numFound = "num_found"
        case start, docs
    }
}

struct Doc: Codable {
    let key: String
    let type: String
    let seed: [String]
    let title, titleSuggest, titleSort: String
    let editionCount: Int
    let editionKey, publishDate: [String]
    let publishYear: [Int]
    let firstPublishYear: Int
    let isbn: [String]
    let lastModifiedI, ebookCountI: Int
    let ebookAccess: EbookAccess
    let hasFullText, publicScanB: Bool
    let readingLogCount, wantToReadCount, currentlyReadingCount, alreadyReadCount: Int?
    let publisher: [String]
    let language: [Language]?
    let authorKey, authorName: [String]
    let authorAlternativeName: [String]?
    let publisherFacet: [String]
    let version: Double
    let authorFacet: [String]
    let numberOfPagesMedian: Int?
    let coverEditionKey: String?
    let coverI: Int?
    let lcc, subject, subjectFacet: [String]?
    let lccSort: String?
    let subjectKey, person, place, time: [String]?
    let personKey, placeKey, timeFacet, personFacet: [String]?
    let placeFacet, timeKey, publishPlace, oclc: [String]?
    let idAmazon: [String]?

    enum CodingKeys: String, CodingKey {
        case key, type, seed, title
        case titleSuggest = "title_suggest"
        case titleSort = "title_sort"
        case editionCount = "edition_count"
        case editionKey = "edition_key"
        case publishDate = "publish_date"
        case publishYear = "publish_year"
        case firstPublishYear = "first_publish_year"
        case isbn
        case lastModifiedI = "last_modified_i"
        case ebookCountI = "ebook_count_i"
        case ebookAccess = "ebook_access"
        case hasFullText = "has_fulltext"
        case publicScanB = "public_scan_b"
        case readingLogCount = "readinglog_count"
        case wantToReadCount = "want_to_read_count"
        case currentlyReadingCount = "currently_reading_count"
        case alreadyReadCount = "already_read_count"
        case publisher, language
        case authorKey = "author_key"
        case authorName = "author_name"
        case authorAlternativeName = "author_alternative_name"
        case publisherFacet = "publisher_facet"
        case version = "_version_"
        case authorFacet = "author_facet"
        case numberOfPagesMedian = "number_of_pages_median"
        case coverEditionKey = "cover_edition_key"
        case coverI = "cover_i"
        case lcc, subject
        case subjectFacet = "subject_facet"
        case lccSort = "lcc_sort"
        case subjectKey = "subject_key"
        case person, place, time
        case personKey = "person_key"
        case placeKey = "place_key"
        case timeFacet = "time_facet"
        case personFacet = "person_facet"
        case placeFacet = "place_facet"
        case timeKey = "time_key"
        case publishPlace = "publish_place"
        case oclc
        case idAmazon = "id_amazon"
    }
}

enum EbookAccess: String, Codable {
    case noEbook = "no_ebook"
    case borrowable = "borrowable"
}

enum Language: String, Codable {
    case eng = "eng"
    case ger = "ger"
    case spa = "spa"
}
