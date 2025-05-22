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
        
    /// Caption shown on the "Manage" button.
    @State private var buttonCaption = "Manage Purchase"
    
    /// Purchase status of the selected product.
    @Binding var purchased: Bool
    
    /// A binding to the `ProductId` of the selected product.
    @Binding var selectedProduct: ProductId
    
    /// A binding to a value which determines if a product is selected.
    @Binding var productSelected: Bool
    
    /// A binding used to determine if we need to display product information or a purchase management sheet for the product.
    @Binding var managePurchase: Bool
    
    /// Creates a StoreKit `SKHelperProductView` style.
    ///
    /// - Parameters:
    ///  - purchased: A binding to a Bool property which holds the purchased state of the product.
    ///  - selectedProductId: A binding to the `ProductId` of the selected `Product`.
    ///  - productSelected: A binding to a value which determines if the `SKHelperProductView` is displayed.
    ///  - managePurchase: A binding to a property which determines if this view will display purchase and subscription management functionality.
    public init(purchased: Binding<Bool>,
                selectedProductId: Binding<ProductId>,
                productSelected: Binding<Bool>,
                managePurchase: Binding<Bool>) {
        
        self._purchased = purchased
        self._selectedProduct = selectedProductId
        self._productSelected = productSelected
        self._managePurchase = managePurchase
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
                    if configuration.hasCurrentEntitlement { managePurchaseButton(product: product) }
                    else {
                        productInformationButton(product: product)
                        purchaseButton(product: product, configuration: configuration)
                        Divider()
                    }
                }
                
            case .loading: ProgressView()
            default: Text("Unable to load product \(configuration.product?.displayName ?? "(unknown)")")
        }
    }
    
    private func managePurchaseButton(product: Product) -> some View {
        Button(action: {
            purchased = true
            selectedProduct = product.id
            productSelected = true
            managePurchase = true
            
        }, label: {
            HStack {
                Image(systemName: "creditcard.circle").resizable().scaledToFit().frame(height: 24)
                Text(buttonCaption).padding(5)
            }
        })
        .SKHelperButtonStyleBorderedProminent()
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
    
    private func productInformationButton(product: Product) -> some View {
        Button(action: {
            purchased = false
            selectedProduct = product.id
            productSelected = true
            managePurchase = false
        }, label: {
            HStack {
                Image(systemName: "info.circle").resizable().scaledToFit().frame(height: 24)
                Text("Product Information").padding(5)
            }
        })
        .SKHelperButtonStyleBorderedProminent()
        .tint(.blue)
        .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 1))
    }
    
    private func purchaseButton(product: Product, configuration: Configuration) -> some View {
        Button(action: { configuration.purchase()}, label: { Text(product.displayPrice).padding(5) })
        .tint(.blue)
        .padding(EdgeInsets(top: 10, leading: 5, bottom: 5, trailing: 10))
    }
}
