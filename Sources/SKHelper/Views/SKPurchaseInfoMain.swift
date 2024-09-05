//
//  SKPurchaseInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that displays purchase information related to a non-consumable.
/// See `SKManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKPurchaseInfoMain: View {
    
    /// A `SKPurchaseInformation` passed by `SKManagePurchaseView`.
    let purchaseInfo: SKPurchaseInformation
    
    /// Creates the body of this view.
    var body: some View {
        VStack {
            SKPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: purchaseInfo.name)
            SKPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: purchaseInfo.id)
            SKPurchaseInfoFieldView(fieldName: "Price:", fieldValue: purchaseInfo.purchasePrice ?? "Unknown")
            
            if purchaseInfo.productType == .nonConsumable {
                SKPurchaseInfoFieldView(fieldName: "Date:", fieldValue: purchaseInfo.purchaseDateFormatted ?? "Unknown")
                SKPurchaseInfoFieldView(fieldName: "Transaction:", fieldValue: String(purchaseInfo.transactionId ?? UInt64.min))
                SKPurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: purchaseInfo.ownershipType == nil ? "Unknown" : (purchaseInfo.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                SKPurchaseInfoFieldView(fieldName: "Notes:", fieldValue: "\(purchaseInfo.revocationDate == nil ? "-" : "Purchased revoked \(purchaseInfo.revocationDateFormatted ?? "") \(purchaseInfo.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
                
            } else {
                Text("No additional purchase information available")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(EdgeInsets(top: 1, leading: 5, bottom: 0, trailing: 5))
            }
        }
    }
}
