//
//  SKHelperSubscriptionState.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

import Foundation

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
