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
                    SKHelperStoreView()
                }
            }
        }
    }
}
