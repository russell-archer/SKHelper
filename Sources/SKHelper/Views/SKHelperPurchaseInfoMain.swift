//
//  SKHelperPurchaseInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that displays purchase information related to a non-consumable.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperPurchaseInfoMain: View {
    
    /// An `SKHelperPurchaseInfo` passed by `SKHelperManagePurchaseView`.
    let purchaseInfo: SKHelperPurchaseInfo
    
    /// Creates the body of this view.
    var body: some View {
        VStack {
            SKHelperPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: purchaseInfo.name)
            SKHelperPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: purchaseInfo.id)
            SKHelperPurchaseInfoFieldView(fieldName: "Price:", fieldValue: purchaseInfo.purchasePrice ?? "Unknown")
            
            if purchaseInfo.productType == .nonConsumable {
                SKHelperPurchaseInfoFieldView(fieldName: "Date:", fieldValue: purchaseInfo.purchaseDateFormatted ?? "Unknown")
                SKHelperPurchaseInfoFieldView(fieldName: "Transaction:", fieldValue: String(purchaseInfo.transactionId ?? UInt64.min))
                SKHelperPurchaseInfoFieldView(fieldName: "Purchase type:", fieldValue: purchaseInfo.ownershipType == nil ? "Unknown" : (purchaseInfo.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                SKHelperPurchaseInfoFieldView(fieldName: "Notes:", fieldValue: "\(purchaseInfo.revocationDate == nil ? "-" : "Purchased revoked \(purchaseInfo.revocationDateFormatted ?? "") \(purchaseInfo.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
                
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
