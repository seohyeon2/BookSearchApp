//
//  SendDataDelegate.swift
//  BookSearchApp
//
//  Created by seohyeon park on 2023/04/24.
//

protocol SendDataDelegate: AnyObject {
    func sendData<T>(
        _ data: T
    )
}
