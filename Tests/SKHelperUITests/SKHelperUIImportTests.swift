//
//  SKHelperUIImportTests.swift
//  SKHelper
//
//  Created by Russell Archer on 14/07/2024.
//

import SwiftUI
import Testing
import SKHelperUI

@MainActor
@Test func uiTypesAreAvailableThroughSKHelperUI() {
    let selectedProductId = Binding.constant(ProductId("com.example.product"))
    let isProductInfoPresented = Binding.constant(false)

    let productView = SKHelperProductView(
        selectedProductId: selectedProductId,
        showProductInfoSheet: isProductInfoPresented
    ) { productId in
        Text(productId)
    }

    let transactionModifier = OnTransaction()
    let productsAvailableModifier = OnProductsAvailable()
    let subscriptionChangeModifier = OnSubscriptionChange()

    _ = productView
    _ = transactionModifier
    _ = productsAvailableModifier
    _ = subscriptionChangeModifier
}
