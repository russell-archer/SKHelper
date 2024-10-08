//
//  SKHelperPurchaseInfoFieldView.swift
//  SKHelper
//
//  Created by Russell Archer on 22/08/2024.
//

import SwiftUI

/// Creates a view containing two horizontally-aligned `Text` views that take the form "field name" : "field value".
@available(iOS 17.0, macOS 14.6, *)
internal struct SKHelperPurchaseInfoFieldView: View {
    
    /// The name of the field.
    let fieldName: String
    
    /// The field's value.
    let fieldValue: String
    
    #if os(iOS)
    /// The width of field name.
    let width: CGFloat = 95
    #else
    /// The width of field name.
    let width: CGFloat = 140
    #endif
    
    /// Creates the body of the view.
    var body: some View {
        HStack {
            SKHelperPurchaseInfoFieldText(text: fieldName)
                .foregroundColor(.secondary)
                .frame(width: width, alignment: .leading)
                .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 5))
            
            SKHelperPurchaseInfoFieldText(text:fieldValue)
                .foregroundColor(.blue)
                .padding(EdgeInsets(top: 10, leading: 5, bottom: 0, trailing: 5))
            
            Spacer()
        }
    }
}

