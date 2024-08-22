//
//  SKProductView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKProductView: View {
    @Environment(SKHelper.self) private var store
    @State private var product: Product?
    @Binding var selectedProductId: String
    @Binding var showProductInfoSheet: Bool
    
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
