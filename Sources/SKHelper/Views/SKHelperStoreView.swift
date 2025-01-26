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
    
    /// A closure that is passed a `ProductId` and returns a `View` providing product details.
    public typealias ProductDetailsClosure = (ProductId) -> Content
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected product.
    @State private var selectedProductId = ""
    
    /// true if a product has been selected.
    @State private var productSelected = false
    
    /// True if the store has products.
    @State private var hasProducts = false
    
    /// A closure which is called to display product details.
    private var productDetails: ProductDetailsClosure?
    
    /// Collection of `ProductId` to display. If nil all available products will be displayed.
    private var productIds: [ProductId]?
    
    /// Provides a collection of `Product` to display in the StoreView.
    private var products: [Product] { productIds == nil ? store.allProducts : store.products(from: productIds!) }

    /// Creates an `SKHelperStoreView` showing all available products. When you instantiate this view provide a closure that may be
    /// called to display product information. This information will be displayed when the user taps on the product's image.
    ///
    /// The `ProductId` of the product to display information for is provided to the closure.
    ///
    /// ## Example ##
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
    public init(@ViewBuilder productDetails: @escaping ProductDetailsClosure) {
        self.productDetails = productDetails
    }
    
    /// Creates an `SKHelperStoreView` showing products that match the provided `[ProductId]`.
    /// When you instantiate this view provide a closure that may be called to display product information. This information will be
    /// displayed when the user taps on the product's image.
    ///
    /// The `ProductId` of the product to display information for is provided to the closure.
    ///
    public init(productIds: [ProductId], @ViewBuilder productDetails: @escaping ProductDetailsClosure) {
        self.productIds = productIds
        self.productDetails = productDetails
    }
    
    /// Creates an `SKHelperStoreView` showing products that match the provided `[ProductId]`.
    /// Default product information will be displayed when the user taps on the product's image.
    ///
    public init(productIds: [ProductId]) where Content == EmptyView {
        self.productIds = productIds
    }
    
    /// Creates an `SKHelperStoreView` showing all available products.
    /// Default product information will be displayed when the user taps on the product's image.
    ///
    public init() where Content == EmptyView {}
    
    /// Creates the body of the view.
    public var body: some View {
        
        if hasProducts {
            ScrollView {
                StoreView(products: products) { product in
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
                .productViewStyle(.automatic)
                .onInAppPurchaseCompletion { product, result in await store.purchaseCompletion(for: product, with: try? result.get()) }
                #if os(iOS)
                .storeButton(.visible, for: .restorePurchases, .policies, .redeemCode)
                #else
                .storeButton(.visible, for: .restorePurchases, .policies)  // Redeem code requires macOS 15+
                #endif
                .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
                .sheet(isPresented: $productSelected) {
                    if let productDetails { SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $productSelected, productDetails: productDetails) }
                    else { SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $productSelected) }
                }
            }
            
        } else {
            
            VStack {
                Text("No products available").font(.subheadline).padding()
                Button("Refresh Products") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
            .onProductsAvailable { _  in
                // This view modifier is called when localized product information becomes available
                hasProducts = store.hasProducts
            }
        }
    }
}

#Preview {
    SKHelperStoreView().environment(SKHelper())
}
