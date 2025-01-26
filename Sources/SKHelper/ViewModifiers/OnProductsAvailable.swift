//
//  OnProductsAvailable.swift
//  SKHelper
//
//  Created by Russell Archer on 01/01/2025.
//

public import SwiftUI
public import StoreKit

/// The `OnProductsAvailable` ViewModifier allows you to be notified when SKHelper retrieves a collection of localized product information from the App Store.
/// See also the `onProductsAvailable(update:)` View extension.
public struct OnProductsAvailable: ViewModifier {
    /// The `SKHelper` object.
    @Environment(SKHelper.self) private var store
    
    /// Optional handler allows you to be notified of localized product information updates.
    private var update: ProductsAvailableClosure?
    
    /// Creates an `OnProductsAvailable` ViewModifier.
    /// - Parameter update: Optional handler allows you to be notified of localized product information updates.
    public init(update: ProductsAvailableClosure? = nil) { self.update = update }
    
    /// Builds the body of the `OnProductsAvailable` view modifier.
    /// - Parameter content: The View's content.
    /// - Returns: Returns the body of the `OnProductsAvailable` view modifier.
    public func body(content: Content) -> some View {
        content
            .onAppear {
                store.productsAvailable = { products in
                    update?(products)
                }
            }
    }
}

public extension View {
    
    /// View extension to provide a `OnProductsAvailable(update:)` modifier.
    /// ```
    /// // Example usage:
    /// VStack {
    ///     .onProductsAvailable { products  in
    ///         :
    ///     }
    /// }
    /// ```
    func onProductsAvailable(update: ProductsAvailableClosure? = nil) -> some View {
        modifier(OnProductsAvailable(update: update))
    }
}
