//
//  SKHelperPurchaseInfo.swift
//  SKHelper
//
//  Created by Russell Archer on 12/08/2024.
//

import StoreKit

/// Information related to the purchase of a non-consumable product.
@MainActor
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperPurchaseInfo: Hashable {
    
    /// The product's unique id
    public var id: ProductId
    
    /// The product's display name
    public var name: String
    
    /// true if the product has been purchased
    public var isPurchased: Bool
    
    /// Consumable, non-consumable, subscription, etc.
    public var productType: Product.ProductType
    
    /// The transactionid for the purchase. UInt64.min if not purchased
    public var transactionId: UInt64?
    
    /// Localized price paid when purchased
    public var purchasePrice: String?
    
    /// Date of purchase
    public var purchaseDate: Date?
    
    /// Date of purchase formatted as "d MMM y" (e.g. "28 Dec 2021")
    public var purchaseDateFormatted: String?
    
    /// Date the app revoked the purchase (e.g. because of a refund, etc.)
    public var revocationDate: Date?
    
    /// Date of revocation formatted as "d MMM y"
    public var revocationDateFormatted: String?
    
    /// Why the purchase was revoked (.developerIssue or .other)
    public var revocationReason: StoreKit.Transaction.RevocationReason?
    
    /// Either .purchased or .familyShared
    public var ownershipType: StoreKit.Transaction.OwnershipType?
}

