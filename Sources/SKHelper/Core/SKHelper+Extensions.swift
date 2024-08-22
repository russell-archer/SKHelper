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
    // MARK: - Public product helpers
    
    var allProducts:                  [SKProduct] { products }
    var allConsumableProducts:        [SKProduct] { products.filter { $0.product.type == .consumable }}
    var allNonConsumableProducts:     [SKProduct] { products.filter { $0.product.type == .nonConsumable }}
    var allSubscriptionProducts:      [SKProduct] { products.filter { $0.product.type == .autoRenewable }}
    var allNonSubscriptionProducts:   [SKProduct] { products.filter { $0.product.type == .nonRenewable }}
    var allPurchasedProducts:         [SKProduct] { products.filter { $0.hasEntitlement }}

    var allProductIds:                [ProductId] { products.map    { $0.id }}
    var allConsumableProductIds:      [ProductId] { products.filter { $0.product.type == .consumable }.map { $0.id }}
    var allNonConsumableProductIds:   [ProductId] { products.filter { $0.product.type == .nonConsumable }.map { $0.id }}
    var allSubscriptionProductIds:    [ProductId] { products.filter { $0.product.type == .autoRenewable }.map { $0.id }}
    var allNonSubscriptionProductIds: [ProductId] { products.filter { $0.product.type == .nonRenewable }.map { $0.id }}
    var allPurchasedProductIds:       [ProductId] { products.filter { $0.hasEntitlement }.map { $0.id }}
    
    var hasProducts:                  Bool { !products.isEmpty }
    var hasConsumableProducts:        Bool { !allConsumableProducts.isEmpty }
    var hasNonConsumableProducts:     Bool { !allNonConsumableProducts.isEmpty }
    var hasSubscriptionProducts:      Bool { !allSubscriptionProducts.isEmpty }
    var hasNonSubscriptionProducts:   Bool { !allNonSubscriptionProducts.isEmpty }
    var hasConsumableProductIds:      Bool { !allConsumableProductIds.isEmpty }
    var hasNonConsumableProductIds:   Bool { !allNonConsumableProductIds.isEmpty }
    var hasSubscriptionProductIds:    Bool { !allSubscriptionProductIds.isEmpty }
    var hasNonSubscriptionProductIds: Bool { !allNonSubscriptionProducts.isEmpty }
    
    func storeProduct(for productId: ProductId)              -> SKProduct?  { products.first(where: { $0.id == productId }) }
    func product(from productId: ProductId)                  -> Product?    { products.first(where: { $0.id == productId })?.product }
    func isAutoRenewable(productId: ProductId)               -> Bool        { allSubscriptionProductIds.contains(productId) }
    func isNonConsumable(productId: ProductId)               -> Bool        { allNonConsumableProductIds.contains(productId) }
    func isConsumable(productId: ProductId)                  -> Bool        { allConsumableProductIds.contains(productId) }
    func subscriptionGroup(for productId: ProductId)         -> String?     { products.first(where: { $0.id == productId })?.product.subscription?.groupDisplayName }
    func allSubscriptionGroups()                             -> [String]    { Array(Set(products.filter { $0.product.type == .autoRenewable }.map { $0.group }.filter { !$0.isEmpty })) }
    func allSubscriptionStoreProducts(for group: String)     -> [SKProduct] { products.filter { $0.product.type == .autoRenewable && $0.group == group }}
    func allSubscriptionProductIdsByLevel(for group: String) -> [ProductId] { allSubscriptionStoreProducts(for: group).sorted { $0.groupLevel < $1.groupLevel}.map { $0.id }}
    func allSubscriptionProducts(for group: String)          -> [Product]   { allSubscriptionStoreProducts(for: group).map { $0.product } }
}

// MARK: - SKUnwrappedVerificationResult

/// Information on the result of unwrapping a transaction `VerificationResult`.
@available(iOS 17.0, macOS 14.6, *)
public struct SKUnwrappedVerificationResult<T: Sendable> : Sendable{
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
    case notStarted, userCannotMakePayments, inProgress, purchased, pending, cancelled, failed, failedVerification, unknown, notPurchased, error, puchaseAlreadyInProgress
    
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
