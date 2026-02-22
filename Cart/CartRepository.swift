//
//  CartRepository.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import Foundation
import Combine

protocol CartRepository {
    var itemsPublisher: AnyPublisher<[CartItem], Never> { get }
    func fetchCart() async throws -> [CartItem]
    func addToCart(product: Product) async throws
    func updateCart(product: Product, quantity: Int) async throws
}

class CartRepositoryImpl: CartRepository {
    @Published private(set) var cartItems: [CartItem] = []
    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        $cartItems.eraseToAnyPublisher()
    }
    func fetchCart() async throws -> [CartItem] {
        return cartItems
    }
    
    func addToCart(product: Product) async throws {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            cartItems.append(CartItem(product: product, quantity: 1))
        }
    }
    
    func updateCart(product: Product, quantity: Int) async throws {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                cartItems.remove(at: index)
            } else {
                cartItems[index].quantity = quantity
            }
        }
    }
}

class MockCartRepository: CartRepository {
    private let cartItemsSubject = CurrentValueSubject<[CartItem], Never>([])

    var cartItems: [CartItem] {
        get { cartItemsSubject.value }
        set { cartItemsSubject.send(newValue) }
    }

    var shouldThrowOnFetch = false
    var shouldThrowOnAdd = false
    var shouldThrowOnUpdate = false

    var addToCartCallCount = 0
    var updateCartCallCount = 0

    var itemsPublisher: AnyPublisher<[CartItem], Never> {
        cartItemsSubject.eraseToAnyPublisher()
    }

    func fetchCart() async throws -> [CartItem] {
        if shouldThrowOnFetch { throw URLError(.badServerResponse) }
        return cartItems
    }

    func addToCart(product: Product) async throws {
        addToCartCallCount += 1
        if shouldThrowOnAdd { throw URLError(.badServerResponse) }
        var items = cartItems
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += 1
        } else {
            items.append(CartItem(product: product, quantity: 1))
        }
        cartItems = items
    }

    func updateCart(product: Product, quantity: Int) async throws {
        updateCartCallCount += 1
        if shouldThrowOnUpdate { throw URLError(.badServerResponse) }
        var items = cartItems
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            if quantity <= 0 {
                items.remove(at: index)
            } else {
                items[index].quantity = quantity
            }
        }
        cartItems = items
    }
}
