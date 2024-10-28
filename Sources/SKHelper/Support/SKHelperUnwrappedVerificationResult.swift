//
//  SKHelperUnwrappedVerificationResult.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

import StoreKit

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
