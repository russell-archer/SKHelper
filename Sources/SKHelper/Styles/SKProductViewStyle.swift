//
//  ProductViewStyle.swift
//  SKHelper
//
//  Created by Russell Archer on 13/08/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKProductViewStyle: ProductViewStyle {
    @Binding var selectedProduct: String
    @Binding var productSelected: Bool
    
    public init(selectedProduct: Binding<String>, productSelected: Binding<Bool>) {
        self._selectedProduct = selectedProduct
        self._productSelected = productSelected
    }
    
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
