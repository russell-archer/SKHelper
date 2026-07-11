//
//  SKHelperCoreImportTests.swift
//  SKHelper
//
//  Created by Russell Archer on 14/07/2024.
//

import Testing
import SKHelperCore

@Test func coreTypesAreAvailableWithoutSwiftUI() {
    let productId: ProductId = "com.example.product"
    let transactionId: TransactionId = "1000000000"
    let purchaseState: SKHelperPurchaseState = .unknown
    let productsAvailable: ProductsAvailableClosure = { products in
        #expect(products.isEmpty)
    }

    productsAvailable([])

    #expect(productId == "com.example.product")
    #expect(transactionId == "1000000000")
    #expect(purchaseState.shortDescription() == "Purchase status unknown")
    #expect(SKHelperConstants.StoreConfiguration == "Products")
}
