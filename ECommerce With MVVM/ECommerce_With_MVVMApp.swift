//
//  ECommerce_With_MVVMApp.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 10/02/26.
//

import SwiftUI

@main
struct ECommerce_With_MVVMApp: App {
    let shopInteractor = ShopInteractorImpl(productRepository: ProductRepositoryImpl())
    let cartInteractor = CartInteractorImpl(cartRepository: CartRepositoryImpl())
    
    var body: some Scene {
        WindowGroup {
            TabView {
                ShopView(searchViewModel: SearchViewModel(cartInteractor: cartInteractor, shopInteractor: shopInteractor))
                    .tabItem {
                        Label("Shop", systemImage: "book")
                    }
                
                CartView(cartViewModel: CartViewModel(cartInteractor: cartInteractor))
                    .tabItem {
                        Label("Cart", systemImage: "cart")
                    }
            }
        }
    }
}
