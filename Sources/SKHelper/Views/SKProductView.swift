//
//  SKProductView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// A view normally displayed as a sheet showing details on a purchasable product.
@available(iOS 17.0, macOS 14.6, *)
public struct SKProductView: View {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The StoreKit `Product` that will have its information displayed.
    @State private var product: Product?
    
    /// A binding to the `ProductId` of the selected product.
    @Binding var selectedProductId: ProductId
    
    /// A binding to a value that determines if this view is displayed.
    @Binding var showProductInfoSheet: Bool
    
    /// Creates the body of the view.
    public var body: some View {
        SKSheetBarView(showSheet: $showProductInfoSheet, title: product?.displayName ?? "Product Info")
        ScrollView {
            ProductView(id: selectedProductId) {
                Image(selectedProductId)
                    .resizable()
                    .cornerRadius(15)
                    .scaledToFit()
                
                Text("Here's some details about why you should buy this product...")
            }
            .padding()
            .productViewStyle(.large)
            .task { product = store.product(from: selectedProductId) }
        }
    }
}

#Preview {
    SKProductView(
        selectedProductId: Binding.constant("com.rarcher.nonconsumable.flowers.large"),
        showProductInfoSheet: Binding.constant(true))
    .environment(SKHelper())
}
