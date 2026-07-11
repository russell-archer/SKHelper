//
//  SKHelperLog.swift
//  SKHelper
//
//  Created by Russell Archer on 14/07/2024.
//

import Foundation
import os.log

/// We use Apple's unified logging system to log errors, notifications and general messages.
/// This system works on simulators and real devices for both debug and release builds.
/// You can view the logs in the Console app by selecting the test device in the left console pane.
/// If running on the simulator, select the machine the simulator is running on. Type your app's
/// bundle identifier into the search field and then narrow the results by selecting "SUBSYSTEM"
/// from the search field's filter. Logs also appear in Xcode's console in the same manner as
/// print statements.
///
/// When running the app on a real device that's not attached to the Xcode debugger,
/// dynamic strings (i.e. the error, event or message parameter you send to the event() function)
/// will not be publicly viewable. They're automatically redacted with the word "private" in the
/// console. This prevents the accidental logging of potentially sensistive user data. Because
/// we know in advance that StoreNotificaton enums do NOT contain sensitive information, we let the
/// unified logging system know it's OK to log these strings through the use of the "%{public}s"
/// keyword. However, we don't know what the event(message:) function will be used to display,
/// so its logs will be redacted.
///
@available(iOS 17.0, macOS 14.6, *)
public struct SKHelperLog {
    private static let skhelperLog = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "STORE")
    
    /// Logs a StoreNotification. Note that the text (shortDescription) of the log entry will be publically available in the Console app.
    ///
    /// - Parameter event: A SKHelperNotification.
    ///
    public static func event(_ event: SKHelperNotification) { logEvent(event) }
    
    /// Logs an SKHelperNotification. Note that the text (shortDescription) and the productId for the log entry will be publically available in the Console app.
    /// 
    /// - Parameters:
    ///   - event:      A SKHelperNotification.
    ///   - productId:  A ProductId associated with the event.
    ///   - transactionId: The id of the transaction.
    ///
    public static func event(_ event: SKHelperNotification, productId: ProductId, transactionId: String? = nil) {
        logEvent(event, productId: productId, transactionId: transactionId)
    }
    
    /// Logs an SKHelperNotification. Note that the text (shortDescription) and the productId for the log entry will be publically available in the Console app.
    /// 
    /// - Parameters:
    ///   - event:      A SKHelperNotification.
    ///   - productId:  A ProductId associated with the event.
    ///   - webOrderLineItemId: A unique ID that identifies subscription purchase events across devices, including subscription renewals.
    ///   - transactionId: The id of the transaction.
    ///
    public static func event(_ event: SKHelperNotification, productId: ProductId, webOrderLineItemId: String?, transactionId: String? = nil) {
        logEvent(event, productId: productId, webOrderLineItemId: webOrderLineItemId, transactionId: transactionId)
    }
    
    /// Logs a SKHelperNotification as a transaction. Note that the text (shortDescription) and the productId for the log entry will be publically available in the Console app.
    /// 
    /// - Parameters:
    ///   - event:      A SKHelperNotification.
    ///   - productId:  A ProductId associated with the event.
    ///   - transactionId: The id of the transaction.
    ///
    public static func transaction(_ event: SKHelperNotification, productId: ProductId, transactionId: String? = nil) {
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId) \(transactionId == nil ? "" : "with transaction id \(transactionId!)")")
        #else
        os_log("%{public}s for product %{public}s", log: skhelperLog, type: .default, event.shortDescription(), productId)
        #endif
    }
    
    /// Logs a SKHelperNotification as a transaction. Note that the text (shortDescription) and the productId for the log entry will be publically available in the Console app.
    ///  
    /// - Parameters:
    ///   - productId:  A ProductId associated with the event.
    ///   - transactionId: The id of the transaction.
    ///   - newSubscriptionStatus: The description of the new subscription status.
    /// 
    public static func subscriptionChanged(productId: ProductId, transactionId: String? = nil, newSubscriptionStatus: String) {
        #if DEBUG
        print("\(SKHelperNotification.subscriptionStausChanged.shortDescription()) for product \(productId) \(transactionId == nil ? "" : "with transaction id \(transactionId!)") to \(newSubscriptionStatus)")
        #else
        os_log("%{public}s for product %{public}s", log: skhelperLog, type: .default, SKHelperNotification.subscriptionStausChanged.shortDescription(), productId)
        #endif
    }
    
    /// Logs a message of type `String`.
    ///
    /// - Parameter message: The message to log.
    ///
    public static func event(_ message: String) {
        #if DEBUG
        print(message)
        #else
        os_log("%s", log: skhelperLog, type: .info, message)
        #endif
    }
    
    /// Logs an event of type `SKHelperNotification`.
    ///
    /// - Parameter event: An event of type `SKHelperNotification`.
    ///
    public static func logEvent(_ event: SKHelperNotification) {
        #if DEBUG
        print(event.shortDescription())
        #else
        os_log("%{public}s", log: skhelperLog, type: .default, event.shortDescription())
        #endif
    }
    
    /// Logs an event of type `SKHelperNotification` for a `ProductId` and transaction id.
    ///
    /// - Parameters:
    ///   - event: An event of type `SKHelperNotification`.
    ///   - productId: The unique id of a product.
    ///   - transactionId: The unique id of a `Transaction`.
    ///
    public static func logEvent(_ event: SKHelperNotification, productId: ProductId, transactionId: String? = nil) {
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId) \(transactionId == nil ? "" : "with transaction id \(transactionId!)")")
        #else
        os_log("%{public}s for product %{public}s", log: skhelperLog, type: .default, event.shortDescription(), productId)
        #endif
    }
    
    /// Logs an event of type `SKHelperNotification` for a `ProductId` web order line item id and transaction id.
    ///
    /// - Parameters:
    ///   - event: An event of type `SKHelperNotification`.
    ///   - productId: The unique id of a product.
    ///   - webOrderLineItemId: An Apple web order line item id.
    ///   - transactionId: The unique id of a `Transaction`.
    ///
    public static func logEvent(_ event: SKHelperNotification, productId: ProductId, webOrderLineItemId: String?, transactionId: String? = nil) {
        #if DEBUG
        print("\(event.shortDescription()) for product \(productId) with webOrderLineItemId \(webOrderLineItemId ?? "none") \(transactionId == nil ? "" : "and transaction id \(transactionId!)")")
        #else
        os_log("%{public}s for product %{public}s with webOrderLineItemId %{public}s",
               log: skhelperLog,
               type: .default,
               event.shortDescription(),
               productId,
               webOrderLineItemId ?? "none")
        #endif
    }
}
