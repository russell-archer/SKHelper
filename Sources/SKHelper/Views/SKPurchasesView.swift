//
//  SKPurchasesView.swift
//  SKHelper
//
//  Created by Russell Archer on 12/08/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKPurchasesView: View {
    @Environment(SKHelper.self) private var store
    @State private var purchasedProducts: [ProductId] = []
    @State private var selectedProductId = ""
    @State private var productSelected = false
    
    public init() {}
    
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
                        .productViewStyle(SKProductViewStyle(selectedProduct: $selectedProductId, productSelected: $productSelected))
                        Divider().padding()
                    }
                }
            }
        }
        .task { purchasedProducts = store.allPurchasedProductIds }
        .onChange(of: store.allPurchasedProductIds) { purchasedProducts = store.allPurchasedProductIds }
        .background(LinearGradient(gradient: Gradient(colors: [.white, .blue]), startPoint: .top, endPoint: .bottom))
        .sheet(isPresented: $productSelected) { SKManagePurchaseView(selectedProductId: $selectedProductId, showPurchaseInfoSheet: $productSelected) }
    }
}

#Preview {
    SKPurchasesView().environment(SKHelper())
}
