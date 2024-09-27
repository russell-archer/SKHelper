//
//  SKHelperPurchaseInfoMain.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI
import StoreKit

/// A composable view that displays purchase information related to a consumable or non-consumable product.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperPurchaseInfoMain: View {
    
    /// An `SKHelperPurchaseInfo` set by `SKHelperManagePurchaseView`. If the product type is non-consumable `purchaseInfo` will have a single element.
    let purchaseInfo: [SKHelperPurchaseInfo]
    
    /// Product type. Must be either `.nonConsumable` or `.consumable`. Set by `SKHelperManagePurchaseView`.
    let productType: Product.ProductType
    
    /// The type of purchase made (personal or family sharing).
    @State private var purchaseType: String = "Unknown"
    
    /// Notes on the purchase.
    @State private var notes: String = "-"
    
    /// Creates the body of this view.
    var body: some View {
        VStack {
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
        }
    }
    
    private func purchaseType(info: SKHelperPurchaseInfo) -> String {
        if let ownershipType = info.ownershipType {
            let value = ownershipType == .purchased ? "Personal purchase" : "Family sharing"
            return "\(value) (\(productType.localizedDescription))"
        }
        
        return "Unknown (\(productType.localizedDescription))"
    }
    
    private func notes(info: SKHelperPurchaseInfo) -> String {
        if info.revocationDate != nil {
            return "Purchased revoked \(info.revocationDateFormatted ?? "") \(info.revocationReason == .developerIssue ? "(developer issue)" : "(other)")"
        }
        
        return "-"
    }
}
