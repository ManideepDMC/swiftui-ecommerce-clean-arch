//
//  SearchViewModel.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import Foundation
import Combine

@MainActor
class SearchViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var productQuantities: [Int:Int] = [:]
    @Published var searchText: String = ""
    let cartInteractor: CartInteractor
    let shopInteractor: ShopInteractor
    private var cancellables = Set<AnyCancellable>()
    
    init(cartInteractor: CartInteractor, shopInteractor: ShopInteractor) {
        self.shopInteractor = shopInteractor
        self.cartInteractor = cartInteractor
        addCartObserver()
    }
    
    func addCartObserver() {
        cartInteractor.cartItemsPublisher
            .map { items in
                Dictionary(
                    uniqueKeysWithValues:
                        items.map { ($0.product.id, $0.quantity) }
                )
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.productQuantities, on: self)
            .store(in: &cancellables)
    }
    
    func fetchProducts() async {
        guard !searchText.isEmpty else {
            self.products = []
            return
        }
        do {
            let products = try await self.shopInteractor.fetchProducts(for: searchText)
            self.products = products
        } catch {
            print("error fetching products :: \(error.localizedDescription)")
        }
    }
    
    func addToCart(product: Product) async {
        do {
            try await cartInteractor.addToCart(product: product)
        } catch {
            print("error adding product to cart ::\(error.localizedDescription)")
        }
    }
    
    func updateCart(product: Product, quantity: Int) async {
        do {
            try await cartInteractor.updateCart(product: product, quantity: quantity)
        } catch {
            print("error removing product from cart ::\(error.localizedDescription)")
        }
    }
}

        
