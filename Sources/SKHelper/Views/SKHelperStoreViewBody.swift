//
//  SKHelperStoreViewBody.swift
//  SKHelper
//
//  Created by Russell Archer on 06/03/2025.
//

import SwiftUI
import StoreKit

/// Uses the StoreKit `StoreView` to create a list of all avaliable products.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperStoreViewBody<Content: View>: View {
    
    /// A closure which is called to display product details.
    public typealias ProductDetailsClosure = (ProductId) -> Content
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected product.
    @Binding var selectedProductId: ProductId
    
    /// true if a product has been selected.
    @Binding var productSelected: Bool
    
    /// The purchase state of the selected product.
    @Binding var purchased: Bool
    
    /// A binding used to determine if we need to display product information or a purchase management sheet for the product.
    @Binding var managePurchase: Bool
    
    /// A collection of `Product` to display in the StoreView.
    public var products: [Product]
    
    /// A closure which is called to display product details.
    public var productDetails: ProductDetailsClosure
    
    public init(selectedProductId: Binding<ProductId>,
                productSelected: Binding<Bool>,
                purchased: Binding<Bool>,
                managePurchase: Binding<Bool>,
                products: [Product],
                @ViewBuilder productDetails: @escaping ProductDetailsClosure) {
        
        self._selectedProductId = selectedProductId
        self._productSelected = productSelected
        self._purchased = purchased
        self._managePurchase = managePurchase
        self.products = products
        self.productDetails = productDetails
    }
    
    /// Creates the body of the view.
    public var body: some View {
        StoreView(products: products) { product in
            Image(product.id)
                .resizable()
                .scaledToFit()
                .clipShape(.circle)
                .SKHelperOnTapGesture {
                    Task {
                        purchased = await store.isPurchased(productId: selectedProductId)
                        selectedProductId = product.id
                        productSelected = true
                    }
                }
        }
        .onInAppPurchaseCompletion { product, result in
            let _ = await store.purchaseCompletion(for: product, with: try? result.get()).purchaseState
        }
        #if os(iOS)
        .storeButton(.visible, for: .restorePurchases, .policies, .redeemCode)
        #else
        .storeButton(.visible, for: .restorePurchases, .policies)  // Redeem code requires macOS 15+
        #endif
        .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
        .sheet(isPresented: $productSelected) { [managePurchase] in
            if managePurchase {
                SKHelperManagePurchaseView(selectedProductId: $selectedProductId, showPurchaseInfoSheet: $productSelected)
            } else {
                SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $productSelected, productDetails: productDetails)
            }
        }
    }
}
