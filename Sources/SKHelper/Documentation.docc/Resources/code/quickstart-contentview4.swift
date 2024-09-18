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
                        Group {
                            Image(productId + ".info").resizable().scaledToFit()
                            Text("Here is some text about why you might want to buy this product.")
                        }
                        .padding()
                    }
                }
                
                // SKHelperSubscriptionStoreView() lists all subscription products for this app.
                // Trials, upgrades and downgrades are handled automatically.
                NavigationLink("List all subscriptions") {
                    SKHelperSubscriptionStoreView(
                        subscriptionGroupName: "vip",
                        subscriptionHeader: {
                            VStack {
                                Image("plant-services").resizable().scaledToFit()
                                Text("Services to make your plants happy!").font(.headline)
                            }
                        },
                        subscriptionControl: { productId in
                            VStack {
                                Image(productId).resizable().scaledToFit()
                                Text("We'll visit \(productId == "com.rarcher.subscription.vip.gold" ? "weekly" : "monthly") to water your plants.").font(.caption2)
                            }
                        },
                        subscriptionDetails: { productId in
                            VStack {
                                Image(productId + ".info").resizable().scaledToFit()
                                Text("Here is some text about why you might want to buy this product.")
                            }
                        })
                }
            }
        }
    }
}
