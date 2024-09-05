//
//  SKHelper+Extensions.swift
//  SKHelper
//
//  Created by Russell Archer on 04/08/2024.
//

public import StoreKit

public typealias ProductId = String

@available(iOS 17.0, macOS 14.6, *)
public extension SKHelper {
    
    // MARK: - Public product helper properties
    
    /// All `SKProduct` products.
    var allSKProducts: [SKProduct] { products }
    
    /// All `SKProduct` products that represent consumables.
    var allSKConsumableProducts: [SKProduct] { products.filter { $0.product.type == .consumable }}
    
    /// All `SKProduct` products that represent non-consumables.
    var allSKNonConsumableProducts: [SKProduct] { products.filter { $0.product.type == .nonConsumable }}
    
    /// All `SKProduct` products that represent auto-renewable subscriptions.
    var allSKSubscriptionProducts: [SKProduct] { products.filter { $0.product.type == .autoRenewable }}
    
    /// All `SKProduct` products that represent purchased products.
    var allSKPurchasedProducts: [SKProduct] { products.filter { $0.hasEntitlement }}
    
    /// A collection of all localized `Product` returned by the App Store. An empty collection will be returned if products have not been successfully returned fromt he App Store.
    var allProducts: [Product] { products.map { $0.product }}
    
    /// A collection of all configured `ProductId`.
    var allProductIds: [ProductId] { products.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent consumables.
    var allConsumableProductIds: [ProductId] { products.filter { $0.product.type == .consumable }.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent non-consumables.
    var allNonConsumableProductIds: [ProductId] { products.filter { $0.product.type == .nonConsumable }.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent auto-renewable subscriptions.
    var allSubscriptionProductIds: [ProductId] { products.filter { $0.product.type == .autoRenewable }.map { $0.id }}
    
    /// All `ProductId` that represent purchased products.
    var allPurchasedProductIds: [ProductId] { products.filter { $0.hasEntitlement }.map { $0.id }}
    
    /// This property is true if `SKHelper.products` contains a valid collection of products, false otherwise.
    var hasProducts: Bool { !products.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more consumable products, false otherwise.
    var hasConsumableProducts: Bool { !allSKConsumableProducts.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more non-consumable products, false otherwise.
    var hasNonConsumableProducts: Bool { !allSKNonConsumableProducts.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more subscription products, false otherwise.
    var hasSubscriptionProducts: Bool { !allSKSubscriptionProducts.isEmpty }
    
    // MARK: - Public helper methods
    
    /// The first `SKProduct` in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the first `SKProduct` in `SKHelper.products` whose `id` matches the supplied `ProductId`, or nil if no match is found.
    ///
    func skProduct(for productId: ProductId) -> SKProduct? {
        products.first(where: { $0.id == productId })
    }
    
    /// The first `Product` in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the first `Product` in `SKHelper.products` whose `id` matches the supplied `ProductId`, or nil if no match is found.
    ///
    func product(from productId: ProductId) -> Product? {
        products.first(where: { $0.id == productId })?.product
    }
    
    /// The products in `SKHelper.products` whose ids match the supplied [`ProductId`].
    ///
    /// - Parameter productIds: The collection of [`ProductId`] to search for in `SKHelper.products`.
    /// - Returns: Returns the products in `SKHelper.products` whose ids match the supplied [`ProductId`]. An empty collection is returned if no matches are found.
    ///
    func products(from productIds: [ProductId]) -> [Product] {
        productIds.compactMap { product(from: $0) }
    }
    
    /// Finds the first auto-renewable subscription in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns true if an auto-renewable subscription in `SKHelper.products` matches the supplied `ProductId`, false otherwise.
    ///
    func isAutoRenewable(productId: ProductId) -> Bool {
        allSubscriptionProductIds.contains(productId)
    }
    
    /// Finds the first non-consumable product in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns true if a non-consumable product in `SKHelper.products` matches the supplied `ProductId`, false otherwise.
    ///
    func isNonConsumable(productId: ProductId) -> Bool {
        allNonConsumableProductIds.contains(productId)
    }
    
    /// Finds the first consumable product in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns true if a consumable product in `SKHelper.products` matches the supplied `ProductId`, false otherwise.
    ///
    func isConsumable(productId: ProductId) -> Bool {
        allConsumableProductIds.contains(productId)
    }
    
    /// Finds the subscription group name (`groupDisplayName`) in `SKHelper.products` for the product that matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the subscription group name (`groupDisplayName`) for the product that matches the supplied `ProductId`, or nil if no match is found.
    ///
    func subscriptionGroupName(for productId: ProductId) -> String? {
        products.first(where: { $0.id == productId })?.product.subscription?.groupDisplayName
    }
    
    /// Finds the subscription group id (`subscriptionGroupID`) in `SKHelper.products` for the product that matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the subscription group id (`subscriptionGroupID`) for the product that matches the supplied `ProductId`, or nil if no match is found.
    ///
    func subscriptionGroupId(for productId: ProductId) -> String? {
        products.first(where: { $0.id == productId })?.product.subscription?.subscriptionGroupID
    }
    
    /// Finds the subscription group id (`subscriptionGroupID`) in `SKHelper.products` for the product that matches the supplied group name.
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`) to search for in `SKHelper.products`.
    /// - Returns: Returns the subscription group id (`subscriptionGroupID`) for the product that matches the supplied group name, or nil if no match is found.
    ///
    func subscriptionGroupId(from groupName: String) -> String? {
        products.first(where: { $0.groupName?.localizedLowercase == groupName.localizedLowercase })?.product.subscription?.subscriptionGroupID
    }
    
    /// The first `Product.SubscriptionInfo` in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the first `Product.SubscriptionInfo` in `SKHelper.products` whose `id` matches the supplied `ProductId`, or nil if no match is found.
    ///
    func subscription(from productId: ProductId) -> Product.SubscriptionInfo? {
        products.first(where: { $0.id == productId })?.product.subscription
    }
    
    /// The subscriptions in `SKHelper.products` whose ids match the supplied [`ProductId`].
    ///
    /// - Parameter productIds: The collection of `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the subscriptions in `SKHelper.products` whose ids match the supplied [`ProductId`]. An empty collection is returned if no matches are found.
    ///
    func subscriptions(from productIds: [ProductId]) -> [Product.SubscriptionInfo] {
        productIds.compactMap { subscription(from: $0) }
    }
    
    /// Finds all subscription group names (`groupDisplayName`) in `SKHelper.products`.
    ///
    /// - Returns: Returns all subscription group names (`groupDisplayName`) in `SKHelper.products`. An empty collection is returned if there are no auto-renewable subscription products.
    ///
    func allSubscriptionGroupNames() -> [String] {
        Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.groupName ?? "" }.filter { !$0.isEmpty }))
    }
    
    /// Finds all subscription group ids (`subscriptionGroupID`) in `SKHelper.products`.
    ///
    /// - Returns: Returns all subscription group ids (`subscriptionGroupID`) in `SKHelper.products`. An empty collection is returned if there are no auto-renewable subscription products.
    ///
    func allSubscriptionGroupIds() -> [String] {
        Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.groupId ?? "" }.filter { !$0.isEmpty }))
    }
    
    /// Finds all subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns all subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allSubscriptionStoreProducts(for groupName: String) -> [SKProduct] {
        products.filter { $0.product.type == .autoRenewable && $0.groupName == groupName }
    }
    
    /// Finds all subscription products in `SKHelper.products` that match the supplied subscription group name. The resulting collection is sorted by subscription group level (value).
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns the `ProductId` of all subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allSubscriptionProductIdsByLevel(for groupName: String) -> [ProductId] {
        allSubscriptionStoreProducts(for: groupName).sorted { $0.groupLevel < $1.groupLevel}.map { $0.id }
    }
    
    /// Finds a collection of all subscription `Product` in `SKHelper.products` that match the supplied subscription group name. The resulting collection is sorted by subscription group level (value).
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns a collection of all subscription `Product` in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allSubscriptionProductsByLevel(for groupName: String) -> [Product] {
        allSubscriptionStoreProducts(for: groupName).sorted { $0.groupLevel < $1.groupLevel}.map { $0.product }
    }
}

// MARK: - SKUnwrappedVerificationResult

/// Information on the result of unwrapping a transaction `VerificationResult`.
@available(iOS 17.0, macOS 14.6, *)
public struct SKUnwrappedVerificationResult<T: Sendable> : Sendable {
    
    /// The verified or unverified transaction.
    public let transaction: T
    
    /// True if the transaction was successfully verified by StoreKit.
    public let verified: Bool
    
    /// If `verified` is false then `verificationError` will hold the verification error, nil otherwise.
    public let verificationError: VerificationResult<T>.VerificationError?
}

// MARK: - SKPurchaseState

/// The state of a purchase.
@available(iOS 17.0, macOS 14.6, *)
public enum SKPurchaseState {
    /// A purchase has not yet started.
    case notStarted
    
    /// The user is not able to make payments, so a purchase cannot proceed.
    case userCannotMakePayments
    
    /// A purchase is in progress.
    case inProgress
    
    /// A product has just been purchased.
    case purchased
    
    /// A purchase is pending approval (e.g. from a parent).
    case pending
    
    /// A purchase process has been cancelled by the user before completion.
    case cancelled
    
    /// A purchase failed.
    case failed
    
    /// A purchase completed but the transaction could not be verified.
    case failedVerification
    
    /// The state of the purchase could not be determined.
    case unknown
    
    /// The product is not purchased.
    case notPurchased
    
    /// A purchase resulted in an error.
    case error
    
    /// A purchase cannot proceed because another purchase is already in progress.
    case puchaseAlreadyInProgress
    
    /// A short description of the state of a purchase.
    ///
    /// - Returns: Returns a short description of the state of a purchase.
    ///
    public func shortDescription() -> String {
        switch self {
            case .notStarted:               return "Purchase has not started"
            case .userCannotMakePayments:   return "User cannot make payments"
            case .inProgress:               return "Purchase in-progress"
            case .purchased:                return "Purchased"
            case .pending:                  return "Purchase pending"
            case .cancelled:                return "Purchase cancelled"
            case .failed:                   return "Purchase failed"
            case .failedVerification:       return "Purchase failed verification"
            case .unknown:                  return "Purchase status unknown"
            case .notPurchased:             return "Not purchased"
            case .error:                    return "Purchase error"
            case .puchaseAlreadyInProgress: return "Another purchase is already in progress"
                
        }
    }
}

// MARK: - SKSubscriptionState

/// The state of a subscription.
@available(iOS 17.0, macOS 14.6, *)
public enum SKSubscriptionState {
    
    /// No activate subscription to this product has been found
    case notSubscribed
    
    /// The transaction for this subscription could not be verified
    case notVerified
    
    /// An activate subscription to this product has been found
    case subscribed
    
    /// The subscription to this product has been superceeded by a subscription to a higher value product in the same subscription group
    case superceeded
}

// MARK: - SKEntitlementState

/// The state of an entitlement to a product.
@available(iOS 17.0, macOS 14.6, *)
public enum SKEntitlementState {
    
    /// No transaction for the product has been found.
    case noEntitlement
    
    /// The transaction for this purchase could not be verified.
    case notVerified
    
    /// The user has a verified entitlement to access the product.
    case verifiedEntitlement
    
    /// Access to the purchase has been revoked by the App Store.
    case revoked
}
