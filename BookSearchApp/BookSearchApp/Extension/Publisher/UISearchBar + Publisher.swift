//
//  UISearchBar + Publisher.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/23.
//

import UIKit
import Combine

extension UISearchTextField {
    var textPublisher: AnyPublisher<String, Never> {
        NotificationCenter.default
            .publisher(for: UISearchTextField.textDidChangeNotification, object: self)
            .compactMap { $0.object as? UITextField }
            .compactMap(\.text)
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main)
            .filter{$0.count > 0 }
            .eraseToAnyPublisher()
    }
}
