//
//  String + Extension.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

extension String {
    func replacingSpacesWithPlus() -> String {
        return self.replacingOccurrences(
            of: " ",
            with: "+"
        )
    }
}
