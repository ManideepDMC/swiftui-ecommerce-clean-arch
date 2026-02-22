//
//  ProductDetailsViewModel.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 20/02/26.
//

import Foundation
import Combine

final class ProductDetailsViewModel: ObservableObject {
    
    let product: Product
    @Published var quantity: Int
    let cartInteractor: CartInteractor
    private var cancellables = Set<AnyCancellable>()
    
    var name: String { product.name }
    
    var price: String { "$ \(String(format: "%.2f", product.price)) per \(product.size)" }
    
    var description: String { product.description }
    
    var imagePath: URL? { URL(string: product.imagePath) }
    
    
    init(product: Product, quantity: Int, cartInteractor: CartInteractor) {
        self.product = product
        self.quantity = quantity
        self.cartInteractor = cartInteractor
        addCartObserver()
    }
    
    func addCartObserver() {
        cartInteractor.cartItemsPublisher
            .map { items in
                items.filter { $0.product.id == self.product.id }.first?.quantity ?? 0
            }
            .receive(on: DispatchQueue.main)
            .assign(to: \.quantity, on: self)
            .store(in: &cancellables)
    }
    
    func addToCart() async {
        do {
            try await cartInteractor.addToCart(product: product)
        } catch {
            print("error adding product to cart ::\(error.localizedDescription)")
        }
    }
    
    func updateCart(quantity: Int) async {
        do {
            try await cartInteractor.updateCart(product: product, quantity: quantity)
        } catch {
            print("error removing product from cart ::\(error.localizedDescription)")
        }
    }
}
