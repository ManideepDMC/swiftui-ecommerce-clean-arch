//
//  ProductDetailsViewModelTests.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 20/02/26.
//

import XCTest
@testable import ECommerce_With_MVVM

@MainActor
class ProductDetailsViewModelTests: XCTestCase {
    
    var viewModel: ProductDetailsViewModel!
    var mockCartInteractor: MockCartInteractor!
    var mockCartRepository: MockCartRepository!
    var product: Product!
    override func setUpWithError() throws {
        mockCartRepository = MockCartRepository()
        mockCartInteractor = MockCartInteractor(cartRepository: mockCartRepository)
        product = createProduct()
        viewModel = ProductDetailsViewModel(product: product, quantity: 0, cartInteractor: mockCartInteractor)
    }
        
    override func tearDownWithError() throws {
    }
    
    // MARK: - Helpers
    
    private func createProduct(id: Int = 100, name: String = "Apple", description: String = "Fresh and juicy oranges sourced from organic farms.", price: Double = 2.0, size: String = "1.2kg") -> Product {
        Product(id: id, name: name, description: description, price: price, imagePath: "", size: size)
    }
    
    private func createCartItem(quantity: Int) -> CartItem {
        CartItem(product: product, quantity: quantity)
    }
    
    // MARK: - test cases
    
    func test_ProductDetails() async {
        XCTAssertEqual(viewModel.name, product.name)
        XCTAssertEqual(viewModel.price, "$ \(String(format: "%.2f", product.price)) per \(product.size)")
        XCTAssertEqual(viewModel.description, product.description)
        XCTAssertEqual(viewModel.imagePath, URL(string: product.imagePath))
    }
    
    func test_fetchCart_empty() async {
        mockCartRepository.cartItems = []
        XCTAssertEqual(viewModel.quantity, 0)
    }
    
    func test_fetchCart_OnError_noCrash() async {
        mockCartRepository.shouldThrowOnFetch = true
        mockCartRepository.cartItems = []
        
        XCTAssertEqual(viewModel.quantity, 0)
    }
    
    func test_addToCart() async {
        await viewModel.addToCart()
        XCTAssertEqual(mockCartRepository.cartItems.count, 1)
        XCTAssertEqual(mockCartRepository.addToCartCallCount, 1)
    }
    
    func test_addToCart_productAlreadyInCart() async {
        let cartItem =  createCartItem(quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        
        await viewModel.addToCart()
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 3)
        XCTAssertEqual(mockCartRepository.addToCartCallCount, 1)
    }
    
    func test_AddToCart_onError_noCrash() async {
        mockCartRepository.shouldThrowOnAdd = true
        await viewModel.addToCart()
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
    }
    
    func test_AddToCart_onError_doesNotModifyExistingCartItems() async {
        
        let cartItem = createCartItem(quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        mockCartRepository.shouldThrowOnAdd = true
        
        await viewModel.addToCart()
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 2)
    }
    
    func test_updateCart() async {
        let cartItem = createCartItem(quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        await viewModel.updateCart(quantity: 1)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 1)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_removeItem() async {
        let cartItem = createCartItem(quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        await viewModel.updateCart(quantity: 0)
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_noCrash() async {
        mockCartRepository.cartItems = []
        mockCartRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(quantity: 2)
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_doesNotModifyExistingCartItems() async {
        let cartItem = createCartItem(quantity: 5)
        mockCartRepository.cartItems = [cartItem]
        mockCartRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(quantity: 3)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 5)
    }
    
}
