//
//  ProductRepository.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import Foundation

let mockProducts: [Product] = [
    Product(
        id: 100,
        name: "Apple",
        description: "Fresh and crispy red apples sourced from organic farms.",
        price: 1.99,
        imagePath: "https://www.jiomart.com/images/product/original/590004487/apple-indian-6-pcs-pack-approx-750-g-950-g-product-images-o590004487-p590004487-0-202501031744.jpg?im=Resize=(420,420)",
        size: "1.2kg"
    ),
    
    Product(
        id: 101,
        name: "Banana",
        description: "Naturally sweet bananas rich in potassium.",
        price: 0.79,
        imagePath: "https://www.cuisinelangelique.com/infotheque/wp-content/uploads/2023/03/banane-1a.jpg",
        size: "0.9kg"
    ),
    
    Product(
        id: 102,
        name: "Orange",
        description: "Juicy oranges packed with Vitamin C.",
        price: 1.49,
        imagePath: "https://cdn.britannica.com/24/174524-050-A851D3F2/Oranges.jpg?w=300",
        size: "1.0kg"
    ),
    
    Product(
        id: 103,
        name: "Mango",
        description: "Premium Alphonso mangoes with tropical sweetness.",
        price: 2.99,
        imagePath: "https://ichef.bbci.co.uk/images/ic/896xn/p06hk0h6.jpg",
        size: "2.3kg"
    ),
    
    Product(
        id: 104,
        name: "Pineapple",
        description: "Sweet and tangy pineapples, perfect for desserts.",
        price: 3.49,
        imagePath: "https://www.thespruceeats.com/thmb/2Pdkzy-BBOBG74eziXqSj3hwDeI=/1500x0/filters:no_upscale():max_bytes(150000):strip_icc()/SES-history-of-the-pineapple-1807645-343418eb3b4c41b1b956d3c702550a07.jpg",
        size: "3.4kg"
    ),
    
    Product(
        id: 105,
        name: "Strawberry",
        description: "Fresh strawberries ideal for smoothies and cakes.",
        price: 1.49,
        imagePath: "https://cdn.apartmenttherapy.info/image/upload/v1559173423/k/archive/5749ffd1a06d4cbd7e687444cfc1e79963fdad2f.jpg",
        size: "1.0kg"
    ),
    
    Product(
        id: 106,
        name: "Watermelon",
        description: "Refreshing watermelon slices for summer days.",
        price: 2.1,
        imagePath: "https://whatscookingamerica.net/wp-content/uploads/2015/03/Watermelon-Sliced-Eqyptian4.jpg",
        size: "5.0kg"
    ),
    
    Product(
        id: 107,
        name: "Grapes",
        description: "Seedless green grapes with natural sweetness.",
        price: 2.19,
        imagePath: "https://static.wikia.nocookie.net/fruit/images/a/a1/Download_%286%29.jpg/revision/latest?cb=20250214145209",
        size: "0.9kg"
    ),
    
    Product(
        id: 108,
        name: "Kiwi",
        description: "Tangy kiwi fruits rich in antioxidants.",
        price: 4.29,
        imagePath: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b8/Kiwi_%28Actinidia_chinensis%29_1_Luc_Viatour.jpg/1280px-Kiwi_%28Actinidia_chinensis%29_1_Luc_Viatour.jpg",
        size: "1.0kg"
    ),
    
    Product(
        id: 109,
        name: "Papaya",
        description: "Ripe papaya loaded with digestive enzymes.",
        price: 1.30,
        imagePath: "https://lakesidenaturalmedicine.com/wp-content/uploads/2023/07/carica-papaya2a-s__20791.jpg",
        size: "1.0kg"
    )
]
protocol ProductRepository {
    func fetchProducts(for query: String) async throws -> [Product]
}

final class ProductRepositoryImpl: ProductRepository {
    func fetchProducts(for query: String) async throws -> [Product] {
        let dummyProducts: [Product] = mockProducts
        return dummyProducts
    }
}

final class MockProductRepository: ProductRepository {
    var shouldThrownOnFetch: Bool = false
    
    func fetchProducts(for _: String) async throws -> [Product] {
        if shouldThrownOnFetch {
            throw URLError(.badServerResponse)
        }
        let dummyProducts: [Product] = mockProducts
        return dummyProducts
    }
}
