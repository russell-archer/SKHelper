//
//  SKHelperTapGesture.swift
//  SKHelper
//
//  Created by hengyu on 2024/3/30.
//

import SwiftUI

/// View extension for cross-platform tap gesture.
public extension View {
    
    /// Cross-platform tap gesture.
    /// 
    /// - Parameter perform: The action to perform.
    /// - Returns: Returns a suitable tap gesture for the current platform.
    ///
    @ViewBuilder func SKHelperOnTapGesture(perform: @escaping () -> Void) -> some View {
        #if os(tvOS)
        if #available(tvOS 16.0, *) { onTapGesture(perform: perform) }
        else { onLongPressGesture(minimumDuration: 0.2, perform: perform) }
        #else
        onTapGesture(perform: perform)
        #endif
    }
}
