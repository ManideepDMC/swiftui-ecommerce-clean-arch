//
//  ShopInteractor.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

protocol ShopInteractor {
    func fetchProducts(for query: String) async throws -> [Product]
}


final class ShopInteractorImpl: ShopInteractor {
    
    let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func fetchProducts(for query: String) async throws -> [Product] {
        return try await productRepository.fetchProducts(for: query)
    }
}

final class MockShopInteractor: ShopInteractor {
    
    let productRepository: ProductRepository
    
    init(productRepository: ProductRepository) {
        self.productRepository = productRepository
    }
    
    func fetchProducts(for query: String) async throws -> [Product] {
        return try await self.productRepository.fetchProducts(for: query)
    }
}
