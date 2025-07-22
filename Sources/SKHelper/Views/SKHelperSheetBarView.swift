//
//  SKHelperSheetBarView.swift
//  SKHelper
//
//  Created by Russell Archer on 15/08/2024.
//

import SwiftUI

/// An iOS-specific view that forms a "title bar", with a title and a close button at the top of a sheet.
#if os(iOS)
@available(iOS 17.0, *)
public struct SKHelperSheetBarView: View {
    
    /// A values that determines if the close button is displayed.
    @State private var showXmark = false
    
    /// A binding to a value that determines if the sheet on which this `SKHelperSheetBarView` sits is displayed.
    @Binding var showSheet: Bool
    
    /// The title to be displayed on the bar.
    private let title: String?
    
    /// The image to be displayed on the bar.
    private let sysImg: String?
    
    /// The padding used by the bar title.
    private let insetsTitle = EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)
    
    /// Creates the view that forms a "title bar", with a title and a close button at the top of a sheet.
    ///
    /// - Parameters:
    ///   - showSheet: A binding to a value that determines if the sheet is displayed.
    ///   - title: The title displayed on the bar.
    ///   - sysImage: The image displayed on the bar.
    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    /// Creates the body view.
    public var body: some View {
        var trailingInset: CGFloat
        
        if #available(iOS 26, *) { trailingInset = 20 }
        else { trailingInset = 10 }
        
        return HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle)}
                else if let t = title { Text(t).padding(insetsTitle)}
                
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                        .SKHelperOnTapGesture { withAnimation { showSheet.toggle() }
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: trailingInset))
    }
}
#endif

/// A macOS-specific view that forms a "title bar" with a title and a close button at the top of a sheet.
#if os(macOS)
@available(macOS 12.0, *)
public struct SKHelperSheetBarView: View {
    /// A values that determines if the close button is displayed.
    @State private var showXmark = false
    
    /// A binding to a value that determines if the sheet on which this `SKHelperSheetBarView` sits is displayed.
    @Binding var showSheet: Bool
    
    /// The title to be displayed on the bar.
    private let title: String?
    
    /// The image to be displayed on the bar.
    private let sysImg: String?
    
    /// The padding used by the bar.
    private var insets = EdgeInsets(top: 13, leading: 20, bottom: 5, trailing: 0)
    
    /// The padding used by the bar title.
    private var insetsTitle = EdgeInsets(top: 13, leading: 0, bottom: 5, trailing: 0)
    
    /// Creates the view that forms a "title bar", with a title and a close button at the top of a sheet.
    ///
    /// - Parameters:
    ///   - showSheet: A binding to a value that determines if the sheet is displayed.
    ///   - title: The title displayed on the bar.
    ///   - sysImage: The image displayed on the bar.
    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    /// Creates the body view.
    public var body: some View {
        var trailingInset: CGFloat
        
        if #available(macOs 26, *) { trailingInset = 20 }
        else { trailingInset = 10 }
        
        return HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle).font(.title)}
                else if let t = title { Text(t).font(.title).padding(insetsTitle)}
                
                HStack {
                    ZStack {
                        Image(systemName: "circle.fill")
                            .resizable()
                            .frame(width: 13, height: 13)
                            .foregroundColor(.red)
                            .padding(insets)
                            .onHover { action in showXmark = action }
                        
                        if showXmark { Image(systemName: "xmark")
                                .resizable()
                                .frame(width: 5, height: 5)
                                .foregroundColor(.black)
                            .padding(insets)}
                    }
                    .SKHelperOnTapGesture { withAnimation { showSheet.toggle() }}
                    Spacer()
                }
            }
        }
        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: trailingInset))
        Divider()
    }
}
#endif

#Preview {
    SKHelperSheetBarView(showSheet: Binding.constant(true), title: "Test", sysImage: "face.smiling")
}
