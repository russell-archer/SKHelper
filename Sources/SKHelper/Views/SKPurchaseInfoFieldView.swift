//
//  SKPurchaseInfoFieldView.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

@available(iOS 17.0, macOS 14.6, *)
internal struct SKPurchaseInfoFieldView: View {
    let fieldName: String
    let fieldValue: String
    
    #if os(iOS)
    let width: CGFloat = 95
    #else
    let width: CGFloat = 140
    #endif
    
    var body: some View {
        HStack {
            SKPurchaseInfoFieldText(text: fieldName).foregroundColor(.secondary).frame(width: width, alignment: .leading).padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 5))
            SKPurchaseInfoFieldText(text:fieldValue).foregroundColor(.blue).padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
            Spacer()
        }
    }
}
