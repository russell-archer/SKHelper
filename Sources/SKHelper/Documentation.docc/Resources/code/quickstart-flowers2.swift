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
    
    :
    :
}
