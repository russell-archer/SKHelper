//
//  SKHelperConstants.swift
//  SKHelper
//
//  Created by Russell Archer on 31/07/2024.
//

import Foundation

/// Keys for each of the `SKHelperConstants`. If you create your own custom configuration property list file you should use these keys.
public enum SKHelperConstantKey: String {
    case storeConfiguration             = "storeConfiguration"
    case purchasedProductsKey           = "purchasedProductsKey"
    case productsConfiguration          = "productsConfiguration"
    case subscriptionsConfiguration     = "subscriptionsConfiguration"
    case subscriptionGroupConfiguration = "subscriptionGroupConfiguration"
    case requestRefundUrl               = "requestRefundUrl"
    case contactUsUrl                   = "contactUsUrl"
}

/// Constants used in support of App Store operations.
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperConstants: Sendable {
    
    /// Returns the name of the .plist configuration file that holds a list of `ProductId`.
    public static let StoreConfiguration = "Products"
    
    /// The UserDefaults key used to store the cached list of purchased products.
    /// Note that you should not attempt to override the value of this constant in a custom configuration.
    public static let PurchasedProductsKey = "PurchasedProducts"
    
    /// The name of the section of the Products.plist file that contains product ids
    public static let ProductsConfiguration = "Products"

    /// The name of the optional section of the Products.plist file that contains subscription product ids
    public static let SubscriptionsConfiguration = "Subscriptions"
    
    /// The name of the optional section of the Products.plist file that contains a subscription group
    public static let SubscriptionGroupConfiguration = "Group"
    
    /// A URL which users on macOS can use to request a refund for an IAP.
    public static let RequestRefundUrl = "https://reportaproblem.apple.com/"
    
    // A URL which can be used to contact the app's developers.
    public static let ContactUsUrl = "https://reportaproblem.apple.com/"
    
    /// Get the value of a constant by using a key.
    /// - Parameter key: The key of the required value.
    /// - Returns: Returns the value of a constant by using a key, or nil if the value cannot be found.
    ///
    public static func value(for key: SKHelperConstantKey) -> String? {
        switch key {
            case .storeConfiguration:               return SKHelperConstants.StoreConfiguration
            case .purchasedProductsKey:             return SKHelperConstants.PurchasedProductsKey
            case .productsConfiguration:            return SKHelperConstants.ProductsConfiguration
            case .subscriptionsConfiguration:       return SKHelperConstants.SubscriptionsConfiguration
            case .subscriptionGroupConfiguration:   return SKHelperConstants.SubscriptionGroupConfiguration
            case .requestRefundUrl:                 return SKHelperConstants.RequestRefundUrl
            case .contactUsUrl:                     return SKHelperConstants.ContactUsUrl
        }
    }
}
