//
//  ProductsSort.swift
//  NotifyExpiryDate (iOS)
//
//  Created by saj panchal on 2021-12-19.
//

import Foundation

struct ProductsSort: Hashable, Identifiable {
    let id: Int
    
    let name: String
    
    let descriptors: [NSSortDescriptor]
    
    static let sorts: [ProductsSort] = [
        ProductsSort(id: 0, name: "Expiry Date", descriptors: [NSSortDescriptor(keyPath: \Product.expiryDate, ascending: true)]),
        ProductsSort(id: 1, name: "Product Name", descriptors: [NSSortDescriptor(keyPath: \Product.name, ascending: true)]),
        ProductsSort(id: 2, name: "Last Modified", descriptors: [NSSortDescriptor(keyPath: \Product.dateStamp, ascending: false)])
    ]
    
    static var `default`: ProductsSort {sorts[0]}
}
