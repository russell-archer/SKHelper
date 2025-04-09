//
//  OnSubscriptionChange.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

public import SwiftUI

/// The `OnSubscriptionChange` ViewModifier allows you to be notified of changes to the status of all subscriptions.
/// See also the `onSubscriptionChange(onChange:)` View extension.
public struct OnSubscriptionChange: ViewModifier {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Optional handler allows you to be notified of changes to the status of all subscriptions.
    private var onChange: SubscriptionStatusChangeClosure?
    
    /// Creates an `OnSubscriptionChange` ViewModifier.
    /// - Parameter onChange: Optional handler allows you to be notified of changes to the status of all subscriptions.
    public init(onChange: SubscriptionStatusChangeClosure? = nil) { self.onChange = onChange }
    
    /// Builds the body of the `OnSubscriptionChange` view modifier.
    /// - Parameter content: The View's content.
    /// - Returns: Returns the body of the `OnSubscriptionChange` view modifier.
    public func body(content: Content) -> some View {
        content
            .onAppear {
                store.subscriptionStatusChange = { productId, transactionId, renewalState, hasExpired in
                    let newState = renewalState.localizedDescription.lowercased(with: Locale.current)
                    print("Subscription \(productId) now \"\(newState)\" with transaction id \(transactionId). The subscription has \(hasExpired ? "expired" : "not expired").")
                    
                    onChange?(productId, transactionId, renewalState, hasExpired)
                }
            }
    }
}

public extension View {
    
    /// View extension to provide a `onSubscriptionChange(onChange:)` modifier.
    /// ```
    /// // Example usage:
    /// SKHelperSubscriptionStoreView()
    ///     .onSubscriptionChange() { productId, transactionId, renewalState, hasExpired  in
    ///         print("The status of subscription \(productId) changed to \(renewalState.localizedDescription)")
    ///     }
    /// ```
    func onSubscriptionChange(onChange: SubscriptionStatusChangeClosure? = nil) -> some View {
        modifier(OnSubscriptionChange(onChange: onChange))
    }
}
