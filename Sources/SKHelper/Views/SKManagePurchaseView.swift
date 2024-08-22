//
//  SKManagePurchaseView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/08/2024.
//

import SwiftUI
import StoreKit

@available(iOS 17.0, macOS 14.6, *)
public struct SKManagePurchaseView: View {
    @Environment(SKHelper.self) private var store
    @State private var purchaseInfo: SKPurchaseInformation?
    @State private var subInfo: SKSubscriptionInformation?
    @State private var showManagePurchase = false
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    @State private var showRefundSheet = false
    @State private var showRefundAlert: Bool = false
    @State private var refundAlertText: String = ""
    @State private var showManageSubscriptionsSheet = false
    @Binding var selectedProductId: String
    @Binding var showPurchaseInfoSheet: Bool
    
    public var body: some View {
        VStack {
            SKSheetBarView(showSheet: $showPurchaseInfoSheet, title: purchaseInfo?.name ?? "Product Info")

            ScrollView {

                Image(selectedProductId)
                    .resizable()
                    .clipShape(.circle)
                    .frame(maxWidth: 85, maxHeight: 85)
                    .scaledToFit()
                
                if let purchaseInfo {
                    SKPurchaseInfoMain(purchaseInfo: purchaseInfo)
                    SKPurchaseInfoRefund(purchaseInfo: purchaseInfo, refundRequestTransactionId: $refundRequestTransactionId, showRefundSheet: $showRefundSheet)
                    
                } else if let subInfo {
                    SKSubscriptionInfoMain(subInfo: subInfo)
                    SKSubscriptionInfoManage(showManageSubscriptionsSheet: $showManageSubscriptionsSheet)
                }
                else {
                    
                    VStack {
                        Text("Getting transaction info...").font(.subheadline)
                        ProgressView()
                    }
                    .padding()
                }
            }
        }
        .task {
            if store.isNonConsumable(productId: selectedProductId) {
                purchaseInfo = await store.purchaseInformation(for: selectedProductId)
            } else if store.isAutoRenewable(productId: selectedProductId) {
                subInfo = await store.subscriptionInformation(for: selectedProductId)
            }
        }
        .refundRequestSheet(for: refundRequestTransactionId, isPresented: $showRefundSheet) { result in
            var requestWasCancelled = false
            switch(result) {
                case .failure(_): refundAlertText = "Refund request submission failed"
                case .success(let status):
                    switch(status) {
                        case .success: refundAlertText = "Refund request submitted"
                        case .userCancelled: requestWasCancelled = true
                        @unknown default: refundAlertText = "Refund request submission error"
                    }
            }
            
            if !requestWasCancelled { showRefundAlert.toggle() }
        }
        .alert(refundAlertText, isPresented: $showRefundAlert) { Button("OK") { showRefundAlert.toggle() }}
        #if os(iOS)
        .manageSubscriptionsSheet(isPresented: $showManageSubscriptionsSheet)  // Not available for macOS
        #else
        .frame(minWidth: 650, idealWidth: 650, maxWidth: 650, minHeight: 650, idealHeight: 650, maxHeight: 650)
        .fixedSize(horizontal: true, vertical: true)
        #endif
    }
}

#Preview {
    SKManagePurchaseView(
        selectedProductId: Binding.constant("com.rarcher.nonconsumable.flowers.large"),
        showPurchaseInfoSheet: Binding.constant(false))
    .environment(SKHelper())
}
