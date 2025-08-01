//
//  SKHelperConfiguration.swift
//  SKHelper
//
//  Created by Russell Archer on 31/07/2024.
//

import Foundation

/// `SKHelperConfiguration` is used to read the contents of the product definition property list (e.g. `Products.plist`).
/// It also handles the reading of custom configuration property list files and get individual values by key.
///
/// ## Example of reading a custom configuration value ##
///
/// ```
/// color = SKHelperConfiguration.value(
///     for: "color",
///     in: "Config") ?? "Unknown"
/// ```
///
/// # Notes on The product definition file #
/// The structure of the product definition property file may take one of two alternative formats, as described below.
///
/// ## Format 1 ##
/// All in-app purchase products (consumable, non-consumable and subscription) are listed together under the top-level
/// "Products" key. When using this format all subscriptions must use the
/// `com.{author}.subscription.{subscription-group-name}.{product-name}` naming convention, so that subscription group
/// names can be determined. Other products do not need to adhere to a naming convention.
///
/// ## Format 2 ##
/// Consumable and non-consumable products are listed together under the top-level "Products" key.
/// Subscriptions are listed under the top-level "Subscriptions" key.
///
/// ## Example 1 ##
/// Products listed together. Subscriptions must use the required naming convention:
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
/// ## Example 2 ##
/// All consumables and non-consumables listed together. Subscriptions listed separately,
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
///
@MainActor
@available(iOS 17.0, macOS 14.6, *)
public class SKHelperConfiguration {
    
    /// The dictionary of values read from the property list file.
    private static var customConfigDictionary: [String : AnyObject] = [:]
    
    /// The file most recently read. Allows for caching of dictionary values.
    private static var mruCustomConfigFile = ""
    
    /// Read the contents of the product definition property list (e.g. `Products.plist`).
    ///
    /// - Returns: Returns an array of `ProductId` if the list was read, nil otherwise.
    /// - Parameter filename: The name of the file to read. If the parameter is not supplied the value of `SKHelperConstants.StoreConfiguration` is used instead.
    ///
    public static func readProductConfiguration(filename: String? = nil) -> [ProductId]? {
        let result = read(filename: filename == nil ? SKHelperConstants.StoreConfiguration : filename!)
        guard !result.isEmpty else {
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
        var values = [String]()
        if let products = result[SKHelperConstants.ProductsConfiguration] as? [String] {
            values = [ProductId](products.compactMap { $0 })
        }
        
        // Do we have an optional "Subscriptions" list?
        guard let subscriptions = result[SKHelperConstants.SubscriptionsConfiguration] as? [[String : AnyObject]] else {
            return values.isEmpty ? nil : values
        }
        
        for subscriptionGroup in subscriptions {
            guard subscriptionGroup[SKHelperConstants.SubscriptionGroupConfiguration] is String else { continue }
            guard let subscriptionsInGroup = subscriptionGroup[SKHelperConstants.ProductsConfiguration] as? [String] else { continue }
            for subscription in subscriptionsInGroup { values.append(subscription) }
        }
        
        if values.isEmpty {
            SKHelperLog.event(.configurationEmpty)
            SKHelperLog.event(.configurationFailure)
            return nil
        } else {
            SKHelperLog.event(.configurationSuccess)
            return values
        }
    }
    
    /// Read a property from a dictionary of custom configuration values.
    /// - Parameters:
    ///   - key: The value's key.
    ///   - file: The property list file to read values from.
    /// - Returns: Returns a property from a dictionary of values that is read from a .plist file.
    /// 
    public static func value(for key: String, in file: String) -> String? {
        if customConfigDictionary.isEmpty || mruCustomConfigFile != file { customConfigDictionary = read(filename: file) }
        if let val = customConfigDictionary[key] as? String { return val }
        return nil
    }
    
    /// Read a plist property file and return a dictionary of values.
    ///
    /// - Parameter filename: The name of the file to read.
    /// - Returns: A set of [String : AnyObject], or nil if the file couldn't be read.
    ///
    private static func read(filename: String) -> [String : AnyObject] {
        mruCustomConfigFile = filename
        guard let path = Bundle.main.path(forResource: filename, ofType: "plist"),
              let contents = NSDictionary(contentsOfFile: path) as? [String : AnyObject]  else { return [:] }
        
        return contents
    }
}
