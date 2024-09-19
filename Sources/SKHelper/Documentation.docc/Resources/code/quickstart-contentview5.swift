import SwiftUI
import SKHelper

struct ContentView: View {
    @Environment(SKHelper.self) private var store
    
    var body: some View {
        NavigationStack {
            List {
                :
                :
                
                // Show all purchases the user has made.
                NavigationLink("List all purchases") {
                    SKHelperPurchasesView()
                }
            }
        }
    }
}
