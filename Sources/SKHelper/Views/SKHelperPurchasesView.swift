//
//  SKHelperPurchasesView.swift
//  SKHelper
//
//  Created by Russell Archer on 12/08/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperPurchasesView: View {
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Collection of the `ProductId` of all purchased products.
    @State private var purchasedProducts: [ProductId] = []
    
    /// The `ProductId` of the currently selected product.
    @State private var selectedProductId = ""
    
    /// true if a product has been selected.
    @State private var productSelected = false
    
    /// Creates a `SKHelperPurchasesView`.
    public init() {}
    
    /// Creates the body of the view.
    public var body: some View {
        ScrollView {
            LazyVStack {
                if purchasedProducts.isEmpty {
                    
                    VStack {
                        Text("Getting purchases...").font(.subheadline)
                        ProgressView()
                    }
                    .padding()
                    
                } else {
                    
                    ForEach(purchasedProducts, id: \.self) { productId in
                        
                        ProductView(id: productId) {
                            Image(productId)
                                .resizable()
                                .clipShape(.circle)
                                .shadow(color: .secondary, radius: 5, x: 10, y: 10)
                                .scaledToFit()
                        }
                        .padding(.all, 10)
                        .productViewStyle(SKHelperProductViewStyle(selectedProductId: $selectedProductId, productSelected: $productSelected))
                        Divider().padding()
                    }
                }
            }
        }
        .task { purchasedProducts = store.allPurchasedProductIds }
        .onChange(of: store.allPurchasedProductIds) { purchasedProducts = store.allPurchasedProductIds }
        .background(LinearGradient(gradient: Gradient(colors: [.white, .blue]), startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $productSelected) { SKHelperManagePurchaseView(selectedProductId: $selectedProductId, showPurchaseInfoSheet: $productSelected) }
    }
}

#Preview {
    SKHelperPurchasesView().environment(SKHelper())
}
