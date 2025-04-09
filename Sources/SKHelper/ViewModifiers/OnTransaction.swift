//
//  OnTransaction.swift
//  SKHelper
//
//  Created by Russell Archer on 28/10/2024.
//

public import SwiftUI

/// The `OnTransaction` ViewModifier allows you to be notified of purchase transactions and other transaction updates.
/// See also the `onTransaction(update:)` View extension.
public struct OnTransaction: ViewModifier {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Optional handler allows you to be notified of purchase transactions and transaction updates.
    private var update: TransactionUpdateClosure?
    
    /// Creates an `OnTransaction` ViewModifier.
    /// - Parameter update: Optional handler allows you to be notified of purchase transactions and transaction updates.
    public init(update: TransactionUpdateClosure? = nil) { self.update = update }
    
    /// Builds the body of the `OnTransaction` view modifier.
    /// - Parameter content: The View's content.
    /// - Returns: Returns the body of the `OnTransaction` view modifier.
    public func body(content: Content) -> some View {
        content
            .onAppear {
                store.transactionUpdateListener = { productId, reason, transaction in
                    update?(productId, reason, transaction)
                }
            }
    }
}

public extension View {
    
    /// View extension to provide a `OnTransactionUpdate(update:)` modifier.
    /// ```
    /// // Example usage:
    /// SKHelperStoreView()
    ///     .onTransaction { productId, reason, transaction  in
    ///         :
    ///     }
    /// ```
    func onTransaction(update: TransactionUpdateClosure? = nil) -> some View {
        modifier(OnTransaction(update: update))
    }
}
