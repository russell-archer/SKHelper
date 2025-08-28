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
    
    /// True if a subscription has been selected.
    @State private var subscriptionSelected = false
    
    /// True if the store has products.
    @State private var hasProducts = false
    
    /// Set to true to display the subscription info and management sheet.
    @State private var manageSubscription = false
    
    /// Setting this value to true will display a sheet showing active subscriptions from which the user can choose. Used when the user
    /// taps the "Manage Subscriptions" button and there is more than one currently active subscription.
    @State private var showSubscriptionSelection = false
    
    /// Collection of all active subscriptions. Initialized when the user taps the "Manage Subscriptions" button.
    @State private var allActiveSubscriptions = [ProductId]()
    
    /// The name of the subscription group from which to display subscriptions. If nil then we display all subscriptions in all groups.
    private var subscriptionGroupName: String?
    
    /// A closure which is called to display a view forming an overall header for the collection of subscriptions.
    private var subscriptionHeader: SubscriptionHeaderClosure?
    
    /// A closure which is called to display a view which provides a brief overview of each subscription.
    private var subscriptionControl: SubscriptionControlClosure?
    
    /// A closure which is called to display subscription details when the user taps the subscription's image.
    private var subscriptionDetails: SubscriptionDetailsClosure
    
    /// Gets either all subscriptions in all groups, or subscriptions in a specific group if `subscriptionGroupName` was provided to init.
    private var subscriptions: [Product] {
        subscriptionGroupName == nil ? store.allAutoRenewableSubscriptions : store.allAutoRenewableSubscriptionProductsByLevel(for: subscriptionGroupName!)
    }
    
    /// Used to determine if this view has requested a refresh of localized product information. This happens automatically
    /// once only if `SKHelper.hasProducts` is false.
    @State private var hasRequestedProducts = false
    
    /// Used to check multiple times for product availability.
    private let refreshProducts = Timer.publish(every: 1, on: .main, in: .common)
    
    /// URL used for the app's privacy policy.
    private var privacyPolicyURL: String = ""
    
    /// URL used for the app's terms of service.
    private var termsOfServiceURL: String = ""
    
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
            self.privacyPolicyURL = SKHelperConfiguration.configurationValue(for: .privacyPolicyUrl)
            self.termsOfServiceURL = SKHelperConfiguration.configurationValue(for: .termsOfServiceUrl)
    }
    
    /// Creates the body of the view.
    public var body: some View {
        if hasProducts {
            ScrollView {
                SubscriptionStoreView(subscriptions: subscriptions) {
                    VStack {
                        subscriptionHeader?()
                        managementSheetButton().padding(10)
                    }
                    .padding()
                }
                .subscriptionStoreButtonLabel(.action)
                .subscriptionStoreControlStyle(.prominentPicker)
                #if os(iOS)
                .storeButton(.visible, for: .redeemCode)
                #endif
                .storeButton(.visible, for: .restorePurchases, .policies)
                .storeButton(.hidden, for: .cancellation)  // Hides the close "X" at the top-right of the view
                .subscriptionStorePolicyDestination(url: URL(string: privacyPolicyURL)!, for: .privacyPolicy)
                .subscriptionStorePolicyDestination(url: URL(string: termsOfServiceURL)!, for: .termsOfService)
                .subscriptionStoreControlIcon { subscription, info in
                    if let subscriptionControl { subscriptionControl(subscription.id).SKHelperOnTapGesture(perform: tapAction(subscription: subscription)) }
                    else { defaultSubscriptionControl(productId: subscription.id).SKHelperOnTapGesture(perform: tapAction(subscription: subscription)) }
                }
                .sheet(isPresented: $subscriptionSelected) {
                    SKHelperProductView(selectedProductId: $selectedProductId, showProductInfoSheet: $subscriptionSelected, productDetails: subscriptionDetails)
                }
                .sheet(isPresented: $manageSubscription) {
                    SKHelperManagePurchaseView(selectedProductId: $selectedProductId, showPurchaseInfoSheet: $manageSubscription)
                }
                .sheet(isPresented: $showSubscriptionSelection) {
                    subscriptionSelection()
                }
            }
        } else {
            
            VStack {
                Text("No subscriptions available").font(.subheadline).padding()
                Button("Refresh Subscriptions") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
            .onProductsAvailable { _ in hasProducts = store.hasAutoRenewableSubscriptionProducts }
            .task {
                if !hasRequestedProducts, !hasProducts, store.autoRequestProducts {
                    hasRequestedProducts = true
                    let _ = await store.requestProducts()
                    hasProducts = store.hasProducts
                }
            }
        }
    }
    
    func defaultSubscriptionControl(productId: ProductId) -> some View {
        VStack {
            Image(productId).resizable().scaledToFit().padding(3)
            HStack {
                Image(systemName: "info.circle").font(.title3).foregroundColor(.blue)
                Text("Info").font(.callout)
            }
        }
    }
    
    func tapAction(subscription: Product) -> () -> Void {
        {
            selectedProductId = subscription.id
            subscriptionSelected.toggle()
        }
    }
    
    func managementSheetButton() -> some View {
        Button(action: { showSubscriptionSelection.toggle() }) {
            Label(title: { Text("Manage Subscriptions").padding()},
                  icon:  { Image(systemName: "creditcard.circle").resizable().scaledToFit().frame(height: 24)})
        }
        .SKHelperButtonStyleBorderedProminent()
    }
    
    func subscriptionSelection() -> some View {
        return VStack {
            Text("\(allActiveSubscriptions.count > 0 ? "Select the active subscription you want to manage." : "No active subscriptions found.")").padding()
            List(allActiveSubscriptions, id: \.self) { productId in
                Text(store.productDisplayName(from: productId))
                    .SKHelperOnTapGesture { showSubManagement(productId: productId) }.padding(5)
            }
            .task {
                allActiveSubscriptions = await store.allActiveSubscriptions()
                
                // Don't show the subscription selection sheet if there's only one active sub - go direct the management sheet
                if allActiveSubscriptions.count == 1 { showSubManagement(productId: allActiveSubscriptions.first!) }
            }
            .padding()
        }
        .presentationDetents([.medium, .large])
        .padding()
        
        func showSubManagement(productId: ProductId) {
            selectedProductId = productId
            manageSubscription = true
            showSubscriptionSelection = false
        }
    }
}

// MARK: - Additional initializers

extension SKHelperSubscriptionStoreView {
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String? = nil,
        @ViewBuilder subscriptionDetails: @escaping SubscriptionDetailsClosure) where Header == EmptyView, Control == EmptyView {
            
            self.subscriptionGroupName = subscriptionGroupName
            self.subscriptionHeader = nil
            self.subscriptionControl = nil
            self.subscriptionDetails = subscriptionDetails
            self.privacyPolicyURL = SKHelperConfiguration.configurationValue(for: .privacyPolicyUrl)
            self.termsOfServiceURL = SKHelperConfiguration.configurationValue(for: .termsOfServiceUrl)
        }
    
    /// Creates a `SKHelperSubscriptionStoreView`.
    public init(
        subscriptionGroupName: String? = nil,
        @ViewBuilder subscriptionHeader: @escaping SubscriptionHeaderClosure,
        @ViewBuilder subscriptionDetails: @escaping SubscriptionDetailsClosure) where Control == EmptyView {
            
            self.subscriptionGroupName = subscriptionGroupName
            self.subscriptionHeader = subscriptionHeader
            self.subscriptionControl = nil
            self.subscriptionDetails = subscriptionDetails
            self.privacyPolicyURL = SKHelperConfiguration.configurationValue(for: .privacyPolicyUrl)
            self.termsOfServiceURL = SKHelperConfiguration.configurationValue(for: .termsOfServiceUrl)
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
        subscriptionDetails: { productId in
            
            VStack {
                Image(productId + ".info").resizable().scaledToFit()
                Text("Here is some text about why you might want to buy this product.")
            }
        })
    .environment(SKHelper())
}

