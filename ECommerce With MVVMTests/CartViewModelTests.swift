//
//  CartViewModelTests.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 16/02/26.
//

import XCTest
@testable import ECommerce_With_MVVM

@MainActor
final class CartViewModelTests: XCTestCase {
    
    var mockRepository: MockCartRepository!
    var mockInteractor: MockCartInteractor!
    var viewModel: CartViewModel!
    
    // MARK: - Life cycle
    override func setUpWithError() throws {
        mockRepository = MockCartRepository()
        mockInteractor = MockCartInteractor(cartRepository: mockRepository)
        viewModel = CartViewModel(cartInteractor: mockInteractor)
    }
    
    override func tearDownWithError() throws {
//        mockRepository = nil
//        mockInteractor = nil
//        viewModel = nil
    }
    
    // MARK: - Helpers
    
    private func createProduct(id: Int = 100, name: String = "Apple", description: String = "Fresh and juicy oranges sourced from organic farms.", price: Double = 2.0, size: String = "1.2kg") -> Product {
        Product(id: id, name: name, description: description, price: price, imagePath: "", size: size)
    }
    
    private func createCartItem(product: Product, quantity: Int) -> CartItem {
        CartItem(product: product, quantity: quantity)
    }
    
    // MARK: - test cases
    
    func test_fetchCart_empty() async {
        mockRepository.cartItems = []
        await viewModel.fetchCart()
        XCTAssertTrue(viewModel.cartItems.isEmpty)
    }
    
    func test_fetchCart_notEmpty() async {
        let product = createProduct()
        let cartItem = CartItem(product: product, quantity: 2)
        mockRepository.cartItems = [cartItem]
        await viewModel.fetchCart()
        XCTAssertEqual(viewModel.cartItems.count, 1)
        XCTAssertEqual(viewModel.cartItems.first?.product.name, "Apple")
        XCTAssertEqual(viewModel.cartItems.first?.product.id, 100)
        XCTAssertEqual(viewModel.cartItems.first?.product.price, 2.0)
    }
    
    func test_fetchCart_MultipleItems() async {
        let product1 = createProduct()
        let product2 = createProduct(id: 101, name: "Orange", description: "Fresh and juicy oranges sourced from organic farms.", price: 2.0, size: "1.0kg")
        let cartItems = [createCartItem(product: product1, quantity: 2),
                         createCartItem(product: product2, quantity: 5)]
        mockRepository.cartItems = cartItems
        await viewModel.fetchCart()
        XCTAssertEqual(viewModel.cartItems.count, 2)
    }
    
    func test_fetchCart_OnError_noCrash() async {
        mockRepository.shouldThrowOnFetch = true
        mockRepository.cartItems = []
        
        await viewModel.fetchCart()
        XCTAssertEqual(viewModel.cartItems.count, 0)
    }
    
    func test_updateCart() async {
        let product = createProduct()
        let cartItem = createCartItem(product: product, quantity: 2)
        mockRepository.cartItems = [cartItem]
        await viewModel.updateCart(cartItem, quantity: 1)
        XCTAssertEqual(viewModel.cartItems.first?.quantity, 1)
        XCTAssertEqual(mockRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_removeItem() async {
        let product = createProduct()
        let cartItem = createCartItem(product: product, quantity: 2)
        mockRepository.cartItems = [cartItem]
        await viewModel.updateCart(cartItem, quantity: 0)
        XCTAssertEqual(viewModel.cartItems.count, 0)
        XCTAssertEqual(mockRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_noCrash() async {
        mockRepository.cartItems = []
        mockRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(createCartItem(product: createProduct(), quantity: 1), quantity: 2)
        XCTAssertEqual(viewModel.cartItems.count, 0)
        XCTAssertEqual(mockRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_doesNotModifyExistingCartItems() async {
        let product1 = createProduct(id: 100, name: "Apple")
        let product2 = createProduct(id: 101, name: "Orange")
        let cartItems = [createCartItem(product: product1, quantity: 2),
                         createCartItem(product: product2, quantity: 5)]
        mockRepository.cartItems = cartItems
        mockRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(createCartItem(product: product1, quantity: 1), quantity: 3)
        XCTAssertEqual(viewModel.cartItems.count, 2)
    }
}
