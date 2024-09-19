import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        NavigationStack {
            List {
                :
                :
                
                // SKHelperSubscriptionStoreView() lists all subscription products for this app.
                // Trials, upgrades and downgrades are handled automatically.
                NavigationLink("List all subscriptions") {
                    SKHelperSubscriptionStoreView(
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
