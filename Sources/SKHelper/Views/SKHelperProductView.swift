//
//  SKHelperProductView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// A view normally displayed as a sheet showing details on a purchasable product.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperProductView<Content: View>: View {
    
    public typealias ProductDetailsClosure = (ProductId) -> Content

    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The StoreKit `Product` that will have its information displayed.
    @State private var product: Product?
    
    /// A binding to the `ProductId` of the selected product.
    @Binding var selectedProductId: ProductId
    
    /// A binding to a value that determines if this view is displayed.
    @Binding var showProductInfoSheet: Bool
    
    /// A closure which is called to display product details.
    private var productDetails: ProductDetailsClosure
    
    /// Creates an `SKHelperProductView` which displays product information using a StoreKit `ProductView`.
    ///
    /// - Parameters:
    ///   - selectedProductId: The `ProductId` of the product for which you want to display details.
    ///   - showProductInfoSheet: Used to togggle the display of the product information sheet
    ///   - productDetails: A closure which is called to display custom information about the product.
    ///
    public init(selectedProductId: Binding<ProductId>, showProductInfoSheet: Binding<Bool>, @ViewBuilder productDetails: @escaping ProductDetailsClosure) {
        self._selectedProductId = selectedProductId
        self._showProductInfoSheet = showProductInfoSheet
        self.productDetails = productDetails
    }
    
    /// Creates the body of the view.
    public var body: some View {
        SKHelperSheetBarView(showSheet: $showProductInfoSheet, title: product?.displayName ?? "Product Info")
        ScrollView {
            productDetails(selectedProductId)

            ProductView(id: selectedProductId) {
                Image(selectedProductId)
                    .resizable()
                    .cornerRadius(15)
                    .scaledToFit()
            }
            .padding()
            .productViewStyle(.large)
            .task { product = store.product(from: selectedProductId) }
        }
    }
}

#Preview {
    SKHelperProductView(selectedProductId: Binding.constant("com.rarcher.nonconsumable.flowers.large"), showProductInfoSheet: Binding.constant(true)) { productId in
        Image("com.rarcher.nonconsumable.flowers.large")
            .resizable()
            .scaledToFit()
        
        Text("Here is a lovely product. You should buy it!")
    }
    .environment(SKHelper())
}
