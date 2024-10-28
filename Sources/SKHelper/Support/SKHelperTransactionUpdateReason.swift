//
//  SKHelperTransactionUpdateReason.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

/// Reasons that a transaction update is broadcast. See the ``OnTransaction`` view modifier.
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperTransactionUpdateReason: Equatable {
    /// The transaction was successfully completed.
    case success

    /// Theh transaction failed and the product was not purchased.
    case failure

    /// The user cancelled the transaction.
    case cancelled

    /// The App Store revoked the user's access to the product, normally because of a refund.
    case revoked

    /// The transaction was upgraded to a higher value product.
    case upgraded

    /// The transaction is awaiting approval, normally from a parent or guardian.
    case pending
    
    /// A short description of the notification.
    ///
    /// - Returns: Returns a short description of the notification.
    ///
    public func shortDescription() -> String {
        switch self {
            case .success:   return "Transaction success. The product was successfully purchased."
            case .failure:   return "Transaction failed. The product was not purchased."
            case .cancelled: return "Transaction cancelled by the user."
            case .revoked:   return "Transaction revoked by the App Store."
            case .upgraded:  return "Transaction was upgraded."
            case .pending:   return "Transaction is pending approval."
        }
    }
}
