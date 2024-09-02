//
//  SKPurchaseInfoFieldText.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// A view that creates a cross-pltform `Text` view with a font suitable for that platform.
@available(iOS 17.0, macOS 14.6, *)
internal struct SKPurchaseInfoFieldText: View {
    
    /// The text to be displayed in the field.
    let text: String
    
    /// Creates the body of the view.
    var body: some View {
        #if os(iOS)
        Text(text).font(.footnote)
        #else
        Text(text).font(.title2)
        #endif
    }
}
