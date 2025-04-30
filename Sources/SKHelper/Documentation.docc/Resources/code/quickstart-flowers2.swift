struct SmallFlowersView: View {
    var body: some View {
        if hasProducts {
            :
            
        } else {
            
            VStack {
                :
            }
            .onProductsAvailable { _ in
                hasProducts = store.hasProducts
                if hasProducts {
                    Task { isPurchased = await store.isPurchased(productId: smallFlowersProductId) }
                }
            }
        }
    }
}
