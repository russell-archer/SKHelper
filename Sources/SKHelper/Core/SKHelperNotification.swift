//
//  SKHelperNotification.swift
//  SKHelper
//
//  Created by Russell Archer on 14/07/2024.
//

internal import StoreKit

/// Informational logging notifications issued by SKHelper
@available(iOS 17.0, macOS 14.6, *)
public enum SKHelperNotification: Error, Equatable {
    
    /// The product configuration property file could not be found. Have you included it in the traget membership of your app?
    case configurationNotFound
    
    /// The product configuration property file does not contain any product definitions. Review the sample Products.plist file for an example.
    case configurationEmpty
    
    /// The product configuration property file was successfully read and valid product definitions extracted.
    case configurationSuccess
    
    /// The product configuration property file was not successfully read. Valid product definitions were not extracted.
    case configurationFailure
    
    /// The user cannot make App Store payments.
    case purchaseUserCannotMakePayments
    
    /// A purhcase is already in progress, so you can't start another one.
    case purchaseAlreadyInProgress
    
    /// A purchase process has started normally.
    case purchaseInProgress
    
    /// The user cancelled a purchase before it could complete.
    case purchaseCancelled
    
    /// A purchase is pending approval (e.g. from a parent).
    case purchasePending
    
    /// The most recent purchase was a success.
    case purchaseSuccess
    
    /// The most recent purchase failed.
    case purchaseFailure
    
    /// A transaction update has been received and will be processed.
    case transactionReceived
    
    /// The transaction was successfully validated.
    case transactionValidationSuccess
    
    /// The transaction could not be validated. The user is not entitled to have access to the product.
    case transactionValidationFailure
    
    /// The transaction could not be validated. However, the user is temporarily entitled to have access to the product.
    case transactionValidationFailureWarning
    
    /// The transaction failed.
    case transactionFailure
    
    /// The transaction was a success.
    case transactionSuccess
    
    /// The transaction related to a subscription was a success.
    case transactionSubscribed
    
    /// The transaction related to a subscription was revoked by the App Store.
    case transactionRevoked
    
    /// The transaction has had a refund request submitted to the App Store.
    case transactionRefundRequested
    
    /// The transaction has had a refund request to the App Store fail.
    case transactionRefundFailed
    
    /// The transaction related to a subscription has expired.
    case transactionExpired
    
    /// The transaction related to a subscription has been upgraded to a higher-value subscription in the same subscription group.
    case transactionUpgraded
    
    /// The transaction related to a subscription is currently in the payment grace period.
    case transactionInGracePeriod
    
    /// The transaction related to a subscription is currently in the payment retry period.
    case transactionInBillingRetryPeriod
    
    /// The transaction was processed and marked as finished.
    case transactionFinished
    
    /// The products has been purchased.
    case productIsPurchased
    
    /// The product has not been purchased.
    case productIsNotPurchased
    
    /// We have requested a collection of localized product information from the App Store.
    case requestProductsStart
    
    /// The request for localized product information from the App Store has failed.
    case requestProductsFailure
    
    /// The request for localized product information from the App Store has suceeded.
    case requestProductsSuccess
    
    /// A purchase intent (a direct App Store purchase of a product) has been received from the App Store.
    case purchaseIntentRecieved
    
    /// The status of a subscription has changed.
    case subscriptionStausChanged
    
    /// `SKHelper` supports consumable and non-consumable products and auto-renewable subscriptions. Non-renewable subscriptions are not supported.
    case nonRenewableSubscriptionsNotSupported
    
    /// The wrong product type was provided.
    case wrongProductType
    
    /// A short description of the notification.
    ///
    /// - Returns: Returns a short description of the notification.
    ///
    public func shortDescription() -> String {
        switch self {
            case .configurationNotFound:                    return "Configuration file not found in the main bundle"
            case .configurationEmpty:                       return "Configuration file does not contain any product definitions"
            case .configurationSuccess:                     return "Configuration success"
            case .configurationFailure:                     return "Configuration failure"
            case .purchaseUserCannotMakePayments:           return "Purchase failed because the user cannot make payments"
            case .purchaseAlreadyInProgress:                return "Purchase already in progress"
            case .purchaseInProgress:                       return "Purchase in progress"
            case .purchasePending:                          return "Purchase in progress. Awaiting authorization"
            case .purchaseCancelled:                        return "Purchase cancelled"
            case .purchaseSuccess:                          return "Purchase success"
            case .purchaseFailure:                          return "Purchase failure"
            case .transactionReceived:                      return "Transaction received"
            case .transactionValidationSuccess:             return "Transaction validation success"
            case .transactionValidationFailure:             return "Transaction validation failure"
            case .transactionValidationFailureWarning:      return "Transaction validation failed when checking entitlement (warning)"
            case .transactionFailure:                       return "Transaction failure"
            case .transactionSuccess:                       return "Transaction success"
            case .transactionSubscribed:                    return "Transaction for subscription was a success"
            case .transactionRevoked:                       return "Transaction was revoked (refunded) by the App Store"
            case .transactionRefundRequested:               return "Transaction refund successfully requested"
            case .transactionRefundFailed:                  return "Transaction refund request failed"
            case .transactionExpired:                       return "Transaction for subscription has expired"
            case .transactionUpgraded:                      return "Transaction superceeded by higher-value subscription"
            case .transactionInGracePeriod:                 return "Subscription is in a billing grace period"
            case .transactionInBillingRetryPeriod:          return "Subscription is in a billing retry period"
            case .transactionFinished:                      return "Transaction finished"
            case .productIsPurchased:                       return "Product purchased"
            case .productIsNotPurchased:                    return "Product not purchased"
            case .requestProductsStart:                     return "Starting request for localized product information from the App Store"
            case .requestProductsFailure:                   return "Localized product information could not be retrieved from the App Store"
            case .requestProductsSuccess:                   return "Localized product information successfully retrieved from the App Store"
            case .purchaseIntentRecieved:                   return "Purchase intent received"
            case .subscriptionStausChanged:                 return "Subscription status changed"
            case .nonRenewableSubscriptionsNotSupported:    return "Non-renewable subscriptions are not supported"
            case .wrongProductType:                         return "Wrong product type"
        }
    }
}
