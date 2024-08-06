//
//  SKHelperConfiguration.swift
//
//  Created by Russell Archer on 31/07/2024.
//

import Foundation

/// Provides methods for reading the contents of the product definition property list (e.g. `Products.plist`).
/// The structure of the product definition property list may take one of two alternative formats, as described below.
///
/// Format 1.
/// All in-app purchase products (consumable, non-consumable and subscription) are listed together under the top-level
/// "Products" key. When using this format all subscriptions must use the
/// `com.{author}.subscription.{subscription-group-name}.{product-name}` naming convention, so that subscription group
/// names can be determined. Other products do not need to adhere to a naming convention.
///
/// Format 2.
/// Consumable and non-consumable products are listed together under the top-level "Products" key.
/// Subscriptions are listed under the top-level "Subscriptions" key.
///
/// Example 1. Products listed together. Subscriptions must use the required naming convention:
///
/// ```
/// <?xml version="1.0" encoding="UTF-8"?>
/// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
/// <plist version="1.0">
/// <dict>
///     <key>Products</key>
///     <array>
///         <string>com.rarcher.nonconsumable.flowers.large</string>
///         <string>com.rarcher.nonconsumable.flowers.small</string>
///         <string>com.rarcher.consumable.plant.installation</string>
///         <string>com.rarcher.subscription.vip.gold</string>
///         <string>com.rarcher.subscription.vip.silver</string>
///         <string>com.rarcher.subscription.vip.bronze</string>
///     </array>
/// </dict>
/// </plist>
/// ```
///
/// Example 2. All consumables and non-consumables listed together. Subscriptions listed separately,
/// with two subscription groups named "vip" and "standard" defined:
///
/// ```
/// <?xml version="1.0" encoding="UTF-8"?>
/// <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
/// <plist version="1.0">
/// <dict>
///     <key>Products</key>
///     <array>
///         <string>com.rarcher.nonconsumable.flowers.large</string>
///         <string>com.rarcher.nonconsumable.flowers.small</string>
///         <string>com.rarcher.consumable.plant.installation</string>
///     </array>
///     <key>Subscriptions</key>
///     <array>
///         <dict>
///             <key>Group</key>
///             <string>vip</string>
///             <key>Products</key>
///             <array>
///                 <string>com.rarcher.gold</string>
///                 <string>com.rarcher.silver</string>
///                 <string>com.rarcher.bronze</string>
///             </array>
///         </dict>
///         <dict>
///             <key>Group</key>
///             <string>standard</string>
///             <key>Products</key>
///             <array>
///                 <string>com.rarcher.sub1</string>
///                 <string>com.rarcher.sub2</string>
///                 <string>com.rarcher.sub3</string>
///             </array>
///         </dict>
///     </array>
/// </dict>
/// </plist>
/// ```

@MainActor
@available(iOS 16.4, macOS 14.6, *)
public struct SKHelperConfiguration {
    
    private struct SubscriptionGroupInfo {
        let group: String
        let productIds: [ProductId]
        
        init(group: String, productIds: [ProductId]? = nil) {
            self.group = group
            self.productIds = productIds ?? [ProductId]()
        }
    }
    
    /// Read the contents of the product definition property list (e.g. `Products.plist`).
    /// - Returns: Returns an array of `ProductId` if the list was read, nil otherwise.
    /// - Parameter filename: The name of the file to read. If the parameter is not supplied
    /// the value of `SKHelperConstants.SKHelperConfiguration` is used instead.
    public static func readProductConfiguration(filename: String? = nil) -> [ProductId]? {
        guard let result = read(filename: filename == nil ? SKHelperConstants.StoreConfiguration : filename!) else {
            SKHelperLog.event(.configurationNotFound)
            SKHelperLog.event(.configurationFailure)
            return nil
        }
        
        guard result.count > 0 else {
            SKHelperLog.event(.configurationEmpty)
            SKHelperLog.event(.configurationFailure)
            return nil
        }
        
        // Read the "Products" list. This can contain consumable, non-consumable and subscription products
        guard var values = result[SKHelperConstants.ProductsConfiguration] as? [String] else {
            SKHelperLog.event(.configurationEmpty)
            SKHelperLog.event(.configurationFailure)
            return nil
        }
        
        // Do we have an optional "Subscriptions" list?
        values = [ProductId](values.compactMap { $0 })
        guard let subscriptions = result[SKHelperConstants.SubscriptionsConfiguration] as? [[String : AnyObject]] else { return values }
        for subscriptionGroup in subscriptions {
            guard subscriptionGroup[SKHelperConstants.SubscriptionGroupConfiguration] is String else { continue }
            guard let subscriptionsInGroup = subscriptionGroup[SKHelperConstants.ProductsConfiguration] as? [String] else { continue }
            for subscription in subscriptionsInGroup { values.append(subscription) }
        }
        
        SKHelperLog.event(.configurationSuccess)
        return values
    }
    
    /// Read a plist property file and return a dictionary of values.
    /// - Parameter filename: The name of the file to read.
    /// - Returns: A set of [String : AnyObject], or nil if the file couldn't be read.
    private static func read(filename: String) -> [String : AnyObject]? {
        guard let path = Bundle.main.path(forResource: filename, ofType: "plist"),
              let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject]  else { return nil }
        
        return contents
    }
}


