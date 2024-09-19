import SwiftUI
import SKHelper

struct SmallFlowersView: View {
    @Environment(SKHelper.self) private var store
    @State private var isPurchased = false
    private let smallFlowersProductId = "com.rarcher.nonconsumable.flowers.small"
    
    var body: some View {
        VStack {
            if isPurchased { FullAccess() }
            else { NoAccess() }
        }
        .task { isPurchased = await store.isPurchased(productId: smallFlowersProductId) }
    }
    
    func FullAccess() -> some View {
        VStack {
            Text("🥰 🌹").font(.system(size: 100)).padding()
            Text("You've purchased the small flowers - here they are, enjoy!").padding()
            Image(smallFlowersProductId).resizable().scaledToFit()
        }
        .padding()
    }
    
    func NoAccess() -> some View {
        VStack {
            Text("😢").font(.system(size: 100)).padding()
            Text("You haven't purchased the small flowers and don't have access.").padding()
            ProductNavLink()
            Spacer()
        }
        .padding()
    }
    
    func ProductNavLink() -> some View {
        NavigationLink("Review Small Flowers Info") {
            SKHelperStoreView(productIds: [smallFlowersProductId]) { productId in
                Group {
                    Image(productId + ".info").resizable().scaledToFit()
                    Text("Here is some text about why you might want to buy this product.")
                }
                .padding()
            }
        }
    }
}
