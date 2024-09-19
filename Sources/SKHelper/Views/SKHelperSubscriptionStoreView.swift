//
//  SKHelperSubscriptionStoreView.swift
//  SKHelper
//
//  Created by Russell Archer on 13/02/2024.
//

import SwiftUI
import StoreKit

/// Uses the StoreKit `SubscriptionStoreView` to create a list of all avaliable subscriptions.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperSubscriptionStoreView<Header: View, Control: View, Details: View>: View {
    
    /// A closure that returns a `View` providing an overview of a group of subscriptions.
    public typealias SubscriptionHeaderClosure = () -> Header
    
    /// A closure that is passed a `ProductId` and returns a `View` providing a subscription image and other details.
    public typealias SubscriptionControlClosure = (ProductId) -> Control
    
    /// A closure that is passed a `ProductId` and returns a `View` providing subscription details.
    public typealias SubscriptionDetailsClosure = (ProductId) -> Details
    
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// The `ProductId` of the currently selected subscription.
    @State private var selectedProductId = ""
    
    /// true if a subscription has been selected.
    @State private var subscriptionSelected = false
    
    /// The name of the subscription group from which to display subscriptions. If nil then we display all subscriptions in all groups.
    private var subscriptionGroupName: String?
    
    /// A closure which is called to display a view forming an overall header for the collection of subscriptions.
    private var subscriptionHeader: SubscriptionHeaderClosure?
    
    /// A closure which is called to display a view which provides a brief overview of each subscription.
    private var subscriptionControl: SubscriptionControlClosure?
    
    /// A closure which is called to display subscription details when the user taps the subscription's image.
    private var subscriptionDetails: SubscriptionDetailsClosure?
    
    /// Gets either all subscriptions in all groups, or subscriptions in a specific group if `subscriptionGroupName` was provided to init.
    private var subscriptions: [Product] {
        subscriptionGroupName == nil ? store.allSubscriptions : store.allSubscriptionProductsByLevel(for: subscriptionGroupName!)
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    /// - Parameters:
    ///   - subscriptionGroupName: The group name from which subscriptions will be displayed. If nil then all subscriptions in all groups will be displayed.
    ///   - subscriptionHeader: A closure that customizes the header displayed. If nil then no header is displayed.
    ///   - subscriptionControl: A closure that customizes the in-line control content displayed. If nil then no customization is displayed.
    ///   - subscriptionDetails: A closure that customizes the subscription details content displayed. If nil then no customization is displayed.
    public init(
        subscriptionGroupName: String? = nil,
        @ViewBuilder subscriptionHeader: @escaping SubscriptionHeaderClosure,
        @ViewBuilder subscriptionControl: @escaping SubscriptionControlClosure,
        @ViewBuilder subscriptionDetails: @escaping SubscriptionDetailsClosure) {
        
        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = subscriptionHeader
        self.subscriptionControl = subscriptionControl
        self.subscriptionDetails = subscriptionDetails
    }
    
    /// Creates the body of the view.
    public var body: some View {
        if store.hasSubscriptionProducts {
            ScrollView {
                SubscriptionStoreView(subscriptions: subscriptions) {
                    VStack { subscriptionHeader?() }.padding()
                }
                .subscriptionStoreButtonLabel(.action)
                .subscriptionStoreControlStyle(.prominentPicker)
                #if os(iOS)
                .storeButton(.visible, for: .redeemCode)
                #endif
                .storeButton(.visible, for: .restorePurchases, .policies)
                .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
                .subscriptionStorePolicyDestination(url: URL(string: "https://russell-archer.github.io/Writerly/privacy/")!, for: .privacyPolicy)
                .subscriptionStorePolicyDestination(url: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!, for: .termsOfService)
                .subscriptionStoreControlIcon { subscription, info in
                    
                    subscriptionControl?(subscription.id)
                        .SKHelperOnTapGesture {
                            selectedProductId = subscription.id
                            subscriptionSelected.toggle()
                        }
                }
                .sheet(isPresented: $subscriptionSelected) {
                    if let subscriptionDetails {
                        SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $subscriptionSelected, productDetails: subscriptionDetails)
                    } else {
                        SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $subscriptionSelected)
                    }
                }
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

// MARK: - Additional initializers

extension SKHelperSubscriptionStoreView {
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String,
        @ViewBuilder subscriptionHeader: @escaping SubscriptionHeaderClosure) where Control == EmptyView, Details == EmptyView {
            
        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = subscriptionHeader
        self.subscriptionControl = nil
        self.subscriptionDetails = nil
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String,
        @ViewBuilder subscriptionControl: @escaping SubscriptionControlClosure) where Header == EmptyView, Details == EmptyView {
            
        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = nil
        self.subscriptionControl = subscriptionControl
        self.subscriptionDetails = nil
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String,
        @ViewBuilder subscriptionDetails: @escaping SubscriptionDetailsClosure) where Header == EmptyView, Control == EmptyView {
            
        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = nil
        self.subscriptionControl = nil
        self.subscriptionDetails = subscriptionDetails
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String,
        @ViewBuilder subscriptionHeader: @escaping SubscriptionHeaderClosure,
        @ViewBuilder subscriptionControl: @escaping SubscriptionControlClosure) where Details == EmptyView {

        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = subscriptionHeader
        self.subscriptionControl = subscriptionControl
        self.subscriptionDetails = nil
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String,
        @ViewBuilder subscriptionHeader: @escaping SubscriptionHeaderClosure,
        @ViewBuilder subscriptionDetails: @escaping SubscriptionDetailsClosure) where Control == EmptyView {

        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = subscriptionHeader
        self.subscriptionControl = nil
        self.subscriptionDetails = subscriptionDetails
    }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(subscriptionGroupName: String) where Header == EmptyView, Control == EmptyView, Details == EmptyView {
        self.subscriptionGroupName = subscriptionGroupName
        self.subscriptionHeader = nil
        self.subscriptionControl = nil
        self.subscriptionDetails = nil
    }
}

#Preview {
    
    SKHelperSubscriptionStoreView(
        subscriptionGroupName: "vip",
        subscriptionHeader: {
            VStack {
                Image("plant-services").resizable().scaledToFit()
                Text("Our top-rated serices will make your plants happy").font(.headline)
            }
        },
        subscriptionControl: { productId in
            
            VStack {
                Image(productId).resizable().scaledToFit()
                Text("A florist will call \(productId == "com.rarcher.subscription.vip.gold" ? "weekly" : "monthly") to water your plants.").font(.caption2)
            }
        },
        subscriptionDetails: { productId in
            
            VStack {
                Image(productId + ".info").resizable().scaledToFit()
                Text("Here is some text about why you might want to buy this product.")
            }
        })
    .environment(SKHelper())
}
