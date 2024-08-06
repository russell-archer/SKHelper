//
//  SKHelperProduct.swift
//  StoreKitViewsDemo
//
//  Created by Russell Archer on 17/07/2024.

public import StoreKit

/// `SKHelperProduct` holds localized product information, along with a cached value for the user's entitlement to use the product.
@MainActor
@available(iOS 16.4, macOS 14.6, *)
public class SKHelperProduct: Identifiable {
    
    /// The unique `ProductId` for the `Product`
    public let id: ProductId
    
    /// Localized product information retrieved from the App Store.
    public let product: Product
    
    /// The subscription group (groupDisplayName) of the product, or an empty String if this is not a subscription
    public let group: String
    
    /// The group level of the subscription, or Int.max if this is not a subscription
    public let groupLevel: Int
    
    /// Does the user have an entitlement to use this product?
    public var hasEntitlement: Bool
    
    /// Creates a StoreProduct.
    /// - Parameters:
    ///   - product: A `Product` available from the App Store.
    ///   - hasEntitlement: True if the user has an entitlement to use this product.
    public init(product: Product, hasEntitlement: Bool = false) {
        self.id = product.id
        self.product = product
        self.hasEntitlement = hasEntitlement
        self.group = product.subscription?.groupDisplayName ?? ""
        self.groupLevel = product.subscription?.groupLevel ?? Int.max
    }
}
