import SwiftUI
import SKHelper

@main
struct SKHelperDemoApp: App {
    @State private var store = SKHelper()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
        }
    }
}
