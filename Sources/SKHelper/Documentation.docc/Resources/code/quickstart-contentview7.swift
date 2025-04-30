import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    @State private var hasProducts = false
    @State private var nonConsumables: [ProductId]? = nil
    
    var body: some View {
        
        VStack {
            if hasProducts {
                SKHelperStoreView(allowManagement: true, productIds: nonConsumables) { productId in
                    VStack {
                        Image("\(productId).info").resizable().scaledToFit()
                        Text("Here is some text about why you might want to buy this product.")
                    }
                    .padding()
                }
            } else {
                Text("Waiting for product info...")
            }
        }
        .onProductsAvailable { _ in
            nonConsumables = store.allNonConsumableProductIds
            hasProducts = true
        }
    }
}
