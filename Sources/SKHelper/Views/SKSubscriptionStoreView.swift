//
//  SKSubscriptionStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// Uses the StoreKit `SubscriptionStoreView` to create a list of all avaliable subscriptions.
@available(iOS 17.0, macOS 14.6, *)
public struct SKSubscriptionStoreView: View {
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Creates a `SKSubscriptionStoreView`.
    public init() {}
    
    /// Creates the body of the view.
    public var body: some View {
        SubscriptionStoreView(productIDs: store.allSubscriptionProductIdsByLevel(for: "vip")) {
            Image(systemName: "cart.fill")
                .resizable()
                .frame(maxWidth: 85, maxHeight: 85)
                .scaledToFit()
        }
        .subscriptionStoreButtonLabel(.action)
        .subscriptionStoreControlStyle(.prominentPicker)
        .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
        .storeButton(.visible, for: .restorePurchases)
        #if os(iOS)
        .storeButton(.visible, for: .redeemCode)
        #endif
        .subscriptionStoreControlIcon { subscription, info in
            Image(subscription.id)
                .resizable()
                .scaledToFit()
        }
    }
}

#Preview {
    SKSubscriptionStoreView().environment(SKHelper())
}
