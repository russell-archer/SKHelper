//
//  SKPurchaseInfoFieldText.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.6, *)
internal struct SKPurchaseInfoFieldText: View {
    let text: String
    
    var body: some View {
        #if os(iOS)
        Text(text).font(.footnote)
        #else
        Text(text).font(.title2)
        #endif
    }
}
