//
//  ProductDetailsView.swift
//  ECommerce With MVVM
//
//  Created by Manideep on 20/02/26.
//

import SwiftUI

struct ProductDetailsView: View {
    
    @StateObject var viewModel: ProductDetailsViewModel
    
    init(viewModel: ProductDetailsViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {

                if let imagePath = viewModel.imagePath {
                    AsyncImage(url: imagePath) { image in
                        image
                            .resizable()
                            .scaledToFit()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .padding(.bottom)
                }

                Group {
                    Text(viewModel.name)
                        .font(.title)
                        .fontWeight(.semibold)
                        .accessibilityIdentifier("detailName_\(viewModel.product.id)")

                    Text(viewModel.price)
                        .font(.title3)
                        .fontWeight(.medium)
                        .accessibilityIdentifier("detailPrice_\(viewModel.product.id)")

                    Text(viewModel.description)
                        .font(.subheadline)
                        .fontWeight(.light)
                        .padding(.bottom)
                        .accessibilityIdentifier("detailDescription_\(viewModel.product.id)")

                    if viewModel.quantity == 0 {
                        Button("Add to Cart") {
                            Task {
                                await viewModel.addToCart()
                            }
                        }
                        .buttonStyle(GlassyButtonStyle())
                        .accessibilityIdentifier("detailAddToCart_\(viewModel.product.id)")
                    } else {
                        HStack {
                            Button {
                                Task {
                                    let quantity = viewModel.quantity - 1
                                    await viewModel.updateCart(quantity: quantity)
                                }
                            } label: {
                                Image(systemName: "minus.circle")
                                    .resizable()
                                    .frame(width: 30.0, height: 30.0)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityIdentifier("detailMinus_\(viewModel.product.id)")

                            Text("\(viewModel.quantity)")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.horizontal, 5.0)
                                .accessibilityIdentifier("detailQuantity_\(viewModel.product.id)")

                            Button {
                                Task {
                                    let quantity = viewModel.quantity + 1
                                    await viewModel.updateCart(quantity: quantity)
                                }
                            } label: {
                                Image(systemName: "plus.app")
                                    .resizable()
                                    .frame(width: 30.0, height: 30.0)
                            }
                            .buttonStyle(.borderless)
                            .accessibilityIdentifier("detailPlus_\(viewModel.product.id)")
                        }
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Prodcut Details")
        }
    }
}
