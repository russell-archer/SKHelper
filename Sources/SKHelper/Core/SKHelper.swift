//
//  SKHelper.swift
//  SKHelper
//
//  Created by Russell Archer on 14/07/2024.
//

public import StoreKit

/// SKHelper, a lightweight StoreKit helper.
@available(iOS 17.0, macOS 14.6, *)
@MainActor
public class SKHelper: Observable {
    
    // MARK: - Public properties
    
    /// Array of `SKProduct`, which includes localized `Product` info retrieved from the App Store and a cached product entitlement.
    public private(set) var products = [SKProduct]()
    
    /// When set to `true` `SKHelper` will use previously cached values for product entitlements if calls to `Transaction.currentEntitlement(for:)` return nil.
    /// Using cached entitlements can help mitigate issues where `Transaction.currentEntitlement(for:)` can sometimes erroneously indicate the user does not have an
    /// entitlement to use a product.
    public var useCachedEntitlements = true

    // MARK: - Private properties
    
    /// Handler for App Store transactions.
    private var transactionListener: Task<Void, any Error>? = nil

    /// Handler for purchase intents from App Store-promoted IAPs.
    private var purchaseIntentListener: Task<Void, any Error>? = nil
    
    /// Handler for changes to subscriptions.
    private var subscriptionListener: Task<Void, any Error>? = nil
    
    /// The current internal state of `SKHelper`.
    private var purchaseState: SKPurchaseState = .unknown
    
    // MARK: - Init/deinit
    
    /// Gets a collection of `ProductId`, cached purchased state and localized `Product` information. Also automatically start listening for App Store transactions,
    /// purchase intents and subscription changes.
    ///
    public init() {
        transactionListener = handleTransactions()
        purchaseIntentListener = handlePurchaseIntents()
        subscriptionListener = handleSubscriptionChanges()
        
        // Read our list of product ids
        guard let productIds = SKConfiguration.readProductConfiguration() else { return }
        
        // Get the cache of purchased product ids
        let purchasedProductIds = readPurchasedProducts()
        
        // Get localized product info from the App Store and create a collection of `SKProduct`
        Task { @MainActor in
            if let localizedProducts = await requestProducts(productIds: Array(productIds)) {
                localizedProducts.forEach { localizedProduct in
                    products.append(SKProduct(product: localizedProduct, hasEntitlement: purchasedProductIds.contains(localizedProduct.id)))
                }
            }
        }
    }
    
    /// Gets a collection of `ProductId`, cached purchased state and localized `Product` information. Also automatically start listening for App Store transactions,
    /// purchase intents and subscription changes.
    ///
    /// This initializer also allows you to set the value of `useCachedEntitlements` which, when set to `true` ensures that `SKHelper` will use previously cached
    /// values for product entitlements if calls to `Transaction.currentEntitlement(for:)` return nil. Using cached entitlements can help mitigate issues where
    ///  `Transaction.currentEntitlement(for:)` can sometimes erroneously indicate the user does not have an entitlement to use a product.
    ///
    public convenience init(useCachedEntitlements: Bool = true) {
        self.init()
        self.useCachedEntitlements = useCachedEntitlements
    }
    
    /// Stop listening for App Store transactions, purchase intents and subscription changes.
    ///
    deinit {
        transactionListener?.cancel()
        purchaseIntentListener?.cancel()
        subscriptionListener?.cancel()
    }
    
    // MARK: - Public methods
    
    /// Request localized product info from the App Store for a collection of `ProductId`.
    ///
    /// - Parameter productIds: The product ids that you want localized information for.
    /// - Returns: Returns an array of `Product`, or nil if no product information is returned by the App Store.
    ///
    public func requestProducts(productIds: [ProductId]) async -> [Product]? {
        SKLog.event(.requestProductsStart)
        
        guard let localizedProducts = try? await Product.products(for: productIds) else {
            SKLog.event(.requestProductsFailure)
            return nil
        }
        
        SKLog.event(.requestProductsSuccess)
        return localizedProducts
    }

    /// Purchase a `Product` previously returned from the App Store.
    ///
    /// - Parameter product: The `Product` to purchase.
    /// - Parameter options: Purchase options. See `Product.PurchaseOption`.
    /// - Returns: Returns a tuple consisting of a `Transaction` object that represents the purchase and a `SKPurchaseState` describing the state of the purchase.
    ///
    public func purchase(_ product: Product, options: Set<Product.PurchaseOption> = []) async -> (transaction: Transaction?, purchaseState: SKPurchaseState)  {
        
        guard AppStore.canMakePayments else {
            SKLog.event(.purchaseUserCannotMakePayments)
            return (nil, .userCannotMakePayments)
        }
        
        guard purchaseState != .inProgress else {
            SKLog.event(.purchaseAlreadyInProgress, productId: product.id)
            return (nil, .puchaseAlreadyInProgress)
        }
        
        // Start a purchase transaction
        purchaseState = .inProgress
        SKLog.event(.purchaseInProgress, productId: product.id)
        
        let result = try? await product.purchase(options: options)  // Purchase the product
        
        return await purchaseCompletion(for: product, with: result)
    }
    
    /// Call this method when the user starts a purchase via a StoreKit view and your code uses the `.onInAppPurchaseStart` view modifier.
    /// This allows SKHelper to prevent other purchases which may interfer with the process.
    ///
    /// ## Note ##
    /// If you do not use the `.onInAppPurchaseStart` view modifier in your SwiftUI code there is no requirement to call this method.
    ///
    /// - Parameter product: The `Product` the user has started the purchase workflow for.
    ///
    public func purchaseDidStart(product: Product) {
        guard AppStore.canMakePayments else {
            SKLog.event(.purchaseUserCannotMakePayments)
            return
        }
        
        guard purchaseState != .inProgress else {
            SKLog.event(.purchaseAlreadyInProgress, productId: product.id)
            return
        }
        
        purchaseState = .inProgress
        SKLog.event(.purchaseInProgress, productId: product.id)
    }
    
    /// Call this method when the user completes a purchase workflow via a StoreKit view and your code uses the `.onInAppPurchaseCompletion` view modifier.
    ///
    /// ## Example usage ##
    /// ```
    /// StoreView(ids: store.allProductIds) { product in
    ///     Image(product.id).resizable()
    /// }
    /// .onInAppPurchaseStart { product in
    ///     store.purchaseDidStart(product: product)
    /// }
    /// .onInAppPurchaseCompletion { product, result in
    ///     let verifiedResult = await store.purchaseCompletion(for: product, with: try? result.get())
    ///     if verifiedResult.purchaseState == .purchased {
    ///         print("You now have access to \(product.id)")
    ///     }
    /// }
    /// ```
    /// This allows `SKHelper` to process and finish the `Transaction` as the use of `.onInAppPurchaseCompletion` prevents transaction updates being
    /// handled in the normal manner by the `SKHelper.handleTransactions` (i.e. the transaction update is never received).
    ///
    /// ## Note ##
    /// If you do not use the `.onInAppPurchaseCompletion` view modifier in your SwiftUI code there is no requirement to call this method.
    ///
    /// - Parameter result: The `Product.PurchaseResult` of the purchase process, or nil if there was an error during the purchase.
    /// - Returns: Returns a tuple consisting of a `Transaction` object that represents the purchase and a `SKPurchaseState` describing the state of the purchase.
    ///
    public func purchaseCompletion(for product: Product, with result: Product.PurchaseResult?) async -> (transaction: Transaction?, purchaseState: SKPurchaseState) {
        guard let result else {
            purchaseState = .failed
            SKLog.event(.purchaseFailure, productId: product.id)
            return (nil, .failed)
        }
        
        // Every time an app receives a transaction from StoreKit, the transaction has already passed through a
        // verification process to confirm whether the payload is signed by the App Store for my app for this device.
        // That is, StoreKit automatically does transaction (receipt) verification for you.

        // We now have a PurchaseResult value. See if the purchase suceeded, failed, was cancelled or is pending.
        switch result {
            case .success(let verificationResult):

                // The purchase seems to have succeeded. StoreKit has already automatically attempted to validate
                // the transaction, returning the result of this validation wrapped in a `VerificationResult`.
                // We now need to check the `VerificationResult<Transaction>` to see if the transaction passed the
                // App Store's validation process. This is equivalent to receipt validation in StoreKit1.

                // Did the transaction pass StoreKit’s automatic validation?
                let checkResult = checkVerificationResult(result: verificationResult)
                if !checkResult.verified {
                    purchaseState = .failedVerification
                    SKLog.transaction(.transactionValidationFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    return (checkResult.transaction, .failedVerification)
                }

                let validatedTransaction = checkResult.transaction  // The transaction was successfully validated
                await validatedTransaction.finish()  // Tell the App Store we delivered the purchased content to the user

                updatePurchasedProducts(validatedTransaction.productID, purchased: true)

                // Let the caller know the purchase succeeded and that the user should be given access to the product
                purchaseState = .purchased
                SKLog.event(.purchaseSuccess, productId: product.id, transactionId: String(validatedTransaction.id))
                return (transaction: validatedTransaction, purchaseState: .purchased)

            case .userCancelled:
                purchaseState = .cancelled
                SKLog.event(.purchaseCancelled, productId: product.id)
                return (transaction: nil, .cancelled)

            case .pending:
                purchaseState = .pending
                SKLog.event(.purchasePending, productId: product.id)
                return (transaction: nil, .pending)

            default:
                purchaseState = .unknown
                SKLog.event(.purchaseFailure, productId: product.id)
                return (transaction: nil, .unknown)
        }
    }
    
    /// Checks the current entitlement for `productId` and returns true if the user is entitled to use the product,
    /// false otherwise.
    ///
    /// ## Note ##
    /// This method is intended for non-comsumable products. If `productId` identifies an auto-renewable subscription
    /// then `isSubscribed(productId)` is called.
    ///
    /// Note that the process of determining if a product is purchased can be unreliable. Calls to
    /// `Transaction.currentEntitlement(for:)` mostly produce the correct result. However, in both the Xcode testing
    /// and live production environments it is quite common for `Transaction.currentEntitlement(for:)` to erroneously
    /// return nil, indicating the user has not purchased the product.
    ///
    /// Also, calling `Transaction.currentEntitlement(for:)` can (seemingly randomly) result one of the following errors:
    ///
    /// - UIDevice.current.identifierForVendor
    /// - AppStore.deviceVerificationID
    /// - Domain=ASDErrorDomain Code=500 "(null)"
    ///
    /// Any of the above errors result in an invalid result for the current entitlement.
    ///
    /// Because of theses inconsistencies we maintain a `SKProduct` collection which contains a cached value
    /// for the user's entitlement to use each product.
    ///
    /// When checking the purchased state of a product we return true if `Transaction.currentEntitlement(for:)` returns
    /// non-nil. If the result is nil then we return true if the value of `SKProduct.hasEntitlement` is true,
    /// otherwise we return false.
    ///
    /// - Parameter productId: The `ProductId` to check.
    /// - Returns: Returns true if user is entitled to use the product, false otherwise.
    ///
    public func isPurchased(productId: ProductId) async throws -> Bool {
        guard let product = storeProduct(for: productId) else { return false }
        guard isNonConsumable(productId: productId) || isAutoRenewable(productId: productId) else { return false }
        
        if isAutoRenewable(productId: productId) { return await isSubscribed(productId: productId) == .subscribed }
        
        // We're dealing with a non-consumable product. Does the user have a current entitlement to use it?
        if let currentEntitlement = await Transaction.currentEntitlement(for: productId) {
            // The user has an entitlement. See if it has been verified by the App Store
            let verified = checkVerificationResult(result: currentEntitlement).verified
            if !verified { SKLog.transaction(.transactionValidationFailure, productId: productId) }
            updatePurchasedProducts(productId, purchased: verified)  // Updates `SKProduct.hasEntitlement`
            return verified
        }
        
        // The user appears NOT to have have an entitlement. See if we've previously cached an entitlement.
        return useCachedEntitlements ? product.hasEntitlement : false
    }
    
    /// Checks the current entitlement for `productId` to see if the user is entitled to use the product. A user may be
    /// subscribed to more than one subscription product in the same group, so a check is also made to ensure the product
    /// identified by `productId` is the highest value product currently subscribed to in the subscription group. If both
    /// checks are positive then true is returned, false otherwise.
    ///
    /// ## Note ##
    /// This method is intended only for **auto-renewable subscriptions**. If `productId` identifies any other type of product then an
    /// exception of type `StoreException.productTypeNotSupported` is thrown.
    ///
    /// Note that the process of determining if a product is purchased can be unreliable. Calls to
    /// `Transaction.currentEntitlement(for:)` mostly produce the correct result. However, in both the Xcode testing
    /// and live production environments it is quite common for `Transaction.currentEntitlement(for:)` to erroneously
    /// return nil, indicating the user has not purchased the product.
    ///
    /// Also, calling `Transaction.currentEntitlement(for:)` can (seemingly randomly) result one of the following errors:
    ///
    /// - UIDevice.current.identifierForVendor
    /// - AppStore.deviceVerificationID
    /// - Domain=ASDErrorDomain Code=500 "(null)"
    ///
    /// Any of the above errors result in an invalid result for the current entitlement.
    ///
    /// Because of theses inconsistencies we maintain a `SKProduct` collection which contains a cached value
    /// for the user's entitlement to use each product.
    ///
    /// When checking the purchased state of a subscription product we:
    ///
    /// - check the return of `Transaction.currentEntitlement(for:)`
    /// - check `SKProduct.hasEntitlement` for the product if the return from `Transaction.currentEntitlement(for:)` is nil
    /// - check if the product is the highest value product subscribed to in the subscription group
    ///
    /// ## Important ##
    /// Note that when checking the value of a product within a subscription group the product with the highest value will
    /// have the **lowest** `Product.subscription.groupLevel` value.
    ///
    /// For example, if we setup subscription products in the .storekit configuration file (or App Store Connect) like this:
    ///
    /// ```
    /// Level   ProductId
    /// 1       com.rarcher.subscription.vip.gold       - This product has the highest value
    /// 2       com.rarcher.subscription.vip.silver
    /// 3       com.rarcher.subscription.vip.bronze     - This product has the lowest value
    /// ```
    ///
    /// - Parameter productId: The `ProductId` to check.
    /// - Returns: Returns `SKSubscriptionState.subscribed` if user is entitled to use the product.
    /// - Returns `SKSubscriptionState.notSubscribed` if the product is not an auto-renewable subscription, or if an activate subscription to this product is not been found.
    /// - Returns `SKSubscriptionState.notVerified` if the user has to have an entitlement to use the product but we couldn't verify the transaction.
    /// - Returns `SKSubscriptionState.superceeded` if the subscription to this product has been superceeded by a subscription with a higher value product in the same subscription group.
    ///
    public func isSubscribed(productId: ProductId) async -> SKSubscriptionState {
        guard isAutoRenewable(productId: productId) else { return .notSubscribed }
        guard let storeProduct = storeProduct(for: productId), let groupName = storeProduct.groupName else { return .notSubscribed }
        
        // We're dealing with an auto-renewable product. Does the user have a current entitlement to use it?
        var hasEntitlement = false
        if let currentEntitlement = await Transaction.currentEntitlement(for: productId) {
            hasEntitlement = true
            if !checkVerificationResult(result: currentEntitlement).verified {
                // The user seems to have an entitlement but we couldn't verify it.
                SKLog.transaction(.transactionValidationFailure, productId: productId)
                updatePurchasedProducts(productId, purchased: false)
                return .notVerified
            }
        }
        
        if !hasEntitlement {
            // The user does NOT have an entitlement to use the product. In case this is a invalid result from
            // `Transaction.currentEntitlement(for:)` see if the user has previously had an entitlement cached.
            if !useCachedEntitlements { return .notSubscribed }
            if !storeProduct.hasEntitlement {
                updatePurchasedProducts(productId, purchased: false)
                return .notSubscribed
            }
        }
        
        // The user DOES have an entitlement to this product, but do they have an entitlement to a subscription
        // product of a higher-value in the same subscription group? We check this because the user may be subscribed
        // to one or more products in a subscription group at the same time. This is usually related to family sharing.
        // However, normally we're only interested in the most high-value product the user is subscribed to in a group.

        let mostValuableActiveSubscription = await highestValueActiveSubscription(in: groupName)
        
        // Is the highestActiveSubscription the product we were asked to check?
        var result: SKSubscriptionState
        if let mostValuableActiveSubscription {
            result = mostValuableActiveSubscription.id == storeProduct.id ? .subscribed : .superceeded
        } else {
            result = .notSubscribed
        }
        
        updatePurchasedProducts(productId, purchased: result == .subscribed)
        return result
    }
    
    /// Return the highest service level auto-renewing subscription the user is subscribed to in the `subscriptionGroup`.
    /// - Parameter subscriptionGroup: The name of the subscription group.
    /// - Returns: Returns the `Product` for the highest service level auto-renewing subscription the user is subscribed to in the `subscriptionGroup`, or nil if the user isn't subscribed to a product in the group.
    ///
    /// When getting information on the highest service level auto-renewing subscription the user is subscribed to we enumerate the `Product.subscription.status` array that is a property of each `Product` in the group.
    /// This array is empty if the user has never subscribed to a product in this subscription group. If the user is subscribed to a product the `statusCollection.count` should be at least 1.
    /// Each `Product` in a subscription group provides access to the same `Product.SubscriptionInfo.Status` array via its `product.subscription.status` property.
    ///
    /// Enumeration of the `SubscriptionInfo.Status` array is necessary because a user may have multiple active subscriptions to products in the same subscription group. For example, a user may have
    /// subscribed themselves to the "Gold" product, as well as receiving an automatic subscription to the "Silver" product through family sharing. In this case, we'd need to return information on the "Gold" product.
    ///
    /// Also, note that even if the `Product.SubscriptionInfo.Status` collection does NOT contain a particular product `Transaction.currentEntitlement(for:)` may still report that the user has an
    /// entitlement. This can happen when upgrading or downgrading subscriptions. Because of this we always need to search the `Product.SubscriptionInfo.Status` collection for a subscribed product with a higher-value.
    ///
    public func highestValueActiveSubscription(in groupName: String) async -> Product? {
        // The higher the value product, the LOWER the `Product.subscription.groupLevel` value.
        // The highest value product will have a `Product.subscription.groupLevel` value of 1.
        
        // Get the group id associated with the supplied group name
        guard let groupId = subscriptionGroupId(from: groupName) else { return nil }
        
        // Get all the subscriptions statuses for the group
        guard let groupSubscriptionStatus = try? await Product.SubscriptionInfo.status(for: groupId) else { return nil }
        
        // Filter-out any subscription the user's not actively subscribed to
        let activeSubscriptions = groupSubscriptionStatus.filter { $0.state == .subscribed }
        guard !activeSubscriptions.isEmpty else { return nil }
        
        // Check the transaction for each subscription is verified and collect their products ids
        let verifiedActiveSubscriptionProductIds = activeSubscriptions.compactMap {
            let statusTransactionResult = checkVerificationResult(result: $0.transaction)
            if statusTransactionResult.verified { return statusTransactionResult.transaction.productID as ProductId } else { return nil }
        }
        
        // Get the actual `Product` objects for each active and verified subscrition
        let subscriptionProducts = products(from: verifiedActiveSubscriptionProductIds)
        
        // Return the active subscription with the highest value (lowest group level).
        // Important: Remember, the higher the value product, the LOWER the `Product.subscription.groupLevel` value.
        // The highest value product will have a `Product.subscription.groupLevel` value of 1.
        return subscriptionProducts.min { $0.subscription?.groupLevel ?? Int.max < $1.subscription?.groupLevel ?? Int.max }
    }
    
    /// Provides information on the purchase of a non-consumable product.
    ///
    /// - Parameter productId: The `ProductId` of the non-consumable product.
    /// - Returns: Returns `SKPurchaseInformation` containing info on the purchase of a non-consumable product. nil is returned if the product has not been purchased or it's not a non-consumable.
    ///
    public func purchaseInformation(for productId: ProductId) async -> SKPurchaseInformation? {
        guard let product = product(from: productId), isNonConsumable(productId: productId) else { return nil }
        
        var pi = SKPurchaseInformation(id: product.id, name: product.displayName, isPurchased: false, productType: product.type, purchasePrice: product.displayPrice)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
        
        pi.isPurchased = (try? await isPurchased(productId: product.id)) ?? false
        guard pi.isPurchased else { return pi }
        guard let transaction = await mostRecentTransaction(for: product.id) else { return pi }

        pi.transactionId = transaction.id
        pi.purchaseDate = transaction.purchaseDate
        pi.purchaseDateFormatted = dateFormatter.string(from: transaction.purchaseDate)
        pi.revocationDate = transaction.revocationDate
        pi.revocationDateFormatted = transaction.revocationDate == nil ? nil : dateFormatter.string(from: transaction.revocationDate!)
        pi.revocationReason = transaction.revocationReason
        pi.ownershipType = transaction.ownershipType
        
        return pi
    }
    
    /// Provides information on the purchase of an auto-renewable subscription productin a format that's suitable for direct display to the user.
    ///
    /// - Parameter productId: The `ProductId` of the auto-renewable subscription product.
    /// - Returns: Returns `SKSubscriptionInformation` containing info on the purchase of an auto-renewable subscription product. nil is returned if the product has not been purchased or it's not an auto-renewable.
    ///
    public func subscriptionInformation(for productId: ProductId) async -> SKSubscriptionInformation? {
        guard let product = product(from: productId), isAutoRenewable(productId: productId) else { return nil }
        
        var subInfo = SKSubscriptionInformation(product: product)  // Create a struct to hold the subscription data
        
        let subscriptionState = await isSubscribed(productId: product.id)
        switch subscriptionState {
            case .subscribed:
                subInfo.isSubscribed = true
                subInfo.isSuperceeded = false
                subInfo.isVerified = true
            case .superceeded:
                subInfo.isSubscribed = false
                subInfo.isSuperceeded = true
                subInfo.isVerified = true
                return subInfo
            case .notSubscribed: fallthrough
            case .notVerified:
                subInfo.isSubscribed = false
                subInfo.isSuperceeded = false
                subInfo.isVerified = false
                return subInfo
        }
        
        // At this point we're dealing with an active subscription that has been verified and is not superceeded
        
        // Get the latest transaction
        guard let transactionVerificationResult = await product.latestTransaction else { return subInfo }
        
        // Unwrap the verification result and make sure it was verified by StoreKit
        let unwrappedVerificationResult = checkVerificationResult(result: transactionVerificationResult)
        guard unwrappedVerificationResult.verified else { return subInfo }
        
        // Get the subscription status from the transaction object
        let transaction = unwrappedVerificationResult.transaction
        guard let status = await transaction.subscriptionStatus else { return subInfo }
        
        // Store the subscription's state
        switch status.state {
            case .subscribed:           subInfo.subscribedtext = "Subscribed"
            case .inGracePeriod:        subInfo.subscribedtext = "Subscribed. Expires shortly"
            case .inBillingRetryPeriod: subInfo.subscribedtext = "Subscribed. Renewal failed"
            case .revoked:              subInfo.subscribedtext = "Subscription revoked"
            case .expired:              subInfo.subscribedtext = "Subscription expired"
            default:
                subInfo.isSubscribed = false
                subInfo.subscribedtext = "Subscription state unknown"
        }

        // Get the subscription object
        guard let subscription = product.subscription else { return subInfo }
                
        // Create text that describes the subscription period (e.g. "14 days"
        var periodUnitText: String?
        switch subscription.subscriptionPeriod.unit {
            case .day:   periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "days"   : "day"
            case .week:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "weeks"  : "week"
            case .month: periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "months" : "month"
            case .year:  periodUnitText = subscription.subscriptionPeriod.value > 1 ? String(subscription.subscriptionPeriod.value) + "years"  : "year"
            @unknown default: periodUnitText = nil
        }

        // Create text that will be used to display the renewal period to the user (e.g. "Every 14 days")
        if let periodUnitText { subInfo.renewalPeriod = "Every \(periodUnitText)"}
        else { subInfo.renewalPeriod = "Unknown renewal period"}
        
        // Get subscription renewal info
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM y"
            
        // Will the current subscription automatically renew?
        if let renewalInfo = try? status.renewalInfo.payloadValue { subInfo.autoRenewOn = renewalInfo.willAutoRenew }
        else { subInfo.autoRenewOn = false }
        
        // When (the date) will the subscription renew?
        if let renewalDate = transaction.expirationDate {
            if transaction.isUpgraded { subInfo.upgraded = true }
            else  {

                subInfo.upgraded = false
                subInfo.renewalDate = dateFormatter.string(from: renewalDate)

                // Create text that describes how long until the current subscription will renew or expire
                let diffComponents = Calendar.current.dateComponents([.day], from: Date(), to: renewalDate)
                if let daysLeft = diffComponents.day {
                    if daysLeft > 1 { subInfo.renewsIn = "\(daysLeft) days" }
                    else if daysLeft == 1 { subInfo.renewsIn! += "\(daysLeft) day" }
                    else { subInfo.renewsIn = "Today" }
                }
            }
        }

        // General info about the most recent transaction
        subInfo.transactionId = transaction.id
        subInfo.purchaseDate = transaction.purchaseDate
        subInfo.purchaseDateFormatted = dateFormatter.string(from: transaction.purchaseDate)
        subInfo.revocationDate = transaction.revocationDate
        subInfo.revocationDateFormatted = transaction.revocationDate == nil ? nil : dateFormatter.string(from: transaction.revocationDate!)
        subInfo.revocationReason = transaction.revocationReason
        subInfo.ownershipType = transaction.ownershipType
        
        // TODO: Add all previous transactions for the product here (add a history to SKSubscriptionInformation)
        
        return subInfo
    }
    
    /// Gets the unique `Transaction` id for the product's most recent transaction.
    /// - Parameter productId: The product's unique App Store id.
    /// - Returns: Returns the unique `Transaction` id for the product's most recent transaction, or nil if the product's never been purchased.
    ///
    public func mostRecentTransactionId(for productId: ProductId) async -> UInt64? {
        if let result = await Transaction.latest(for: productId) {
            let verificationResult = checkVerificationResult(result: result)
            if verificationResult.verified { return verificationResult.transaction.id }
        }
        
        return nil
    }
    
    /// Gets the most recent `Transaction` for the product.
    /// - Parameter productId: The product's unique App Store id.
    /// - Returns: Returns the most recent `Transaction` for the product, or nil if the product's never been purchased.
    ///
    public func mostRecentTransaction(for productId: ProductId) async -> Transaction? {
        if let result = await Transaction.latest(for: productId) {
            let verificationResult = checkVerificationResult(result: result)
            if verificationResult.verified { return verificationResult.transaction }
        }
        
        return nil
    }
    
    // MARK: - Private methods
        
    /// This is an infinite async sequence (loop). It will continue waiting for transactions until it is explicitly canceled by calling the `Task.cancel()` method. See `transactionListener`.
    ///
    /// - Returns: Returns a task for the transaction handling loop.
    ///
    private func handleTransactions() -> Task<Void, any Error> {
        
        // Note: Previously had this as a detached task. However, with Xcode 16 Beta 5 this produces the error:
        // "Main actor-isolated value of type '() async -> Void' passed as a strongly transferred parameter; later accesses could race"
        
        return Task { @MainActor [self] in
            for await verificationResult in Transaction.updates {
                
                // See if StoreKit validated the transaction
                let checkResult = checkVerificationResult(result: verificationResult)
                guard checkResult.verified else {
                    // StoreKit's attempts to validate the transaction failed
                    SKLog.transaction(.transactionFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    return
                }
                
                let transaction = checkResult.transaction  // The transaction was validated by StoreKit
                guard transaction.productType == .autoRenewable || transaction.productType == .nonConsumable else {
                    SKLog.event("Product type \(transaction.productType.localizedDescription) is not supported.")
                    return
                }
                
                await transaction.finish()  // Finish the transaction for all cases, including access revoked, subscription expired, subscription upgraded and successful purchase
                
                if transaction.revocationDate != nil {
                    // The user's access to the product has been revoked by the App Store (e.g. a refund, etc.)
                    // See transaction.revocationReason for more details if required
                    SKLog.transaction(.transactionRevoked, productId: transaction.productID, transactionId: String(transaction.id))
                    updatePurchasedProducts(transaction.productID, purchased: false)
                    return
                }
                
                if transaction.isUpgraded {
                    // Transaction superceeded by an active, higher-value subscription
                    SKLog.transaction(.transactionUpgraded, productId: transaction.productID, transactionId: String(transaction.id))
                    updatePurchasedProducts(transaction.productID, purchased: false)  // Not subscribed because it's been superceeded
                    
                    /*
                     
                        ** BUG in StoreKit **
                     
                        Subscribe to a product, then upgrade it to a higher-value product. From that point onwards we don't get ANY
                        notifications on the Transaction.updates loop. So purchasing a non-consumable results in that transaction
                        being unfinished, and we also don't get a chance to cache the purchase state of that product.
                        As a workaround we cancel and immediately restart the `transactionListener` task, which seems to restart
                        the flow of notifications.
                     
                     */
                    
                    transactionListener?.cancel()  // See StoreKit bug comments above
                    transactionListener = handleTransactions()
                    return
                }
                
                // Update the list of products the user has access to
                SKLog.transaction(.transactionSuccess, productId: transaction.productID, transactionId: String(transaction.id))
                updatePurchasedProducts(transaction.productID, purchased: true)
            }
        }
    }
    
    /// Handles all purchase status change updates related to subscriptions.
    ///
    /// - Returns: Returns a task for the subscription changes handling loop.
    ///
    private func handleSubscriptionChanges() -> Task<Void, any Error> {
        return Task { @MainActor [self] in
            for await status in Product.SubscriptionInfo.Status.updates {
                guard let renewalInfo = try? status.renewalInfo.payloadValue, let transaction = try? status.transaction.payloadValue else { return }
                
                await transaction.finish()  // Finish the transaction here because sometimes we don't get an update via `Transaction.updates`
                SKLog.subscriptionChanged(productId: transaction.productID, transactionId: String(transaction.id), newSubscriptionStatus: status.state.localizedDescription)
                if let expired = renewalInfo.expirationReason, let expirationDate = transaction.expirationDate {
                    SKLog.transaction(.transactionExpired, productId: transaction.productID, transactionId: String(transaction.id))
                    SKLog.event("Subscription for \(transaction.productID) expired on \(expirationDate) because \(expired.localizedDescription).")
                }
                
                updatePurchasedProducts(transaction.productID, purchased: status.state == .subscribed)
            }
        }
    }
    
    /// Handles all purchase intents resulting from direct App Store purchases for promoted products.
    ///
    /// - Returns: Returns a task for the purchase intents handling loop.
    ///
    private func handlePurchaseIntents() -> Task<Void, any Error> {
        return Task { @MainActor [self] in
            for await purchaseIntent in PurchaseIntent.intents {
                SKLog.event(.purchaseIntentRecieved, productId: purchaseIntent.product.id)
                let purchaseResult = await purchase(purchaseIntent.product)  // Proceed with the normal product purchase flow
                purchaseState = purchaseResult.purchaseState
            }
        }
    }
    
    /// Check if StoreKit was able to automatically verify a transaction by inspecting the verification result.
    ///
    /// - Parameter result: The transaction `VerificationResult` to check.
    /// - Returns: Returns an `SKUnwrappedVerificationResult<T>` where `verified` is true if the transaction was successfully verified by StoreKit.
    /// When `verified` is false `verificationError` will be non-nil.
    ///
    private func checkVerificationResult<T>(result: VerificationResult<T>) -> SKUnwrappedVerificationResult<T> {
        
        switch result {
            case .unverified(let unverifiedTransaction, let error):
                // StoreKit failed to automatically validate the transaction
                return SKUnwrappedVerificationResult(transaction: unverifiedTransaction, verified: false, verificationError: error)
                
            case .verified(let verifiedTransaction):
                // StoreKit successfully automatically validated the transaction
                return SKUnwrappedVerificationResult(transaction: verifiedTransaction, verified: true, verificationError: nil)
        }
    }
    
    /// Update our cache of purchased products.
    /// 
    /// - Parameters:
    ///   - productId: The `ProductId` to insert/remove.
    ///   - insert: If true the `ProductId` is purchased.
    ///   - purchased: true if the product is to be flagged as purchased, false otherwise.
    ///
    private func updatePurchasedProducts(_ productId: ProductId, purchased: Bool) {
        if let product = storeProduct(for: productId) {
            product.hasEntitlement = purchased
            savePurchasedProducts()
        }
    }
    
    /// Read the cache of purchased products from storage.
    ///
    /// - Returns: Returns the list of fallback product ids, or an empty collection if none is available.
    ///
    private func readPurchasedProducts() -> [ProductId] {
        if let purchaseProductIds = UserDefaults.standard.object(forKey: SKConstants.PurchasedProductsKey) as? [ProductId] {
            return purchaseProductIds
        }
        
        return [ProductId]()
    }
    
    /// Saves the cache of purchased product ids. Ids saved will have at least one positive entitlement.
    ///
    private func savePurchasedProducts() {
        var purchaseProductIds = [ProductId]()
        
        products.forEach { product in
            if product.hasEntitlement { purchaseProductIds.append(product.id) }
        }
        
        UserDefaults.standard.set(purchaseProductIds, forKey: SKConstants.PurchasedProductsKey)
    }
}

