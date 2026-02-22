//
//  CartInteractor.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import Combine

protocol CartInteractor {
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> { get }
    func fetchCart() async throws -> [CartItem]
    func addToCart(product: Product) async throws
    func updateCart(product: Product, quantity: Int) async throws
}

final class CartInteractorImpl: CartInteractor {
    let cartRepository: CartRepository
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> {
        cartRepository.itemsPublisher
    }
    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }
    
    func fetchCart() async throws -> [CartItem] {
        return try await self.cartRepository.fetchCart()
    }
    
    func addToCart(product: Product) async throws {
        try await self.cartRepository.addToCart(product: product)
    }
    
    func updateCart(product: Product, quantity: Int) async throws {
        try await self.cartRepository.updateCart(product: product, quantity: quantity)
    }
}


//Note:
// Although the MockCartInteractor and CartInteractorImpl looks same but in real scenario when business logic updates added to CartInteractorImpl the logic will change

final class MockCartInteractor: CartInteractor {
    let cartRepository: CartRepository
    var cartItemsPublisher: AnyPublisher<[CartItem], Never> {
        cartRepository.itemsPublisher
    }
    
    init(cartRepository: CartRepository) {
        self.cartRepository = cartRepository
    }
    
    func fetchCart() async throws -> [CartItem] {
        return try await self.cartRepository.fetchCart()
    }
    
    func addToCart(product: Product) async throws {
        try await self.cartRepository.addToCart(product: product)
    }
    
    func updateCart(product: Product, quantity: Int) async throws {
        try await self.cartRepository.updateCart(product: product, quantity: quantity)
    }
}
