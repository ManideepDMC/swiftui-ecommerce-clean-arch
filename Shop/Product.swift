//
//  Product.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

struct Product: Decodable, Hashable {
    let id: Int
    let name: String
    let description: String
    let price: Double
    let imagePath: String
    let size: String
}
