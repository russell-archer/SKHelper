import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        VStack {
            SKHelperSubscriptionStoreView(
                subscriptionGroupName: "vip",
                subscriptionHeader: { header() },
                subscriptionDetails: { productId in details(productId: productId) })
        }
    }
    
    func header() -> some View {
        VStack {
            Image("plant-services").resizable().scaledToFit()
            Text("Our top-rated services will make your plants happy").font(.headline)
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
