//
//  SKHelper+Extensions.swift
//  SKHelper
//
//  Created by Russell Archer on 04/08/2024.
//

public import SwiftUI
public import StoreKit

public typealias ProductId = String
public typealias TransactionId = String
public typealias SubscriptionStatusChangeClosure = (_ productId: ProductId, _ transactionId: TransactionId, _ renewalState: Product.SubscriptionInfo.RenewalState, _ hasExpired: Bool) -> Void

@available(iOS 17.0, macOS 14.6, *)
public extension SKHelper {
    
    // MARK: - Public product helper properties
    
    /// All `SKHelperProduct` products.
    var allSKHelperProducts: [SKHelperProduct] { products }
    
    /// All `SKHelperProduct` products that represent consumables.
    var allSKHelperConsumableProducts: [SKHelperProduct] { products.filter { $0.product.type == .consumable }}
    
    /// All `SKHelperProduct` products that represent non-consumables.
    var allSKHelperNonConsumableProducts: [SKHelperProduct] { products.filter { $0.product.type == .nonConsumable }}
    
    /// All `SKHelperProduct` products that represent auto-renewable subscriptions.
    var allSKHelperAutoRenewableSubscriptionProducts: [SKHelperProduct] { products.filter { $0.product.type == .autoRenewable }}
    
    /// All `SKHelperProduct` products that represent non-renewable subscriptions.
    var allSKHelperNonRenewableSubscriptionProducts: [SKHelperProduct] { products.filter { $0.product.type == .nonRenewable }}
    
    /// All `SKHelperProduct` products that represent purchased products.
    var allSKHelperPurchasedProducts: [SKHelperProduct] { products.filter { $0.hasEntitlement }}
    
    /// A collection of all localized `Product` returned by the App Store. An empty collection will be returned if products have not been successfully returned fromt he App Store.
    var allProducts: [Product] { products.map { $0.product }}
    
    /// A collection of all configured `ProductId`.
    var allProductIds: [ProductId] { products.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent consumables.
    var allConsumableProductIds: [ProductId] { products.filter { $0.product.type == .consumable }.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent non-consumables.
    var allNonConsumableProductIds: [ProductId] { products.filter { $0.product.type == .nonConsumable }.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent auto-renewable subscriptions.
    var allAutoRenewableSubscriptionProductIds: [ProductId] { products.filter { $0.product.type == .autoRenewable }.map { $0.id }}
    
    /// A collection of all configured `ProductId` that represent auto-renewable subscriptions.
    var allNonRenewabaleSubscriptionProductIds: [ProductId] { products.filter { $0.product.type == .nonRenewable }.map { $0.id }}
    
    /// A collection of all configured `Product` that represent auto-renewable subscriptions in all subscription groups.
    var allAutoRenewableSubscriptions: [Product] { products.filter { $0.product.type == .autoRenewable }.map { $0.product }}
    
    /// Finds all subscription group names (`groupDisplayName`) in `SKHelper.products`.
    /// An empty collection is returned if there are no auto-renewable subscription products.
    var allSubscriptionGroupNames: [String] { Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.groupName ?? "" }.filter { !$0.isEmpty }))}
    
    /// Finds all subscription group ids (`subscriptionGroupID`) in `SKHelper.products`.
    /// An empty collection is returned if there are no auto-renewable subscription products.
    var allSubscriptionGroupIds: [String] { Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.groupId ?? "" }.filter { !$0.isEmpty }))}
    
    /// All `ProductId` that represent purchased products.
    var allPurchasedProductIds: [ProductId] { products.filter { $0.hasEntitlement }.map { $0.id }}
    
    /// This property is true if `SKHelper.products` contains a valid collection of products, false otherwise.
    var hasProducts: Bool { !products.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more consumable products, false otherwise.
    var hasConsumableProducts: Bool { !allSKHelperConsumableProducts.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more non-consumable products, false otherwise.
    var hasNonConsumableProducts: Bool { !allSKHelperNonConsumableProducts.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more auto-renewable subscription products, false otherwise.
    var hasAutoRenewableSubscriptionProducts: Bool { !allSKHelperAutoRenewableSubscriptionProducts.isEmpty }
    
    /// This property is true if `SKHelper.products` contains one or more non-renewable subscription products, false otherwise.
    var hasNonRenewableSubscriptionProducts: Bool { !allSKHelperNonRenewableSubscriptionProducts.isEmpty }
    
    // MARK: - Public helper methods
    
    /// The first `SKHelperProduct` in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the first `SKHelperProduct` in `SKHelper.products` whose `id` matches the supplied `ProductId`, or nil if no match is found.
    ///
    func skhelperProduct(for productId: ProductId) -> SKHelperProduct? {
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
    
    /// The display name of the first `Product` in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns the display name of the first `Product` in `SKHelper.products` whose `id` matches the supplied `ProductId`., or an empty `String` if no match is found.
    ///
    func productDisplayName(from productId: ProductId) -> String {
        products.first(where: { $0.id == productId })?.product.displayName ?? ""
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
    func isAutoRenewableSubscription(productId: ProductId) -> Bool {
        allAutoRenewableSubscriptionProductIds.contains(productId)
    }
    
    /// Finds the first non-renewable subscription in `SKHelper.products` whose `id` matches the supplied `ProductId`.
    ///
    /// - Parameter productId: The `ProductId` to search for in `SKHelper.products`.
    /// - Returns: Returns true if a non-renewable subscription in `SKHelper.products` matches the supplied `ProductId`, false otherwise.
    ///
    func isNonRenewableSubscription(productId: ProductId) -> Bool {
        allAutoRenewableSubscriptionProductIds.contains(productId)
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
    
    /// Finds all auto-renewable subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns all auto-renewable subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allAutoRenewableSubscriptionStoreProducts(for groupName: String) -> [SKHelperProduct] {
        products.filter { $0.product.type == .autoRenewable && $0.groupName == groupName }
    }
    
    /// Finds all auto-renewable subscription products in `SKHelper.products` that match the supplied subscription group name.
    /// The resulting collection is sorted by subscription group level (value).
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns the `ProductId` of all auto-renewable subscription products in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allAutoRenewableSubscriptionProductIdsByLevel(for groupName: String) -> [ProductId] {
        allAutoRenewableSubscriptionStoreProducts(for: groupName).sorted { $0.groupLevel < $1.groupLevel}.map { $0.id }
    }
    
    /// Finds a collection of all auto-renewable subscription `Product` in `SKHelper.products` that match the supplied subscription group name.
    /// The resulting collection is sorted by subscription group level (value).
    ///
    /// - Parameter groupName: The group name (`groupDisplayName`)  to search for in `SKHelper.products`.
    /// - Returns: Returns a collection of all auto-renewable subscription `Product` in `SKHelper.products` that match the supplied subscription group name.
    ///
    func allAutoRenewableSubscriptionProductsByLevel(for groupName: String) -> [Product] {
        allAutoRenewableSubscriptionStoreProducts(for: groupName).sorted { $0.groupLevel < $1.groupLevel}.map { $0.product }
    }
    
    /// The `Transaction` associated with a unique id. Searches the user's complete transaction history.
    /// - Parameter transactionId: The transaction's unique id.
    /// - Returns: Returns the `Transaction` associated with the unique id, or nil if the transaction cannot be found or can't be verified.
    ///
    func transaction(for transactionId: UInt64) async -> StoreKit.Transaction? {
        for await transactionResult in Transaction.all {
            if transactionResult.unsafePayloadValue.id != transactionId { continue }

            // Get the verified transaction object
            let unwrappedTransactionResult = checkVerificationResult(result: transactionResult)
            if !unwrappedTransactionResult.verified { return nil }  // We couldn't verify this transaction
            return unwrappedTransactionResult.transaction
        }
        
        return nil
    }
}

// MARK: - SKHelperUnwrappedVerificationResult

/// Information on the result of unwrapping a transaction `VerificationResult`.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperUnwrappedVerificationResult<T: Sendable> : Sendable {
    
    /// The verified or unverified transaction.
    public let transaction: T
    
    /// True if the transaction was successfully verified by StoreKit.
    public let verified: Bool
    
    /// If `verified` is false then `verificationError` will hold the verification error, nil otherwise.
    public let verificationError: VerificationResult<T>.VerificationError?
}

// MARK: - SKHelperPurchaseState

/// The state of a purchase.
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperPurchaseState {
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

// MARK: - SKHelperSubscriptionState

/// The state of a subscription.
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperSubscriptionState {
    
    /// No activate subscription to this product has been found
    case notSubscribed
    
    /// The transaction for this subscription could not be verified
    case notVerified
    
    /// An activate subscription to this product has been found
    case subscribed
    
    /// The subscription to this product has been superceeded by a subscription to a higher value product in the same subscription group
    case superceeded
}

// MARK: - SKHelperEntitlementState

/// The state of an entitlement to a product.
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperEntitlementState {
    
    /// No transaction for the product has been found.
    case noEntitlement
    
    /// The transaction for this purchase could not be verified.
    case notVerified
    
    /// The user has a verified entitlement to access the product.
    case verifiedEntitlement
    
    /// Access to the purchase has been revoked by the App Store.
    case revoked
}

// MARK: - OnSubscriptionChange

/// The `OnSubscriptionChange` ViewModifier allows you to be notified of changes to the status of all subscriptions.
/// See also the `onSubscriptionChange(onChange:)` View extension.
public struct OnSubscriptionChange: ViewModifier {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Optional handler allows you to be notified of changes to the status of all subscriptions.
    private var onChange: SubscriptionStatusChangeClosure?
    
    /// Creates an `OnSubscriptionChange` ViewModifier.
    /// - Parameter onChange: Optional handler allows you to be notified of changes to the status of all subscriptions.
    public init(onChange: SubscriptionStatusChangeClosure? = nil) { self.onChange = onChange }
    
    /// Builds the body of the `OnSubscriptionChange` view modifier.
    /// - Parameter content: The View's content.
    /// - Returns: Returns the body of the `OnSubscriptionChange` view modifier.
    public func body(content: Content) -> some View {
        content
            .onAppear {
                store.subscriptionStatusChange = { productId, transactionId, renewalState, hasExpired in
                    let newState = renewalState.localizedDescription.lowercased(with: Locale.current)
                    print("Subscription \(productId) now \"\(newState)\" with transaction id \(transactionId). The subscription has \(hasExpired ? "expired" : "not expired").")
                    
                    onChange?(productId, transactionId, renewalState, hasExpired)
                }
            }
    }
}

// MARK: - onSubscriptionChange(onChange:) View extension

public extension View {
    
    /// View extension to provide a `onSubscriptionChange(onChange:)` modifier.
    /// ```
    /// // Example usage:
    /// SKHelperSubscriptionStoreView()
    ///     .onSubscriptionChange() { productId, transactionId, renewalState, hasExpired  in
    ///         print("The status of subscription \(productId) changed to \(renewalState.localizedDescription)")
    ///     }
    /// ```
    public func onSubscriptionChange(onChange: SubscriptionStatusChangeClosure? = nil) -> some View {
        modifier(OnSubscriptionChange(onChange: onChange))
    }
}
