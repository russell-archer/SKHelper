//
//  ProductViewStyle.swift
//  SKHelper
//
//  Created by Russell Archer on 13/08/2024.
//

import SwiftUI
import StoreKit

/// StoreKit `SKProductView` style.
@available(iOS 17.0, macOS 14.6, *)
public struct SKProductViewStyle: ProductViewStyle {
    
    /// A binding to the `ProductId` of the selected product.
    @Binding var selectedProduct: ProductId
    
    /// A binding to a value which determines if a product is selected.
    @Binding var productSelected: Bool
    
    /// Creates a StoreKit `SKProductView` style.
    ///
    /// - Parameters:
    ///   - selectedProductId: A binding to the `ProductId` of the selected `Product`.
    ///   - productSelected: A binding to a value which determines if the `SKManagePurchaseView` is displayed.
    ///   
    public init(selectedProductId: Binding<ProductId>, productSelected: Binding<Bool>) {
        self._selectedProduct = selectedProductId
        self._productSelected = productSelected
    }
    
    /// Creates the body of the StoreKit `SKProductView` style.
    /// 
    /// - Parameter configuration: The style's configuration.
    /// - Returns: Returns the body of the custom StoreKit `SKProductView` style.
    ///
    public func makeBody(configuration: Configuration) -> some View {
        switch configuration.state {
            case .success(let product):
                VStack(alignment: .center) {
                    configuration.icon
                        .padding()
                    
                    Text(product.displayName).font(.title)
                    
                    if configuration.hasCurrentEntitlement {
                        
                        Button(action: {
                            selectedProduct = product.id
                            productSelected.toggle()
                            
                        }, label: {
                            HStack {
                                Image(systemName: "creditcard.circle")
                                Text("Manage Purchase")
                            }
                        })
                        .tint(.blue)
                        .padding()
                        
                        
                    } else {
                        
                        Button(product.displayPrice) {
                            configuration.purchase()
                        }
                        .tint(.blue)
                        .padding()
                        
                    }
                }
                .background(.blue, in: .rect(cornerRadius: 20))
                
            default: ProductView(configuration)
        }
    }
}
