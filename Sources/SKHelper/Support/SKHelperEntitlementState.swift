//
//  SKHelperEntitlementState.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

import Foundation

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
