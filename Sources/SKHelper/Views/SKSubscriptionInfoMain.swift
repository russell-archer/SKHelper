//
//  SKSubInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that displays purchase information related to a subscription.
/// See `SKManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKSubscriptionInfoMain: View {
    
    /// Information related to a subscription.
    let subInfo: SKSubscriptionInformation
    
    /// Creates the body of the view.
    var body: some View {
        
        VStack {
            Group {
                SKPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: subInfo.name)
                SKPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: subInfo.productId)
                SKPurchaseInfoFieldView(fieldName: "Price:", fieldValue: subInfo.displayPrice ?? "Unknown")
                SKPurchaseInfoFieldView(fieldName: "Upgrade:", fieldValue: subInfo.upgraded == nil ? "Unknown" : (subInfo.upgraded! ? "Yes" : "No"))
                if let willAutoRenew = subInfo.autoRenewOn {
                    if willAutoRenew {
                        SKPurchaseInfoFieldView(fieldName: "Status:", fieldValue: subInfo.subscribedtext ?? "Unknown")
                        SKPurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "Yes")
                        SKPurchaseInfoFieldView(fieldName: "Renews:", fieldValue: subInfo.renewalPeriod ?? "Unknown")
                        SKPurchaseInfoFieldView(fieldName: "Renewal date:", fieldValue: subInfo.renewalDate ?? "Unknown")
                        SKPurchaseInfoFieldView(fieldName: "Renews in:", fieldValue: subInfo.renewsIn ?? "Unknown")
                    } else {
                        SKPurchaseInfoFieldView(fieldName: "Status:", fieldValue: "Cancelled")
                        SKPurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "No")
                        SKPurchaseInfoFieldView(fieldName: "Renews:", fieldValue: "Will not renew")
                        SKPurchaseInfoFieldView(fieldName: "Expirary date:", fieldValue: subInfo.renewalDate ?? "Unknown")
                        SKPurchaseInfoFieldView(fieldName: "Expires in:", fieldValue: subInfo.renewsIn ?? "Unknown")
                    }
                }
            }
            
            Group {
                Text("Most recent transaction").foregroundColor(.secondary).padding()
                Divider()
                SKPurchaseInfoFieldViewNarrow(fieldName: "Date:", fieldValue: subInfo.purchaseDateFormatted ?? "Unknown")
                SKPurchaseInfoFieldViewNarrow(fieldName: "ID:", fieldValue: String(subInfo.transactionId ?? UInt64.min))
                SKPurchaseInfoFieldViewNarrow(fieldName: "Price:", fieldValue: subInfo.displayPrice ?? "Unknown")
                SKPurchaseInfoFieldViewNarrow(fieldName: "Purchase type:", fieldValue: subInfo.ownershipType == nil ? "Unknown" : (subInfo.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                SKPurchaseInfoFieldViewNarrow(fieldName: "Notes:", fieldValue: "\(subInfo.revocationDate == nil ? "-" : "Purchased revoked \(subInfo.revocationDateFormatted ?? "") \(subInfo.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
            }
            
            if !subInfo.history.isEmpty {
                Group {
                    Text("Historical transactions").foregroundColor(.secondary).padding()
                    ForEach(subInfo.history) { historicalTransaction in
                        Divider()
                        SKPurchaseInfoFieldViewNarrow(fieldName: "Date:", fieldValue: historicalTransaction.purchaseDateFormatted ?? "Unknown")
                        SKPurchaseInfoFieldViewNarrow(fieldName: "ID:", fieldValue: String(historicalTransaction.transactionId ?? UInt64.min))
                        SKPurchaseInfoFieldViewNarrow(fieldName: "Price:", fieldValue: historicalTransaction.displayPrice ?? "Unknown")
                    }
                }
            }
        }
        .padding()
    }
}
