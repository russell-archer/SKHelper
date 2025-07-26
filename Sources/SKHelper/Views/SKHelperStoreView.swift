//
//  SKHelperStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// Creates a list showing all available products. When you instantiate this view provide a closure that will be called
/// to display product information. This information will be displayed when the user taps on the product's image.
/// If the `allowManagement` option is true, when a product has been purchased a "Manage Purchase" button is displayed
/// in place of a purchase button. Tapping the "Manage Purchase" button will display information about the purchase and
/// allow the user to apply for refunds and subscription cancellations.
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
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperStoreView<Content: View>: View {
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected product.
    @State private var selectedProductId = ""
    
    /// true if a product has been selected.
    @State private var productSelected = false
    
    /// True if the store has products.
    @State private var hasProducts = false
    
    /// The result of any user-initiated purchase.
    @State private var purchaseState: SKHelperPurchaseState = .notStarted
    
    /// The purchase state of the selected product. Set by `SKHelperProductViewStyle` if the user taps the "Manage Purchase" button.
    /// Is also set if the user taps on a product image if that product has been purchased.
    @State private var purchased = false
    
    /// Used to determine if we need to display product information or a purchase management sheet for the product.
    /// Set by `SKHelperProductViewStyle` if the user taps the "Manage Purchase" button.
    @State private var managePurchase = false
    
    /// Used to determine if this view has requested a refresh of localized product information. This happens automatically
    /// once only if `SKHelper.hasProducts` is false.
    @State private var hasRequestedProducts = false
    
    /// A closure which is called to display product details.
    private var productDetails: ((ProductId) -> Content)
    
    /// Collection of `ProductId` to display. If nil all available products will be displayed.
    private var productIds: [ProductId]?
    
    /// Provides a collection of `Product` to display in the StoreView.
    private var products: [Product] { productIds == nil ? store.allProducts : store.products(from: productIds!) }
    
    /// If true, allows the user access to post-purchase management functionaility.
    private var allowManagement = false

    /// Creates an `SKHelperStoreView` showing products that match the provided `[ProductId]`, or all products if `productIds` is nil.
    /// - Parameters:
    ///   - allowManagement: If true, allows the user access to post-purchase management functionaility.
    ///   - productIds: Collection of `ProductId` to display. If nil all available products will be displayed.
    ///   - productDetails: A closure which is called to display product details.
    public init(allowManagement: Bool = false, productIds: [ProductId]? = nil, @ViewBuilder productDetails: @escaping (ProductId) -> Content) {
        self.allowManagement = allowManagement
        self.productIds = productIds
        self.productDetails = productDetails
    }
    
    /// Creates the body of the view.
    public var body: some View {
        
        if hasProducts {
            ScrollView {
                if allowManagement { bodyWithManagementStyle() }
                else { bodyWithAutomaticStyle() }
            }
            
        } else {
            
            VStack {
                Text("No products available").font(.subheadline).padding()
                Button("Refresh Products") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
            .onProductsAvailable { _ in hasProducts = store.hasProducts }
            .task {
                if !hasRequestedProducts, !hasProducts, store.autoRequestProducts {
                    hasRequestedProducts = true
                    let _ = await store.requestProducts()
                    hasProducts = store.hasProducts
                }
            }
        }
    }
    
    private func bodyWithAutomaticStyle() -> some View {
        SKHelperStoreViewBody(selectedProductId: $selectedProductId,
                              productSelected: $productSelected,
                              purchased: $purchased,
                              managePurchase: $managePurchase,
                              products: products,
                              productDetails: productDetails)
        .productViewStyle(.automatic)
    }
    
    private func bodyWithManagementStyle() -> some View {
        SKHelperStoreViewBody(selectedProductId: $selectedProductId,
                              productSelected: $productSelected,
                              purchased: $purchased,
                              managePurchase: $managePurchase,
                              products: products,
                              productDetails: productDetails)
        .productViewStyle(SKHelperProductViewStyle(purchased: $purchased,
                                                   selectedProductId: $selectedProductId,
                                                   productSelected: $productSelected,
                                                   managePurchase: $managePurchase))
    }
}

