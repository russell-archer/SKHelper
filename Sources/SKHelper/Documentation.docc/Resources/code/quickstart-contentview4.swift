import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        VStack {
            SKHelperSubscriptionStoreView(
                subscriptionGroupName: "vip",
                subscriptionHeader: { header() },
                subscriptionControl: { productId in control(productId: productId) },
                subscriptionDetails: { productId in details(productId: productId) })
        }
    }
    
    func header() -> some View {
        VStack {
            Image("plant-services").resizable().scaledToFit()
            Text("Our top-rated services will make your plants happy").font(.headline)
        }
    }
    
    func control(productId: ProductId) -> some View {
        VStack {
            Image(productId).resizable().scaledToFit()
            Text("We'll water your plants \(productId == "com.rarcher.subscription.vip.gold" ? "weekly" : "monthly").").font(.callout)
        }
    }
    
    func details(productId: ProductId) -> some View {
        VStack {
            Image("\(productId).info").resizable().scaledToFit()
            Text("Here is some text about why you might want to buy this product.")
        }
        .padding()
    }
}
