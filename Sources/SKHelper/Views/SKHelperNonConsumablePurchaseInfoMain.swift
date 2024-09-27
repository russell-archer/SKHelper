//
//  SKHelperNonConsumablePurchaseInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI
import StoreKit

/// A composable view that displays purchase information related to a non-consumable.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperNonConsumablePurchaseInfoMain: View {
    
    /// An `SKHelperPurchaseInfo` passed by `SKHelperManagePurchaseView`.
    let purchaseInfo: SKHelperPurchaseInfo
    
    /// The product type. Must be `.nonConsumable`.
    @State private var productType: Product.ProductType = .nonConsumable
    
    /// The type of purchase made (personal or family sharing).
    @State private var purchaseType: String = "Unknown"
    
    /// Notes on the purchase.
    @State private var notes: String = "-"
    
    /// Creates the body of this view.
    var body: some View {
        VStack {
            if productType == .nonConsumable {
                
                    SKHelperPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: purchaseInfo.name)
                    SKHelperPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: purchaseInfo.id)
                    SKHelperPurchaseInfoFieldView(fieldName: "Price:", fieldValue: purchaseInfo.purchasePrice ?? "Unknown")
                    SKHelperPurchaseInfoFieldView(fieldName: "Date:", fieldValue: purchaseInfo.purchaseDateFormatted ?? "Unknown")
                    SKHelperPurchaseInfoFieldView(fieldName: "Transaction:", fieldValue: String(purchaseInfo.transactionId ?? UInt64.min))
                    SKHelperPurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: purchaseType)
                    SKHelperPurchaseInfoFieldView(fieldName: "Notes:", fieldValue: notes)

                
            } else {
                
                Text("Invalid product type.")
                    .font(.title)
                    .foregroundColor(.red)
                    .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
            }
        }
        .task {
            productType = purchaseInfo.productType
            if let ownershipType = purchaseInfo.ownershipType {
                purchaseType = ownershipType == .purchased ? "Personal purchase" : "Family sharing"
            }
            
            if let revocationDate = purchaseInfo.revocationDate {
                notes = "Purchased revoked \(purchaseInfo.revocationDateFormatted ?? "") \(purchaseInfo.revocationReason == .developerIssue ? "(developer issue)" : "(other)")"
            }
        }
    }
}
