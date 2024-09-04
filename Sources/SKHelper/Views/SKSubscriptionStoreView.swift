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
        if store.hasSubscriptionProducts {
            SubscriptionStoreView(subscriptions: store.allSubscriptionProductsByLevel(for: "vip")) {
                Image(systemName: "cart.fill")
                    .resizable()
                    .frame(maxWidth: 85, maxHeight: 85)
                    .scaledToFit()
            }
            .subscriptionStoreButtonLabel(.action)
            .subscriptionStoreControlStyle(.prominentPicker)
            .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
            .storeButton(.visible, for: .restorePurchases, .policies)
            .subscriptionStorePolicyDestination(url: URL(string: "https://russell-archer.github.io/Writerly/privacy/")!, for: .privacyPolicy)
            .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
            #if os(iOS)
            .storeButton(.visible, for: .redeemCode)
            #endif
            .subscriptionStoreControlIcon { subscription, info in
                Image(subscription.id)
                    .resizable()
                    .scaledToFit()
            }
        } else {
            
            VStack {
                Text("No subscriptions available").font(.subheadline)
                Button("Refresh Subscriptions") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
        }
    }
}

#Preview {
    SKSubscriptionStoreView().environment(SKHelper())
}
