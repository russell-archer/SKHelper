//
//  SKHelper.swift
//  StoreKitViewsDemo
//
//  Created by Russell Archer on 14/07/2024.
//

public import StoreKit

/// SKHelper, a lightweight StoreKit helper
@available(iOS 16.4, macOS 14.6, *)
@MainActor
public class SKHelper: Observable {
    
    // MARK: - Public properties
    
    /// Array of `SKHelperProduct`, which includes localized `Product` info retrieved from the App Store and a cached product entitlement.
    public private(set) var products = [SKHelperProduct]()

    // MARK: - Private properties
    
    /// Handler for App Store transactions.
    private var transactionListener: Task<Void, any Error>? = nil

    /// Handler for purchase intents from App Store-promoted IAPs.
    private var purchaseIntentListener: Task<Void, any Error>? = nil
    
    /// Handler for changes to subscriptions.
    private var subscriptionListener: Task<Void, any Error>? = nil
    
    /// The current internal state of SKHelper. If `purchaseState == inProgress` then an attempt to start
    /// a new purchase will result in a `purchaseInProgressException` being thrown by `purchase(_:)`.
    private var purchaseState: PurchaseState = .unknown
    
    // MARK: - Init/deinit
    
    init() {
        // Start listening for App Store transactions, purchase intents and subscription changes
        transactionListener = handleTransactions()
        purchaseIntentListener = handlePurchaseIntents()
        subscriptionListener = handleSubscriptionChanges()
        
        // Read our list of product ids
        guard let productIds = SKHelperConfiguration.readProductConfiguration() else { return }
        
        // Get the cache of purchased product ids
        let purchasedProductIds = readPurchasedProducts()
        
        // Get localized product info from the App Store and create a collection of `SKHelperProduct`
        Task { @MainActor in
            if let localizedProducts = await requestProducts(productIds: Array(productIds)) {
                localizedProducts.forEach { localizedProduct in
                    products.append(SKHelperProduct(product: localizedProduct, hasEntitlement: purchasedProductIds.contains(localizedProduct.id)))
                }
            }
        }
    }
    
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
    public func requestProducts(productIds: [ProductId]) async -> [Product]? {
        SKHelperLog.event(.requestProductsStart)
        
        guard let localizedProducts = try? await Product.products(for: productIds) else {
            SKHelperLog.event(.requestProductsFailure)
            return nil
        }
        
        SKHelperLog.event(.requestProductsSuccess)
        return localizedProducts
    }
    
    /// Purchase a `Product` previously returned from the App Store.
    ///
    /// May throw an exception of type:
    /// - `StoreException.purchaseException` if the App Store itself throws an exception
    /// - `StoreException.purchaseInProgressException` if a purchase is already in progress
    /// - `StoreException.transactionVerificationFailed` if the purchase transaction failed verification
    ///
    /// - Parameter product: The `Product` to purchase.
    /// - Parameter options: Purchase options. See Product.PurchaseOption.
    /// - Returns: Returns a tuple consisting of a transaction object that represents the purchase and a `PurchaseState`
    /// describing the state of the purchase.
    public func purchase(_ product: Product, options: Set<Product.PurchaseOption> = []) async throws -> (transaction: Transaction?, purchaseState: PurchaseState)  {
        
        guard AppStore.canMakePayments else {
            SKHelperLog.event(.purchaseUserCannotMakePayments)
            return (nil, .userCannotMakePayments)
        }
        
        guard purchaseState != .inProgress else {
            SKHelperLog.exception(.purchaseInProgressException, productId: product.id)
            throw StoreException.purchaseInProgressException
        }
        
        // Start a purchase transaction
        purchaseState = .inProgress
        SKHelperLog.event(.purchaseInProgress, productId: product.id)

        let result: Product.PurchaseResult
        do { result = try await product.purchase(options: options) } catch {
            purchaseState = .failed
            SKHelperLog.event(.purchaseFailure, productId: product.id)
            throw StoreException.purchaseException(.init(error: error))
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
                    SKHelperLog.transaction(.transactionValidationFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    throw StoreException.transactionVerificationFailed
                }

                let validatedTransaction = checkResult.transaction  // The transaction was successfully validated
                await validatedTransaction.finish()  // Tell the App Store we delivered the purchased content to the user

                updatePurchasedProducts(validatedTransaction.productID, purchased: true)

                // Let the caller know the purchase succeeded and that the user should be given access to the product
                purchaseState = .purchased
                SKHelperLog.event(.purchaseSuccess, productId: product.id, transactionId: String(validatedTransaction.id))
                return (transaction: validatedTransaction, purchaseState: .purchased)

            case .userCancelled:
                purchaseState = .cancelled
                SKHelperLog.event(.purchaseCancelled, productId: product.id)
                return (transaction: nil, .cancelled)

            case .pending:
                purchaseState = .pending
                SKHelperLog.event(.purchasePending, productId: product.id)
                return (transaction: nil, .pending)

            default:
                purchaseState = .unknown
                SKHelperLog.event(.purchaseFailure, productId: product.id)
                return (transaction: nil, .unknown)
        }
    }
    
    /// Checks the current entitlement for `productId` and returns true if the user is entitled to use the product,
    /// false otherwise. Intended for non-comsumable products. If `productId` identifies an auto-renewable subscription
    /// then `isSubscribed(productId)` is called.
    ///
    /// Note that the process of determining if a product is purchased can be unreliable. Calls to
    /// `Transaction.currentEntitlement(for:)` mostly produce the correct result. However, in both the Xcode testing
    /// and live production environments it is quite common for `Transaction.currentEntitlement(for:)` to erroneously
    /// return nil, indicating the user has not purchased the product. Also, calling `Transaction.currentEntitlement(for:)`
    /// can (seemingly randomly) result one of the following errors:
    ///
    /// - UIDevice.current.identifierForVendor
    /// - AppStore.deviceVerificationID
    /// - Domain=ASDErrorDomain Code=500 "(null)"
    ///
    /// Any of the above errors result in an invalid result for the current entitlement.
    ///
    /// Because of theses inconsistencies we maintain a `SKHelperProduct` collection which contains a cached value
    /// for the user's entitlement to use each product.
    ///
    /// When checking the purchased state of a product we return true if `Transaction.currentEntitlement(for:)` returns
    /// non-nil. If the result is nil then we return true if the value of `SKHelperProduct.hasEntitlement` is true,
    /// otherwise we return false.
    ///
    /// - Parameter productId: The `ProductId` to check.
    /// - Returns: Returns true if user is entitled to use the product, false otherwise.
    /// - Throws: `StoreException.productTypeNotSupported` if the product identified by `productId` is a consumable.
    /// - Throws: `StoreException.productNotFound` if the product identified by `productId` cannot be found in `SKHelperProduct.products`.
    public func isPurchased(productId: ProductId) async throws -> Bool {
        guard let product = storeProduct(for: productId) else { throw StoreException.productNotFound }
        guard !isConsumable(productId: productId) else { throw StoreException.productTypeNotSupported }
        
        if isAutoRenewable(productId: productId) { return try await isSubscribed(productId: productId) }
        
        // We're dealing with a non-consumable product. Does the user have a current entitlement to use it?
        if let currentEntitlement = await Transaction.currentEntitlement(for: productId) {
            // The user has an entitlement. See if it has been verified by the App Store
            let verified = checkVerificationResult(result: currentEntitlement).verified
            if !verified { SKHelperLog.transaction(.transactionValidationFailure, productId: productId) }
            updatePurchasedProducts(productId, purchased: verified)
            return verified
        }
        
        // The user appears not to have have an entitlement. See if we've had previous success validating an entitlement.
        return product.hasEntitlement
    }
    
    /// Checks the current entitlement for `productId` to see if the user is entitled to use the product. A user may be
    /// subscribed to more than one subscription product in the same group, so a check is also made to ensure the product
    /// identified by `productId` is the highest value product currently subscribed to in the subscription group. If both
    /// checks are positive then true is returned, false otherwise.
    ///
    /// Intended only for auto-renewable subscriptions. If `productId` identifies any other type of product then an
    /// exception of type `StoreException.productTypeNotSupported` is thrown.
    ///
    /// Note that the process of determining if a product is purchased can be unreliable. Calls to
    /// `Transaction.currentEntitlement(for:)` mostly produce the correct result. However, in both the Xcode testing
    /// and live production environments it is quite common for `Transaction.currentEntitlement(for:)` to erroneously
    /// return nil, indicating the user has not purchased the product. Also, calling `Transaction.currentEntitlement(for:)`
    /// can (seemingly randomly) result one of the following errors:
    ///
    /// - UIDevice.current.identifierForVendor
    /// - AppStore.deviceVerificationID
    /// - Domain=ASDErrorDomain Code=500 "(null)"
    ///
    /// Any of the above errors result in an invalid result for the current entitlement.
    ///
    /// Because of theses inconsistencies we maintain a `SKHelperProduct` collection which contains a cached value
    /// for the user's entitlement to use each product.
    ///
    /// When checking the purchased state of a subscription product we:
    ///
    /// - check the return of `Transaction.currentEntitlement(for:)`
    /// - check `SKHelperProduct.hasEntitlement` for the product if the return from `Transaction.currentEntitlement(for:)` is nil
    /// - check if the product is the highest value product subscribed to in the subscription group.
    ///
    /// **Important**
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
    /// - Returns: Returns true if user is entitled to use the product, false otherwise.
    /// - Throws: `StoreException.productTypeNotSupported` if the product identified by `productId` is not an auto-renewable subscription.
    /// - Throws: `StoreException.productNotFound` if the product identified by `productId` cannot be found in `SKHelperProduct.products`.
    public func isSubscribed(productId: ProductId) async throws -> Bool {
        guard let storeProduct = storeProduct(for: productId) else { throw StoreException.productNotFound }
        guard isAutoRenewable(productId: productId) else { throw StoreException.productTypeNotSupported }
        
        // We're dealing with an auto-renewable product. Does the user have a current entitlement to use it?
        var hasEntitlement = false
        if let currentEntitlement = await Transaction.currentEntitlement(for: productId) {
            hasEntitlement = true
            if !checkVerificationResult(result: currentEntitlement).verified {
                // The user seems to have an entitlement but we couldn't verify it.
                SKHelperLog.transaction(.transactionValidationFailure, productId: productId)
                updatePurchasedProducts(productId, purchased: false)
                return false
            }
        }
        
        if !hasEntitlement {
            // The user doesn't seem to have an entitlement to use the product. In case this is a invalid result
            // from `Transaction.currentEntitlement(for:)` see if the user has previously had an entitlement.
            if !storeProduct.hasEntitlement {
                updatePurchasedProducts(productId, purchased: false)
                return false
            }
        }
        
        // The user does have (or did have) an entitlement to this product, but do they have an entitlement to a subscription
        // product of higher-value in the same subscription group? We check this because the user may be subscribed
        // to one or more products in a subscription group at the same time. This is usually related to family sharing.
        // However, normally we're only interested in the most high-value product the user is subscribed to in a group.
        //
        // Important: Remember, the higher the value product, the LOWER the `Product.subscription.groupLevel` value.
        // The highest value product will have a `Product.subscription.groupLevel` value of 1.
        //
        // We'll now get an array of `Product.SubscriptionInfo.Status` (see `statusCollection` below). This array is empty
        // if the user has never subscribed to a product in this subscription group. If the user is subscribed to a product
        // the `statusCollection.count` should be at least 1. Also, note that even if the `Product.SubscriptionInfo.Status`
        // collection does NOT contain a particular product `Transaction.currentEntitlement(for:)` may still report
        // that the user has an entitlement. This can happen when upgrading or downgrading subscriptions. Because of this
        // we always need to search the `Product.SubscriptionInfo.Status` collection for a subscribed product with a
        // higher-value.
        
        guard let statusCollection = try? await storeProduct.product.subscription?.status, statusCollection.count > 0 else {
            updatePurchasedProducts(productId, purchased: false)
            return false
        }
        
        // See if we can find anything of higher value (lower `groupLevel`) than `storeProduct.groupLevel`
        
        for status in statusCollection {
            // If the user's not subscribed to this product then keep looking
            guard status.state == .subscribed else { continue }
            
            // Check the transaction verification
            let statusTransactionResult = checkVerificationResult(result: status.transaction)
            guard statusTransactionResult.verified else { continue }
            
            // Are we looking at the same product we're checking for a higher-value product? If so, ignore
            if statusTransactionResult.transaction.productID == storeProduct.id { continue }
            
            // Check the renewal info verification
            let renewalInfoResult = checkVerificationResult(result: status.renewalInfo)
            guard renewalInfoResult.verified else { continue }

            // Make sure this product is from the same subscription group as the product we're searching for
            guard let currentGroup = subscriptionGroup(for: renewalInfoResult.transaction.currentProductID),
                  currentGroup == storeProduct.group else { continue }
            
            // We've found a valid transaction for a product in the target subscription group.
            // Is its service level higher (lower `groupLevel`)than that of the product we're testing for entitlement?
            
            let currentServiceLevel = product(from: renewalInfoResult.transaction.currentProductID)?.subscription?.groupLevel ?? Int.max
            if currentServiceLevel < storeProduct.groupLevel {
                // We found a higher value active subscription. So the product we're testing for entitlement is flagged as "not subscribed"
                updatePurchasedProducts(productId, purchased: false)
                return false
            }
        }
    
        // We didn't find a higher value product, so the product we're testing for entitlement is flagged as "subscribed"
        updatePurchasedProducts(productId, purchased: true)
        return true
    }
    
    // MARK: - Private methods
        
    /// This is an infinite async sequence (loop). It will continue waiting for transactions until it is explicitly
    /// canceled by calling the Task.cancel() method. See `transactionListener`.
    /// - Returns: Returns a task for the transaction handling loop.
    private func handleTransactions() -> Task<Void, any Error> {
        return Task.detached { @MainActor [self] in
            for await verificationResult in Transaction.updates {
                
                // See if StoreKit validated the transaction
                let checkResult = self.checkVerificationResult(result: verificationResult)
                guard checkResult.verified else {
                    // StoreKit's attempts to validate the transaction failed
                    SKHelperLog.transaction(.transactionFailure, productId: checkResult.transaction.productID, transactionId: String(checkResult.transaction.id))
                    return
                }
                
                let transaction = checkResult.transaction  // The transaction was validated by StoreKit
                guard transaction.productType == .autoRenewable || transaction.productType == .nonConsumable else {
                    SKHelperLog.event("Product type \(transaction.productType.localizedDescription) is not supported.")
                    return
                }
                
                await transaction.finish()  // Finish the transaction for all cases, including access revoked, subscription expired, subscription upgraded and successful purchase
                
                if transaction.revocationDate != nil {
                    // The user's access to the product has been revoked by the App Store (e.g. a refund, etc.)
                    // See transaction.revocationReason for more details if required
                    SKHelperLog.transaction(.transactionRevoked, productId: transaction.productID, transactionId: String(transaction.id))
                    updatePurchasedProducts(transaction.productID, purchased: false)
                    return
                }
                
                if transaction.isUpgraded {
                    // Transaction superceeded by an active, higher-value subscription
                    SKHelperLog.transaction(.transactionUpgraded, productId: transaction.productID, transactionId: String(transaction.id))
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
                SKHelperLog.transaction(.transactionSuccess, productId: transaction.productID, transactionId: String(transaction.id))
                self.updatePurchasedProducts(transaction.productID, purchased: true)
            }
        }
    }
    
    /// Handles all purchase status change updates.
    /// - Returns: Returns a task for the subscription changes handling loop.
    private func handleSubscriptionChanges() -> Task<Void, any Error> {
        return Task { @MainActor [self] in
            for await status in Product.SubscriptionInfo.Status.updates {
                guard let renewalInfo = try? status.renewalInfo.payloadValue, let transaction = try? status.transaction.payloadValue else { return }
                
                await transaction.finish()  // Finish the transaction here because sometimes we don't get an update via `Transaction.updates`
                SKHelperLog.subscriptionChanged(productId: transaction.productID, transactionId: String(transaction.id), newSubscriptionStatus: status.state.localizedDescription)
                if let expired = renewalInfo.expirationReason, let expirationDate = transaction.expirationDate {
                    SKHelperLog.transaction(.transactionExpired, productId: transaction.productID, transactionId: String(transaction.id))
                    SKHelperLog.event("Subscription for \(transaction.productID) expired on \(expirationDate) because \(expired.localizedDescription).")
                }
                
                updatePurchasedProducts(transaction.productID, purchased: status.state == .subscribed)
            }
        }
    }
    
    /// Handles all purchase intents resulting from direct App Store purchases for promoted products.
    /// - Returns: Returns a task for the purchase intents handling loop.
    private func handlePurchaseIntents() -> Task<Void, any Error> {
        return Task { @MainActor [self] in
            for await purchaseIntent in PurchaseIntent.intents {
                do {
                    SKHelperLog.event(.purchaseIntentRecieved, productId: purchaseIntent.product.id)
                    let purchaseResult = try await purchase(purchaseIntent.product)  // Proceed with the normal product purchase flow
                    purchaseState = purchaseResult.purchaseState

                } catch { purchaseState = .failed }  // The purchase or validation failed
            }
        }
    }
    
    /// Check if StoreKit was able to automatically verify a transaction by inspecting the verification result.
    ///
    /// - Parameter result: The transaction VerificationResult to check.
    /// - Returns: Returns an `UnwrappedVerificationResult<T>` where `verified` is true if the transaction was
    /// successfully verified by StoreKit. When `verified` is false `verificationError` will be non-nil.
    private func checkVerificationResult<T>(result: VerificationResult<T>) -> UnwrappedVerificationResult<T> {
        
        switch result {
            case .unverified(let unverifiedTransaction, let error):
                // StoreKit failed to automatically validate the transaction
                return UnwrappedVerificationResult(transaction: unverifiedTransaction, verified: false, verificationError: error)
                
            case .verified(let verifiedTransaction):
                // StoreKit successfully automatically validated the transaction
                return UnwrappedVerificationResult(transaction: verifiedTransaction, verified: true, verificationError: nil)
        }
    }
    
    /// Update our list of purchased products.
    /// - Parameters:
    ///   - productId: The `ProductId` to insert/remove.
    ///   - insert: If true the `ProductId` is purchased.
    private func updatePurchasedProducts(_ productId: ProductId, purchased: Bool) {
        if let product = storeProduct(for: productId) {
            product.hasEntitlement = purchased
            savePurchasedProducts()
        }
    }
    
    /// Read the cache of purchased products from storage.
    /// - Returns: Returns the list of fallback product ids, or an empty collection if none is available.
    private func readPurchasedProducts() -> [ProductId] {
        if let purchaseProductIds = UserDefaults.standard.object(forKey: SKHelperConstants.PurchasedProductsKey) as? [ProductId] {
            return purchaseProductIds
        }
        
        return [ProductId]()
    }
    
    /// Saves the cache of purchased product ids. Ids saved will have at least one positive entitlement.
    private func savePurchasedProducts() {
        var purchaseProductIds = [ProductId]()
        
        products.forEach { product in
            if product.hasEntitlement { purchaseProductIds.append(product.id) }
        }
        
        UserDefaults.standard.set(purchaseProductIds, forKey: SKHelperConstants.PurchasedProductsKey)
    }
}

