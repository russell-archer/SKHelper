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
                    SKHelperSubscriptionStoreView()
                }
            }
        }
    }
}
