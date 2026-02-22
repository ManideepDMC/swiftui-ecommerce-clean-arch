//
//  CartView.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 11/02/26.
//

import SwiftUI

struct CartView: View {
    
    @StateObject var cartViewModel: CartViewModel
    @State private var navigationPath = NavigationPath()
    
    init(cartViewModel: CartViewModel) {
        self._cartViewModel = StateObject(wrappedValue: cartViewModel)
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            List(cartViewModel.cartItems, id: \.id) { cartItem in
                CartProductTile(cartItem: cartItem, cartViewModel: cartViewModel) {
                    navigationPath.append(cartItem.product)
                }
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailsView(
                    viewModel: ProductDetailsViewModel(
                        product: product,
                        quantity: cartViewModel.cartItems.first { $0.product.id == product.id }?.quantity ?? 0,
                        cartInteractor: cartViewModel.cartInteractor
                    )
                )
            }
            .scrollIndicators(.hidden)
            .toolbar(navigationPath.isEmpty ? .visible : .hidden, for: .tabBar)
            .accessibilityIdentifier("cartProductList")
        }
    }
}

struct CartProductTile: View {
    
    @ObservedObject var cartViewModel: CartViewModel
    let cartItem: CartItem
    let onTap: () -> Void
    
    init(cartItem: CartItem, cartViewModel: CartViewModel, onTap: @escaping () -> Void) {
        self.cartViewModel = cartViewModel
        self.cartItem = cartItem
        self.onTap = onTap
    }
    
    var body: some View {
        HStack {
            HStack {
                AsyncImage(url: URL(string: cartItem.product.imagePath)) { image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 50, height: 50)
                .clipShape(Circle())

                VStack(alignment: .leading) {
                    Text(cartItem.product.name)
                        .font(.body)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("cartProductName_\(cartItem.product.id)")

                    Text("$ \(String(format: "%.2f", cartItem.product.price)) per \(cartItem.product.size)")
                        .font(.callout)
                        .fontWeight(.medium)
                        .accessibilityIdentifier("cartProductPrice_\(cartItem.product.id)")

                    Text(cartItem.product.description)
                        .font(.footnote)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture { onTap() }

            Spacer()

            HStack {
                Button {
                    Task {
                        await cartViewModel.updateCart(cartItem, quantity: cartItem.quantity - 1)
                    }
                } label: {
                    Image(systemName: "minus.circle")
                        .resizable()
                        .frame(width: 20.0, height: 20.0)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("cartMinus_\(cartItem.product.id)")

                Text("\(cartItem.quantity)")
                    .padding(.horizontal, 5.0)
                    .accessibilityIdentifier("cartQuantity_\(cartItem.product.id)")

                Button {
                    Task {
                        await cartViewModel.updateCart(cartItem, quantity: cartItem.quantity + 1)
                    }
                } label: {
                    Image(systemName: "plus.app")
                        .resizable()
                        .frame(width: 20.0, height: 20.0)
                }
                .buttonStyle(.borderless)
                .accessibilityIdentifier("cartPlus_\(cartItem.product.id)")
            }
        }
    }
}
