//
//  SKStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// Uses the StoreKit `StoreView` to create a list of all avaliable products.
@available(iOS 17.0, macOS 14.6, *)
public struct SKStoreView: View {
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected product.
    @State private var selectedProductId = ""
    
    /// true if a product has been selected.
    @State private var productSelected = false
    
    /// Creates a `SKStoreView`.
    public init() {}
    
    /// Creates the body of the view.
    public var body: some View {
        if store.hasProducts {
            StoreView(products: store.allProducts) { product in
                VStack {
                    Image(product.id)
                        .resizable()
                        .scaledToFit()
                        .clipShape(.circle)
                        .onTapGesture {
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
                SKProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $productSelected)
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
    SKStoreView().environment(SKHelper())
}
