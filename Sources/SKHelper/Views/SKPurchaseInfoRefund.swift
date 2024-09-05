//
//  SKPurchaseInfoRefund.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that allows the user to request a refund for a non-consumable.
/// See `SKManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
internal struct SKPurchaseInfoRefund: View {
    
    /// Purchase information passed to us by `SKManagePurchaseView`.
    let purchaseInfo: SKPurchaseInformation
    
    /// A binding to a purchase refund request transaction id.
    @Binding var refundRequestTransactionId: UInt64
    
    /// A binding that determines if the refund sheet is displayed.
    @Binding var showRefundSheet: Bool
    
    /// Creates the body of the view.
    var body: some View {
        Divider().padding(.bottom)
        
        #if os(iOS)
        
        Button(action: {
            if let tid = purchaseInfo.transactionId {
                refundRequestTransactionId = tid
                withAnimation { showRefundSheet.toggle()}
            }
        }) {
            Label(title: { Text("Manage Purchase").padding()},
                  icon:  { Image(systemName: "creditcard.circle").resizable().scaledToFit().frame(height: 24)})
        }
        .SKButtonStyleBorderedProminent()
        .padding()
        
        #else
        
        Button(action: {
            if let refundUrl = URL(string: SKConstants.requestRefundUrl) {
                NSWorkspace.shared.open(refundUrl)
            }
        }) {
            Label("Manage Purchase", systemImage: "creditcard.circle")
        }
        .SKButtonStyleBorderedProminent()
        .padding()
        
        #endif
        
        Text("You may request a refund from the App Store if a purchase does not perform as expected. This requires you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
            .foregroundColor(.secondary)
            .font(.caption)
            .multilineTextAlignment(.center)
            .padding()
    }
}
