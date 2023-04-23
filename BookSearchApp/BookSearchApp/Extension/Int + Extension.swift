//
//  Int + Extension.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

extension Int {
    func replacingCoverImageName(size: String) -> String {
        return "\(self)-\(size).jpg"
    }
}
