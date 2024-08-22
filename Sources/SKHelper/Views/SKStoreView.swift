//
//  SKStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKStoreView: View {
    @Environment(SKHelper.self) private var store
    @State private var selectedProductId = ""
    @State private var productSelected = false
    
    public init() {}
    
    public var body: some View {
        StoreView(ids: store.allProductIds) { product in
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
    }
}

#Preview {
    SKStoreView().environment(SKHelper())
}
