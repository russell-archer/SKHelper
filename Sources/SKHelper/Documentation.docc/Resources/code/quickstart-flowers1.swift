import SwiftUI
import StoreKit
import SKHelper

struct SmallFlowersView: View {
    @Environment(SKHelper.self) private var store
    @State private var hasProducts = false
    @State private var isPurchased = false
    @State private var product: Product?
    private let smallFlowersProductId = "com.rarcher.nonconsumable.flowers.small"
    
    var body: some View {
        if hasProducts {
            if isPurchased { FullAccess() }
            else { NoAccess() }
            
        } else {
            
            VStack {
                Text("No products available").font(.subheadline).padding()
                Button("Refresh Products") { Task { await store.requestProducts() }}
                ProgressView()
            }
            .padding()
            .onProductsAvailable { _  in
                hasProducts = store.hasProducts
                if hasProducts {
                    Task { isPurchased = await store.isPurchased(productId: smallFlowersProductId) }
                }
            }
        }
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
            
            if let product {
                Button("Purchase Small Flowers for \(product.displayPrice)") {
                    Task {
                        let result = await store.purchase(product)
                        if result.purchaseState == .purchased { isPurchased = true }
                    }
                }
                .tint(.blue)
            }
        }
        .padding()
        .task { product = store.product(from: smallFlowersProductId) }
    }
}
