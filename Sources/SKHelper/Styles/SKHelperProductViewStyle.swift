//
//  SKHelperProductViewStyle.swift
//  SKHelper
//
//  Created by Russell Archer on 13/08/2024.
//

import SwiftUI
import StoreKit

/// StoreKit `SKHelperProductView` style.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperProductViewStyle: ProductViewStyle {
    
    /// The purchase state of the product.
    @State private var purchased = false
    
    /// Caption shown on the "Manage" button.
    @State private var buttonCaption = "Manage Purchase"
    
    /// A binding to the `ProductId` of the selected product.
    @Binding var selectedProduct: ProductId
    
    /// A binding to a value which determines if a product is selected.
    @Binding var productSelected: Bool
    
    /// Creates a StoreKit `SKHelperProductView` style.
    ///
    /// - Parameters:
    ///   - selectedProductId: A binding to the `ProductId` of the selected `Product`.
    ///   - productSelected: A binding to a value which determines if the `SKHelperProductView` is displayed.
    ///   
    public init(selectedProductId: Binding<ProductId>, productSelected: Binding<Bool>) {
        self._selectedProduct = selectedProductId
        self._productSelected = productSelected
    }
    
    /// Creates the body of the StoreKit `SKHelperProductView` style.
    ///
    /// - Parameter configuration: The style's configuration.
    /// - Returns: Returns the body of the custom StoreKit `SKHelperProductView` style.
    ///
    public func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
            case .success(let product):
                VStack(alignment: .center) {
                    configuration.icon.padding()
                    Text(product.displayName).font(.title)
                    if purchased { managePurchaseButton(product: product) }
                    else { purchaseButton(product: product, configuration: configuration) }
                }
                .task { purchased = await isPurchased(product: product, configuration: configuration) }
                
            default: ProductView(configuration)
        }
    }
    
    private func managePurchaseButton(product: Product) -> some View {
        Button(action: {
            selectedProduct = product.id
            productSelected.toggle()
            
        }, label: {
            HStack {
                Image(systemName: "creditcard.circle")
                Text(buttonCaption)
            }
        })
        .tint(.blue)
        .padding()
        .task {
            buttonCaption = switch product.type {
                case .consumable: "Manage Purchase"
                case .nonConsumable: "Manage Purchase"
                case .autoRenewable: "Manage Subscription"
                default: ""
            }
        }
    }
    
    private func purchaseButton(product: Product, configuration: Configuration) -> some View {
        Button(product.displayPrice) {
            configuration.purchase()
        }
        .tint(.blue)
        .padding()
    }
    
    private func isPurchased(product: Product, configuration: Configuration) async -> Bool {
        var value = false
        var latestTransaction: VerificationResult<StoreKit.Transaction>?
        
        if product.type == .consumable { latestTransaction = await product.latestTransaction }
        else if product.type == .nonConsumable || product.type == .autoRenewable { latestTransaction = await product.currentEntitlement }
        
        if let latestTransaction {
            switch latestTransaction {
                case .unverified(_, _): value = false
                case .verified(_): value = true
            }
        }
        
        return value
    }
}
