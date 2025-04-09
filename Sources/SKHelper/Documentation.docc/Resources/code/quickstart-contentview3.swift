import SwiftUI
import SKHelper

struct ContentView: View {
    var body: some View {
        
        // SKHelperSubscriptionStoreView() lists all available subscription
        // products for this app. Subscriptions that have been purchased will
        // be grayed-out. Tapping on the subscription's image results in
        // SKHelper calling the provided closure to show details for the
        // subscription.
        
        SKHelperSubscriptionStoreView() { productId in
            // This closure is called when the user taps on the product's image
            // to request details on the subscription.
            VStack {
                Image("\(productId).info").resizable().scaledToFit()
                Text("Here is some text about why you might want to subscribe to this product.")
            }
            .padding()
        }
    }
}
