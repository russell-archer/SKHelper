//
//  SKHelperPurchaseState.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

import Foundation

/// The state of a purchase.
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperPurchaseState: Sendable {
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
    
    /// This type of product is not supported.
    case unsupportedProduct
    
    /// Access to the purchase has been revoked by the App Store.
    case revoked
    
    /// The purchase has been upgraded.
    case upgraded
    
    /// The purchase has been downgraded.
    case downgraded
    
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
            case .unsupportedProduct:       return "Transaction is not supported for this type of product"
            case .revoked:                  return "Access to purchase has been revoked by the App Store"
            case .upgraded:                 return "Purchase has been upgraded"
            case .downgraded:               return "Purchase has been downgraded"
        }
    }
}
