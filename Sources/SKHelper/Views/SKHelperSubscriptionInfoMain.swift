//
//  SKHelperSubscriptionInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that displays purchase information related to a subscription.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperSubscriptionInfoMain: View {
    
    /// Information related to a subscription.
    let subInfo: SKHelperSubscriptionInfo
    
    /// Creates the body of the view.
    var body: some View {
        
        VStack {
            Group {
                SKHelperPurchaseInfoFieldView(fieldName: "Product name:", fieldValue: subInfo.name)
                SKHelperPurchaseInfoFieldView(fieldName: "Product ID:", fieldValue: subInfo.productId)
                SKHelperPurchaseInfoFieldView(fieldName: "Price:", fieldValue: subInfo.displayPrice ?? "Unknown")
                SKHelperPurchaseInfoFieldView(fieldName: "Upgrade:", fieldValue: subInfo.upgraded == nil ? "Unknown" : (subInfo.upgraded! ? "Yes" : "No"))
                if let willAutoRenew = subInfo.autoRenewOn {
                    if willAutoRenew {
                        SKHelperPurchaseInfoFieldView(fieldName: "Status:", fieldValue: subInfo.subscribedtext ?? "Unknown")
                        SKHelperPurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "Yes")
                        SKHelperPurchaseInfoFieldView(fieldName: "Renews:", fieldValue: subInfo.renewalPeriod ?? "Unknown")
                        SKHelperPurchaseInfoFieldView(fieldName: "Renewal date:", fieldValue: subInfo.renewalDate ?? "Unknown")
                        SKHelperPurchaseInfoFieldView(fieldName: "Renews in:", fieldValue: subInfo.renewsIn ?? "Unknown")
                    } else {
                        SKHelperPurchaseInfoFieldView(fieldName: "Status:", fieldValue: "Cancelled")
                        SKHelperPurchaseInfoFieldView(fieldName: "Auto-renews:", fieldValue: "No")
                        SKHelperPurchaseInfoFieldView(fieldName: "Renews:", fieldValue: "Will not renew")
                        SKHelperPurchaseInfoFieldView(fieldName: "Expirary date:", fieldValue: subInfo.renewalDate ?? "Unknown")
                        SKHelperPurchaseInfoFieldView(fieldName: "Expires in:", fieldValue: subInfo.renewsIn ?? "Unknown")
                    }
                }
            }
            
            Group {
                Text("Most recent transaction").foregroundColor(.secondary).padding()
                Divider()
                SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Date:", fieldValue: subInfo.purchaseDateFormatted ?? "Unknown")
                SKHelperPurchaseInfoFieldViewNarrow(fieldName: "ID:", fieldValue: String(subInfo.transactionId ?? UInt64.min))
                SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Price:", fieldValue: subInfo.displayPrice ?? "Unknown")
                SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Purchase type:", fieldValue: subInfo.ownershipType == nil ? "Unknown" : (subInfo.ownershipType! == .purchased ? "Personal purchase" : "Family sharing"))
                SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Notes:", fieldValue: "\(subInfo.revocationDate == nil ? "-" : "Purchased revoked \(subInfo.revocationDateFormatted ?? "") \(subInfo.revocationReason == .developerIssue ? "(developer issue)" : "(other issue)")")")
            }
            
            if !subInfo.history.isEmpty {
                Group {
                    Text("Historical transactions").foregroundColor(.secondary).padding()
                    ForEach(subInfo.history) { historicalTransaction in
                        Divider()
                        SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Date:", fieldValue: historicalTransaction.purchaseDateFormatted ?? "Unknown")
                        SKHelperPurchaseInfoFieldViewNarrow(fieldName: "ID:", fieldValue: String(historicalTransaction.transactionId ?? UInt64.min))
                        SKHelperPurchaseInfoFieldViewNarrow(fieldName: "Price:", fieldValue: historicalTransaction.displayPrice ?? "Unknown")
                    }
                }
            }
        }
        .padding()
    }
}
