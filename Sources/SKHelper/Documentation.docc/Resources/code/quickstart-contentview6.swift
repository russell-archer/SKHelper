import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        NavigationStack {
            List {
                :
                :
                
                // Show the small flowers purchase-related view
                NavigationLink("Access Small Flowers") {
                    SmallFlowersView()
                }
            }
        }
    }
}
