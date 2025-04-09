import SwiftUI
import SKHelper

struct ContentView: View {
    var body: some View {
        
        // SKHelperStoreView() lists all available products for this app.
        // Products that have been purchased will be grayed-out.
        // Tapping on the product's image results in SKHelper calling the
        // provided closure to show details for the product.
        
        SKHelperStoreView() { productId in
            // This closure is called when the user taps on the product's image to request
            // details on the product.
            VStack {
                Image("\(productId).info").resizable().scaledToFit()
                Text("Here is some text about why you might want to buy this product.")
            }
            .padding()
        }
    }
}
