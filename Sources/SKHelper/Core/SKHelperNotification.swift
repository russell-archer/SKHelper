//
//  SKHelperNotification.swift
//  StoreKitViewsDemo
//
//  Created by Russell Archer on 14/07/2024.
//

public import StoreKit

/// Informational logging notifications issued by StoreHelper
@available(iOS 16.4, macOS 14.6, *)
public enum SKHelperNotification: Error, Equatable {
    case configurationNotFound
    case configurationEmpty
    case configurationSuccess
    case configurationFailure
    case purchaseUserCannotMakePayments
    case purchaseAlreadyInProgress
    case purchaseInProgress
    case purchaseCancelled
    case purchasePending
    case purchaseSuccess
    case purchaseFailure
    case transactionReceived
    case transactionValidationSuccess
    case transactionValidationFailure
    case transactionValidationFailureWarning
    case transactionFailure
    case transactionSuccess
    case transactionSubscribed
    case transactionRevoked
    case transactionRefundRequested
    case transactionRefundFailed
    case transactionExpired
    case transactionUpgraded
    case transactionInGracePeriod
    case transactionInBillingRetryPeriod
    case transactionFinished
    case productIsPurchased
    case productIsNotPurchased
    case requestProductsStart
    case requestProductsFailure
    case requestProductsSuccess
    case purchaseIntentRecieved
    case subscriptionStausChanged
    
    
    /// A short description of the notification.
    /// - Returns: Returns a short description of the notification.
    public func shortDescription() -> String {
        switch self {
            case .configurationNotFound:                return "Configuration file not found in the main bundle"
            case .configurationEmpty:                   return "Configuration file does not contain any product definitions"
            case .configurationSuccess:                 return "Configuration success"
            case .configurationFailure:                 return "Configuration failure"
            case .purchaseUserCannotMakePayments:       return "Purchase failed because the user cannot make payments"
            case .purchaseAlreadyInProgress:            return "Purchase already in progress"
            case .purchaseInProgress:                   return "Purchase in progress"
            case .purchasePending:                      return "Purchase in progress. Awaiting authorization"
            case .purchaseCancelled:                    return "Purchase cancelled"
            case .purchaseSuccess:                      return "Purchase success"
            case .purchaseFailure:                      return "Purchase failure"
            case .transactionReceived:                  return "Transaction received"
            case .transactionValidationSuccess:         return "Transaction validation success"
            case .transactionValidationFailure:         return "Transaction validation failure"
            case .transactionValidationFailureWarning:  return "Transaction validation failed when checking entitlement (warning)"
            case .transactionFailure:                   return "Transaction failure"
            case .transactionSuccess:                   return "Transaction success"
            case .transactionSubscribed:                return "Transaction for subscription was a success"
            case .transactionRevoked:                   return "Transaction was revoked (refunded) by the App Store"
            case .transactionRefundRequested:           return "Transaction refund successfully requested"
            case .transactionRefundFailed:              return "Transaction refund request failed"
            case .transactionExpired:                   return "Transaction for subscription has expired"
            case .transactionUpgraded:                  return "Transaction superceeded by higher-value subscription"
            case .transactionInGracePeriod:             return "Subscription is in a billing grace period"
            case .transactionInBillingRetryPeriod:      return "Subscription is in a billing retry period"
            case .transactionFinished:                  return "Transaction finished"
            case .productIsPurchased:                   return "Product purchased"
            case .productIsNotPurchased:                return "Product not purchased"
            case .requestProductsStart:                 return "Starting request for localized product information from the App Store"
            case .requestProductsFailure:               return "Localized product information could not be retrieved from the App Store"
            case .requestProductsSuccess:               return "Localized product information successfully retrieved from the App Store"
            case .purchaseIntentRecieved:               return "Purchase intent received"
            case .subscriptionStausChanged:             return "Subscription status changed"
        }
    }
}

/// SKHelper exceptions
@available(iOS 16.4, macOS 14.6, *)
public enum StoreException: Error, Equatable {
    case purchaseException(UnderlyingError?)
    case purchaseInProgressException
    case transactionVerificationFailed
    case productTypeNotSupported
    case productNotFound

    public func shortDescription() -> String {
        switch self {
        case .purchaseException:                return "Exception. StoreKit threw an exception while processing a purchase"
        case .purchaseInProgressException:      return "Exception. You can't start another purchase yet, one is already in progress"
        case .transactionVerificationFailed:    return "Exception. A transaction failed StoreKit's automatic verification"
        case .productTypeNotSupported:          return "Exception. Products of type nonRenewable are not supported"
        case .productNotFound:                  return "Exception. The product cannot be found. See StoreProduct.products."
        }
    }
}

@available(iOS 16.4, macOS 14.6, *)
extension StoreKitError: @retroactive Equatable {
    public static func == (lhs: StoreKitError, rhs: StoreKitError) -> Bool {
        switch (lhs, rhs) {
        case (.unknown, .unknown):                                      return true
        case (.userCancelled, .userCancelled):                          return true
        case (.networkError, .networkError):                            return true
        case (.systemError, .systemError):                              return true
        case (.notAvailableInStorefront, .notAvailableInStorefront):    return true
        case (.notEntitled, .notEntitled):                              return true
        default:                                                        return false
        }
    }
}

@available(iOS 16.4, macOS 14.6, *)
public enum UnderlyingError: Equatable, Sendable {
    case purchase(Product.PurchaseError)
    case storeKit(StoreKitError)

    public init?(error: any Error) {
        if let purchaseError = error as? Product.PurchaseError { self = .purchase(purchaseError) }
        else if let skError = error as? StoreKitError { self = .storeKit(skError) }
        else { return nil }
    }
}
