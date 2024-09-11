//
//  SKHelperSubscriptionInfo.swift
//  SKHelper
//
//  Created by Russell Archer on 19/08/2024.
//

import StoreKit

/// Information about the purchase of an auto-renewable subscription product.
@MainActor
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperSubscriptionInfo: Hashable {
    
    /// Creates an `SKHelperSubscriptionInfo`.
    ///
    /// - Parameter product: A StoreKit `Product` object.
    /// 
    public init(product: Product) {
        self.product        = product
        self.productId      = product.id
        self.name           = product.displayName
        self.isSubscribed   = false
        self.isSuperceeded  = false
        self.productType    = product.type
        self.displayPrice   = product.displayPrice
        self.groupName      = product.subscription?.groupDisplayName
        self.groupId        = product.subscription?.subscriptionGroupID
        self.history        = [SKHelperSubscriptionHistory]()
    }
    
    /// The StoreKit `Product` that describes the auto-renewable subscription.
    public var product: Product
    
    /// The product's unique id.
    public var productId: ProductId
    
    /// The product's display name.
    public var name: String
    
    /// The subscription group display name (localized "reference name"). For example, "vip".
    public var groupName: String?

    /// The subscription group id (localized "reference name"). For example, "198AC052".
    public var groupId: String?
    
    /// true if the user has a currently active subscription to the product. If the value of `isSuperceeded` is true then `isSubscribed` will be false.
    public var isSubscribed: Bool
    
    /// true if the user is subscribed to a higher-value product in the subscription group.
    public var isSuperceeded: Bool
    
    /// Consumable, non-consumable, subscription, etc.
    public var productType: Product.ProductType
    
    /// true if the transaction that confers an entitlement has been verified
    public var isVerified: Bool?
    
    /// Display text for the subscribed state.
    public var subscribedtext: String?
    
    /// true if the product has been upgraded.
    public var upgraded: Bool?
    
    /// true if auto-renew is on.
    public var autoRenewOn: Bool?
    
    /// Display text for the renewal period (e.g. "Every month").
    public var renewalPeriod: String?
    
    /// Display text for the renewal date.
    public var renewalDate: String?
    
    /// Display text for when the subscription renews (e.g. "12 days").
    public var renewsIn: String?
    
    /// Localized price paid when purchased.
    public var displayPrice: String?
    
    /// Most recent date of purchase.
    public var purchaseDate: Date?
    
    /// Most recent date of purchase formatted as "d MMM y" (e.g. "28 Dec 2021").
    public var purchaseDateFormatted: String?
    
    /// Transactionid for most recent purchase. UInt64.min if not purchased.
    public var transactionId: UInt64?
    
    /// Date the app store revoked the purchase (e.g. because of a refund, etc.).
    public var revocationDate: Date?
    
    /// Date of revocation formatted as "d MMM y".
    public var revocationDateFormatted: String?
    
    /// Why the purchase was revoked (.developerIssue or .other).
    public var revocationReason: StoreKit.Transaction.RevocationReason?
    
    /// Either .purchased or .familyShared.
    public var ownershipType: StoreKit.Transaction.OwnershipType?
    
    /// A collection of all historical purchases of this auto-renewable subscription product.
    public var history: [SKHelperSubscriptionHistory]
}

/// Information about a historical purchase of an auto-renewable subscription product.
@available(iOS 17.0, macOS 14.6, *)
@MainActor
public struct SKHelperSubscriptionHistory: Hashable, Identifiable {
    /// Transactionid for most recent purchase.
    public var id: String
    
    /// The product's unique id.
    public var productId: ProductId
            
    /// Localized price paid when the transaction took place.
    public var displayPrice: String?
    
    /// Most recent date of purchase.
    public var purchaseDate: Date?
    
    /// Most recent date of purchase formatted as "d MMM y" (e.g. "28 Dec 2021").
    public var purchaseDateFormatted: String?
    
    /// Transactionid for most recent purchase.
    public var transactionId: UInt64?
}
