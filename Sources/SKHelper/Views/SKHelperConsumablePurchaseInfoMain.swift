//
//  SKHelperConsumablePurchaseInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI
import StoreKit

/// A composable view that displays purchase information related to a consumable.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperConsumablePurchaseInfoMain: View {
    
    /// An `SKHelperPurchaseInfo` passed by `SKHelperManagePurchaseView`.
    let purchaseInfo: [SKHelperPurchaseInfo]
    
    /// The product type. Must be `.consumable`.
    @State private var productType: Product.ProductType = .consumable
    
    /// The type of purchase made (personal or family sharing).
    @State private var purchaseType: String = ""
    
    /// Notes on the purchase.
    @State private var notes: String = ""
    
    /// Creates the body of this view.
    var body: some View {
        VStack {
            if productType == .consumable {
                ForEach(purchaseInfo, id: \.self) { pi in
                    SKHelperPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: pi.name)
                    SKHelperPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: pi.id)
                    SKHelperPurchaseInfoFieldView(fieldName: "Price:", fieldValue: pi.purchasePrice ?? "Unknown")
                    SKHelperPurchaseInfoFieldView(fieldName: "Date:", fieldValue: pi.purchaseDateFormatted ?? "Unknown")
                    SKHelperPurchaseInfoFieldView(fieldName: "Transaction:", fieldValue: String(pi.transactionId ?? UInt64.min))
                    SKHelperPurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: purchaseType(info: pi))
                    SKHelperPurchaseInfoFieldView(fieldName: "Notes:", fieldValue: notes(info: pi))
                    Divider()
                }

            } else {
                
                Text("Invalid product type.")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
            }
        }
        .task { productType = purchaseInfo.first?.productType ?? .consumable }
    }
    
    private func purchaseType(info: SKHelperPurchaseInfo) -> String {
        if let ownershipType = info.ownershipType {
            return ownershipType == .purchased ? "Personal purchase" : "Family sharing"
        }
        
        return "Unknown"
    }
    
    private func notes(info: SKHelperPurchaseInfo) -> String {
        if let revocationDate = info.revocationDate {
            return "Purchased revoked \(info.revocationDateFormatted ?? "") \(info.revocationReason == .developerIssue ? "(developer issue)" : "(other)")"
        }
        
        return "-"
    }
}
