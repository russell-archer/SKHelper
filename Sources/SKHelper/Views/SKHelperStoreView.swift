//
//  SKHelperStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// Uses the StoreKit `StoreView` to create a list of all avaliable products.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperStoreView<Content: View>: View {
    
    public typealias ProductDetailsClosure = (ProductId) -> Content
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected product.
    @State private var selectedProductId = ""
    
    /// true if a product has been selected.
    @State private var productSelected = false
    
    /// A closure which is called to display product details.
    private var productDetails: ProductDetailsClosure
    
    /// Creates an `SKHelperStoreView`. When you instantiate this view provide a closure that may be called to display product information. This information will be displayed when the
    /// user taps on the product's image.
    ///
    /// The `ProductId` of the product to display information for is provided to the closure.
    ///
    /// ## Example 1 ##
    ///
    /// ```
    /// SKHelperStoreView() { productId in
    ///     Group {
    ///         Text("This is a lovely bunch of flowers that would be perfect for a birthday!").font(.headline)
    ///         Image(productId)
    ///             .resizable()
    ///             .scaledToFit()
    ///         Text("Here is some text about why you might want to buy this product.")
    ///     }
    ///     .padding()
    /// }
    /// ```
    ///
    /// Note that you can also provide an empty closure if you do not wish to provide custom content.
    ///
    /// ## Example 2 ##
    ///
    /// ```
    /// SKHelperStoreView() { _ in }
    /// ```
    public init(@ViewBuilder productDetails: @escaping ProductDetailsClosure) {
        self.productDetails = productDetails
    }

    /// Creates the body of the view.
    public var body: some View {
        if store.hasProducts {
            StoreView(products: store.allProducts) { product in
                VStack {
                    Image(product.id)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.circle)
                        .SKHelperOnTapGesture {
                            selectedProductId = product.id
                            productSelected.toggle()
                        }
                }
            }
            .background(LinearGradient(gradient: Gradient(colors: [.white, .blue]), startPoint: .top, endPoint: .bottom))
            .productViewStyle(.automatic)
            #if os(iOS)
            .storeButton(.visible, for: .restorePurchases, .policies, .redeemCode)
            #else
            .storeButton(.visible, for: .restorePurchases, .policies)  // Redeem code requires macOS 15+
            #endif
            .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
            .sheet(isPresented: $productSelected) {
                SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $productSelected, productDetails: productDetails)
            }
        } else {
            
            VStack {
                Text("No products available").font(.subheadline)
                Button("Refresh Products") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
        }
    }
}

#Preview {
    SKHelperStoreView() { selectedProductId in
        Text("Product details for \(selectedProductId)")
    }
    .environment(SKHelper())
}
