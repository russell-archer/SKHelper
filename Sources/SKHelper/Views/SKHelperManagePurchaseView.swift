//
//  SKHelperManagePurchaseView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/08/2024.
//

import SwiftUI
import StoreKit

/// A view that displays detailed information related to a consumable, non-consumable or subscription purchase, along with purchase management options.
///
/// ## Consumables ##
/// If the purchase is for a consumable we show all historical purchases for that product.
///
/// ## Non-consumables ##
/// If the purchase is for a non-consumable a button is diplsayed allowing the user to "Manage Purchase" (request a refund).
/// Tapping this button displays the standard StoreKit App Store Refund Request sheet.
///
/// ## Subscriptions ##
/// If the purchase is for a subscription a button is displayed allowing the user to "Manage Subscription".
/// Tapping this button displays the standard StoreKit App Store subscription sheet which shows the current subscription,
/// along with upgrade and downgrade options. The option to cancel the subscription is also displayed.
///
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperManagePurchaseView: View {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The type of product we're showing info for.
    @State private var productType: Product.ProductType = .consumable
    
    @State private var viewTitle = "Product Info"
    
    /// Purchase information related to a non-consumable.
    @State private var consumablePurchaseInfo: [SKHelperPurchaseInfo]?
    
    /// Purchase information related to a non-consumable.
    @State private var nonConsumablePurchaseInfo: SKHelperPurchaseInfo?
    
    /// Purchase information related to a subscription.
    @State private var subscriptionPurchaseInfo: SKHelperSubscriptionInfo?
    
    /// Determines if the manage purchase sheet is displayed.
    @State private var showManagePurchase = false
    
    /// If a refund is requestd this is the transaction id of for that refund.
    @State private var refundRequestTransactionId: UInt64 = UInt64.min
    
    /// Determines if the request refund sheet is displayed.
    @State private var showRefundSheet = false
    
    /// Determines if results from the refund request process are displayed.
    @State private var showRefundAlert: Bool = false
    
    /// Text related to the result of the most recent refund request.
    @State private var refundAlertText: String = ""
    
    /// Determines if the manage subscription sheet is displayed.
    @State private var showManageSubscriptionsSheet = false
    
    /// A binding to the currently selected `ProductId`.
    @Binding var selectedProductId: ProductId
    
    /// A binding that determines if the purchase info sheet is displayed.
    @Binding var showPurchaseInfoSheet: Bool
    
    /// Creates the `SKHelperManagePurchaseView`.
    public var body: some View {
        VStack {
            SKHelperSheetBarView(showSheet: $showPurchaseInfoSheet, title: viewTitle)

            ScrollView {

                Image(selectedProductId)
                    .resizable()
                    .clipShape(.circle)
                    .frame(maxWidth: 85, maxHeight: 85)
                    .scaledToFit()
                
                if let consumablePurchaseInfo {
                    
                    SKHelperPurchaseInfoMain(purchaseInfo: consumablePurchaseInfo, productType: .consumable)
                    
                } else if let nonConsumablePurchaseInfo {
                    
                    SKHelperPurchaseInfoMain(purchaseInfo: [nonConsumablePurchaseInfo], productType: .nonConsumable)
                    SKHelperPurchaseInfoManage(purchaseInfo: nonConsumablePurchaseInfo, refundRequestTransactionId: $refundRequestTransactionId, showRefundSheet: $showRefundSheet)
                    
                } else if let subscriptionPurchaseInfo {
                    
                    SKHelperSubscriptionInfoMain(subInfo: subscriptionPurchaseInfo)
                    SKHelperSubscriptionInfoManage(showManageSubscriptionsSheet: $showManageSubscriptionsSheet)
                    
                } else {
                    
                    VStack {
                        Text("Getting transaction info...").font(.subheadline)
                        ProgressView()
                    }
                    .padding()
                }
            }
        }
        .task { await getPurchaseInfo() }
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
    
    private func getPurchaseInfo() async {
        if store.isConsumable(productId: selectedProductId) {
            
            consumablePurchaseInfo = await store.consumablePurchaseInformation(for: selectedProductId)
            productType = .consumable
            viewTitle = consumablePurchaseInfo?.first?.name ?? "Purchase Info"
            
        } else if store.isNonConsumable(productId: selectedProductId) {
            
            nonConsumablePurchaseInfo = await store.nonConsumablePurchaseInformation(for: selectedProductId)
            productType = .nonConsumable
            viewTitle = nonConsumablePurchaseInfo?.name ?? "Purchase Info"
            
        } else if store.isAutoRenewableSubscription(productId: selectedProductId) {
            
            subscriptionPurchaseInfo = await store.subscriptionInformation(for: selectedProductId)
            productType = .autoRenewable
            viewTitle = consumablePurchaseInfo?.first?.name ?? "Subscription Info"
        }
    }
}

#Preview {
    SKHelperManagePurchaseView(
        selectedProductId: Binding.constant("com.rarcher.nonconsumable.flowers.large"),
        showPurchaseInfoSheet: Binding.constant(false))
    .environment(SKHelper())
}
