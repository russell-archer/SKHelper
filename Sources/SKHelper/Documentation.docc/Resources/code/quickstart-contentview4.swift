//
//  ContentView.swift
//  SKHelperDemo
//

import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        NavigationStack {
            List {
                // SKHelperStoreView() lists all available products for this app.
                // Products that have been purchased will be grayed-out.
                // Tapping on the product's image shows details for the product.
                NavigationLink("List all products") {
                    SKHelperStoreView() { productId in
                        // Add more content to a product's description by placing it in this closure
                        Group {
                            Image(productId)
                                .resizable()
                                .scaledToFit()
                            Text("Here is some text about why you might want to buy this product.")
                        }
                        .padding()
                    }
                }
                
                // SKHelperSubscriptionStoreView() lists all subscription products for this app.
                // Trials, upgrades and downgrades are handled automatically.
                NavigationLink("Lists all subscription") {
                    SKHelperSubscriptionStoreView()
                }
                
                // SKHelperPurchasesView() lists all products that have been purchased,
                // including subscriptions. Details of the purchase or subscription are shown when
                // the "Manage Purchase" button is tapped.
                NavigationLink("List all purchases") {
                    SKHelperPurchasesView()
                }
            }
        }
    }
}
