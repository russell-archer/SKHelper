//
//  SKSubscriptionInfoManage.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

struct SKSubscriptionInfoManage: View {
    @Binding var showManageSubscriptionsSheet: Bool
    
    var body: some View {
        #if os(iOS)
        Divider().padding(.bottom)
        
        Button(action: {
            withAnimation { showManageSubscriptionsSheet.toggle()}
        }) {
            Label(title: { Text("Manage Subscription").padding()},
                  icon:  { Image(systemName: "creditcard.circle").resizable().scaledToFit().frame(height: 24)})
        }
        .SKButtonStyleBorderedProminent()
        
        Text("Managing your subscription may require you to authenticate with the App Store. Note that this app does not have access to credentials used to sign-in to the App Store.")
            .font(.caption)
            .multilineTextAlignment(.center)
            .foregroundColor(.secondary)
            .padding()
        
        #endif
        
    }
}
