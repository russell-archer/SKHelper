//
//  SKHelperProduct.swift
//  SKHelper
//
//  Created by Russell Archer on 17/07/2024.

public import StoreKit

/// `SKHelperProduct` holds localized product information, along with a cached value for the user's entitlement to use the product.
@MainActor
@available(iOS 17.0, macOS 14.6, *)
public class SKHelperProduct: Identifiable, Equatable {
    
    /// The unique `ProductId` for the `Product`.
    public let id: ProductId
    
    /// Localized `Product` information retrieved from the App Store.
    public let product: Product
    
    /// The subscription group (`groupDisplayName`) of the product, or nil if this is not a subscription.
    public let groupName: String?
    
    /// The subscription group id (`subscriptionGroupID`) of the product, or nil if this is not a subscription.
    public let groupId: String?
    
    /// The group level of the subscription, or Int.max if this is not a subscription. Subscriptions with a lower group level indicate a higher level of service.
    /// For example, if someone subscribes to a subscription with a group level lower than their current subscription, this would be an upgrade.
    public let groupLevel: Int
        
    /// The sort order for this product when shown in a list with other types of product.
    public let sortOrder: Int
    
    /// A cached entitlement to use the product.
    public var hasEntitlement: Bool
    
    /// Creates an `SKHelperProduct`.
    ///
    /// - Parameters:
    ///   - product: A `Product` available from the App Store.
    ///   - hasEntitlement: True if the user has an entitlement to use this product.
    ///   
    public init(product: Product, hasEntitlement: Bool = false) {
        self.id = product.id
        self.product = product
        self.hasEntitlement = hasEntitlement
        self.groupName = product.subscription?.groupDisplayName
        self.groupId = product.subscription?.subscriptionGroupID
        self.groupLevel = product.subscription?.groupLevel ?? Int.max
        
        switch product.type {
            case .nonConsumable: self.sortOrder = 0
            case .consumable:    self.sortOrder = 1
            case .autoRenewable: self.sortOrder = 2
            default :            self.sortOrder = 3
        }
    }
    
    nonisolated public static func == (lhs: SKHelperProduct, rhs: SKHelperProduct) -> Bool { lhs.id == rhs.id }
}
