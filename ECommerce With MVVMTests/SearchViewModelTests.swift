//
//  SearchViewModelTests.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 16/02/26.
//

import XCTest
@testable import ECommerce_With_MVVM

@MainActor
final class SearchViewModelTests: XCTestCase {
    
    var mockProductRepository: MockProductRepository!
    var mockSearchInteractor: MockShopInteractor!
    var mockCartRepository: MockCartRepository!
    var mockCartInteractor: MockCartInteractor!
    var viewModel: SearchViewModel!
    override func setUp() async throws {
        mockProductRepository = MockProductRepository()
        mockSearchInteractor = MockShopInteractor(productRepository: mockProductRepository)
        mockCartRepository = MockCartRepository()
        mockCartInteractor = MockCartInteractor(cartRepository: mockCartRepository)
        viewModel = SearchViewModel(cartInteractor: mockCartInteractor, shopInteractor: mockSearchInteractor)
    }
    
    override func tearDownWithError() throws {
        
    }
    
    // MARK: - Helpers
    
    private func createProduct(id: Int = 100, name: String = "Apple", description: String = "Fresh and juicy oranges sourced from organic farms.", price: Double = 2.0, size: String = "1.2kg") -> Product {
        Product(id: id, name: name, description: description, price: price, imagePath: "", size: size)
    }
    
    private func createCartItem(product: Product, quantity: Int) -> CartItem {
        CartItem(product: product, quantity: quantity)
    }
    
    // MARK: - Test cases
    
    func test_No_Search_Results() async throws {
        viewModel.searchText = ""
        await viewModel.fetchProducts()
        XCTAssertEqual(viewModel.products.count, 0)
    }
    
    func test_Search_Results_Error() async throws {
        mockProductRepository.shouldThrownOnFetch = true
        viewModel.searchText = "fruit"
        await viewModel.fetchProducts()
        XCTAssertEqual(viewModel.products.count, 0)
    }
    
    func test_Search_Results_Success() async throws {
        mockProductRepository.shouldThrownOnFetch = false
        viewModel.searchText = "fruit"
        await viewModel.fetchProducts()
        XCTAssertEqual(viewModel.products.count, 10)
    }
    
    func test_addToCart() async {
        let product = createProduct()        
        await viewModel.fetchProducts()
        await viewModel.addToCart(product: product)
        XCTAssertEqual(mockCartRepository.cartItems.count, 1)
        XCTAssertEqual(mockCartRepository.addToCartCallCount, 1)
    }
    
    func test_addToCart_productAlreadyInCart() async {
        let product = createProduct()
        let cartItem =  createCartItem(product: product, quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        
        await viewModel.addToCart(product: product)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 3)
        XCTAssertEqual(mockCartRepository.addToCartCallCount, 1)
    }
    
    func test_AddToCart_onError_noCrash() async {
        let product = createProduct()
        
        mockCartRepository.shouldThrowOnAdd = true
        await viewModel.addToCart(product: product)
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
    }
    
    func test_AddToCart_onError_doesNotModifyExistingCartItems() async {
        let product = createProduct()
        
        let cartItem = createCartItem(product: product, quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        mockCartRepository.shouldThrowOnAdd = true
        
        await viewModel.addToCart(product: product)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 2)
    }
    
    func test_updateCart() async {
        let product = createProduct()
        let cartItem = createCartItem(product: product, quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        await viewModel.updateCart(product: product, quantity: 1)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 1)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_removeItem() async {
        let product = createProduct()
        let cartItem = createCartItem(product: product, quantity: 2)
        mockCartRepository.cartItems = [cartItem]
        await viewModel.updateCart(product: product, quantity: 0)
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_noCrash() async {
        mockCartRepository.cartItems = []
        mockCartRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(product: createProduct(), quantity: 2)
        XCTAssertEqual(mockCartRepository.cartItems.count, 0)
        XCTAssertEqual(mockCartRepository.updateCartCallCount, 1)
    }
    
    func test_updateCart_onError_doesNotModifyExistingCartItems() async {
        let product1 = createProduct(id: 100, name: "Apple")
        let product2 = createProduct(id: 101, name: "Orange")
        let cartItems = [createCartItem(product: product1, quantity: 2),
                         createCartItem(product: product2, quantity: 5)]
        mockCartRepository.cartItems = cartItems
        mockCartRepository.shouldThrowOnUpdate = true
        await viewModel.updateCart(product: product1, quantity: 3)
        XCTAssertEqual(mockCartRepository.cartItems.count, 2)
        XCTAssertEqual(mockCartRepository.cartItems.first?.quantity, 2)
    }
}
