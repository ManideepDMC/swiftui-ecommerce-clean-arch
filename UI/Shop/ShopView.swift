//
//  ShopView.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import SwiftUI

struct ShopView: View {

    @StateObject var searchViewModel: SearchViewModel
    @State private var navigationPath = NavigationPath()

    init(searchViewModel: SearchViewModel) {
        self._searchViewModel = StateObject(wrappedValue: searchViewModel)
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(searchViewModel.products, id: \.id) { product in
                SearchProductTile(product: product, searchViewModel: searchViewModel) {
                    navigationPath.append(product)
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailsView(
                    viewModel: ProductDetailsViewModel(
                        product: product,
                        quantity: searchViewModel.productQuantities[product.id] ?? 0,
                        cartInteractor: searchViewModel.cartInteractor
                    )
                )
            }
            .scrollIndicators(.hidden)
            .toolbar(navigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
            .navigationTitle("Shop")
            .searchable(text: $searchViewModel.searchText, prompt: "Search fruits")
            .accessibilityIdentifier("shopProductList")
            .onSubmit(of: .search) {
                Task {
                    await searchViewModel.fetchProducts()
                }
            }
            .onChange(of: searchViewModel.searchText) {
                Task {
                    await searchViewModel.fetchProducts()
                }
            }
        }
    }
}


struct SearchProductTile: View {
    let product: Product
    @ObservedObject var searchViewModel: SearchViewModel
    let onTap: () -> Void

    init(product: Product, searchViewModel: SearchViewModel, onTap: @escaping () -> Void) {
        self.product = product
        self.searchViewModel = searchViewModel
        self.onTap = onTap
    }

    var body: some View {
        HStack {
            HStack {
                AsyncImage(url: URL(string: product.imagePath)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(product.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("productName_\(product.id)")

                    Text("$ \(String(format: "%.2f", product.price)) per \(product.size)")
                        .font(.callout)
                        .fontWeight(.medium)
                        .accessibilityIdentifier("productPrice_\(product.id)")

                    Text(product.description)
                        .font(.footnote)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            Spacer()

            if searchViewModel.productQuantities[product.id] ?? 0 == 0 {
                Button("Add to Cart") {
                    Task {
                        await searchViewModel.addToCart(product: product)
                    }
                }
                .accessibilityIdentifier("addToCart_\(product.id)")
            } else {
                HStack {
                    Button {
                        Task {
                            let quantity = (searchViewModel.productQuantities[product.id] ?? 1) - 1
                            await searchViewModel.updateCart(product: product, quantity: quantity)
                        }
                    } label: {
                       Image(systemName: "minus.circle")
                            .resizable()
                            .frame(width: 20.0, height: 20.0)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("shopMinus_\(product.id)")

                    Text("\(searchViewModel.productQuantities[product.id] ?? 0)")
                        .padding(.horizontal, 5.0)
                        .accessibilityIdentifier("shopQuantity_\(product.id)")

                    Button {
                        Task {
                            let quantity = (searchViewModel.productQuantities[product.id] ?? 0) + 1
                            await searchViewModel.updateCart(product: product, quantity: quantity)
                        }
                    } label: {
                        Image(systemName: "plus.app")
                             .resizable()
                             .frame(width: 20.0, height: 20.0)
                    }
                    .buttonStyle(.borderless)
                    .accessibilityIdentifier("shopPlus_\(product.id)")
                }
            }
        }
    }
}
