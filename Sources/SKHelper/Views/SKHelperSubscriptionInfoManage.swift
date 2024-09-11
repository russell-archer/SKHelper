//
//  SKHelperSubscriptionInfoManage.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A composable view that allows the user to manage a subscription, including cancelling, upgrading or downgrading.
/// See `SKHelperManagePurchaseView`, which includes this view.
///
@available(iOS 17.0, macOS 14.6, *)
struct SKHelperSubscriptionInfoManage: View {
    
    /// A binding to a value that determines if the manage subscription sheet is displayed.
    @Binding var showManageSubscriptionsSheet: Bool
    
    /// Creates the body of the view.
    var body: some View {
        #if os(iOS)
        Divider().padding(.bottom)
        
        Button(action: {
            withAnimation { showManageSubscriptionsSheet.toggle()}
        }) {
            Label(title: { Text("Manage Subscription").padding()},
                  icon:  { Image(systemName: "creditcard.circle").resizable().scaledToFit().frame(height: 24)})
        }
        .SKHelperButtonStyleBorderedProminent()
        
        Text("Managing your subscription may require you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding()
        
        #endif
        
    }
}
