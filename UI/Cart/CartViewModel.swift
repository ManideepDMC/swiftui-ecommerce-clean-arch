//
//  CartViewModel.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import Foundation
import Combine

@MainActor
class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    let cartInteractor: CartInteractor
    
    init(cartInteractor: CartInteractor) {
        self.cartInteractor = cartInteractor
        addCartObserver()
    }
    
    func addCartObserver() {
        cartInteractor.cartItemsPublisher
            .assign(to: &$cartItems)
    }
    
    func fetchCart() async {
        do {
           let cartItems = try await self.cartInteractor.fetchCart()
           self.cartItems = cartItems
        } catch {
            print("the error is \(error.localizedDescription)")
        }
    }
    
    func updateCart(_ cartItem: CartItem, quantity: Int) async {
        do {
            try await self.cartInteractor.updateCart(product: cartItem.product, quantity: quantity)
        } catch {
            print("error in adding to cart :: \(error.localizedDescription)")
        }
    }
}

    
    
