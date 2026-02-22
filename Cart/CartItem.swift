//
//  CartItem.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

struct CartItem: Identifiable {
    var product: Product
    var quantity: Int
    
    var id: Int { product.id }
}
