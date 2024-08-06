//
//  SKHelper+Extensions.swift
//
//  Created by Russell Archer on 04/08/2024.
//

public import StoreKit

public typealias ProductId = String

@available(iOS 14.4, macOS 16.4, *)
public extension SKHelper {
    // MARK: - Public product helpers
    
    var allConsumableProducts:           [SKHelperProduct]      { products.filter { $0.product.type == .consumable }}
    var allNonConsumableProducts:        [SKHelperProduct]      { products.filter { $0.product.type == .nonConsumable }}
    var allSubscriptionProducts:         [SKHelperProduct]      { products.filter { $0.product.type == .autoRenewable }}
    var allNonSubscriptionProducts:      [SKHelperProduct]      { products.filter { $0.product.type == .nonRenewable }}

    var allProductIds:                   [ProductId]         { products.map    { $0.id }}
    var allConsumableProductIds:         [ProductId]         { products.filter { $0.product.type == .consumable }.map { $0.id }}
    var allNonConsumableProductIds:      [ProductId]         { products.filter { $0.product.type == .nonConsumable }.map { $0.id }}
    var allSubscriptionProductIds:       [ProductId]         { products.filter { $0.product.type == .autoRenewable }.map { $0.id }}
    var allNonSubscriptionProductIds:    [ProductId]         { products.filter { $0.product.type == .nonRenewable }.map { $0.id }}

    var hasProducts:                     Bool                { products.count > 0 ? true : false }
    var hasConsumableProducts:           Bool                { allConsumableProducts.count > 0 ? true : false }
    var hasNonConsumableProducts:        Bool                { allNonConsumableProducts.count > 0 ? true : false }
    var hasSubscriptionProducts:         Bool                { allSubscriptionProducts.count > 0 ? true : false }
    var hasNonSubscriptionProducts:      Bool                { allNonSubscriptionProducts.count > 0 ? true : false }
    var hasConsumableProductIds:         Bool                { allConsumableProductIds.count > 0 ? true : false }
    var hasNonConsumableProductIds:      Bool                { allNonConsumableProductIds.count > 0 ? true : false }
    var hasSubscriptionProductIds:       Bool                { allSubscriptionProductIds.count > 0 ? true : false }
    var hasNonSubscriptionProductIds:    Bool                { allNonSubscriptionProducts.count > 0 ? true : false }
    
    func storeProduct(for productId: ProductId)              -> SKHelperProduct?   { products.first(where: { $0.id == productId }) }
    func product(from productId: ProductId)                  -> Product?        { products.first(where: { $0.id == productId })?.product }
    func isAutoRenewable(productId: ProductId)               -> Bool            { allSubscriptionProductIds.contains(productId) }
    func isNonConsumable(productId: ProductId)               -> Bool            { allNonConsumableProductIds.contains(productId) }
    func isConsumable(productId: ProductId)                  -> Bool            { allConsumableProductIds.contains(productId) }
    func subscriptionGroup(for productId: ProductId)         -> String?         { products.first(where: { $0.id == productId })?.product.subscription?.groupDisplayName }
    func allSubscriptionGroups()                             -> [String]        { Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.group }.filter { !$0.isEmpty })) }
    func allSubscriptionStoreProducts(for group: String)     -> [SKHelperProduct]  { products.filter { $0.product.type == .autoRenewable && $0.group == group }}
    func allSubscriptionProductIdsByLevel(for group: String) -> [ProductId]     { allSubscriptionStoreProducts(for: group).sorted { $0.groupLevel < $1.groupLevel}.map { $0.id }}
    func allSubscriptionProducts(for group: String)          -> [Product]       { allSubscriptionStoreProducts(for: group).map { $0.product } }
}

// MARK: - UnwrappedVerificationResult

/// Information on the result of unwrapping a transaction `VerificationResult`.
@available(iOS 14.4, macOS 16.4, *)
public struct UnwrappedVerificationResult<T: Sendable> : Sendable{
    /// The verified or unverified transaction.
    public let transaction: T
    
    /// True if the transaction was successfully verified by StoreKit.
    public let verified: Bool
    
    /// If `verified` is false then `verificationError` will hold the verification error, nil otherwise.
    public let verificationError: VerificationResult<T>.VerificationError?
}

// MARK: - PurchaseState

/// The state of a purchase.
@available(iOS 14.4, macOS 16.4, *)
public enum PurchaseState {
    case notStarted, userCannotMakePayments, inProgress, purchased, pending, cancelled, failed, failedVerification, unknown, notPurchased
    
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
        }
    }
}
