//
//  SKSheetBarView.swift
//  SKHelper
//
//  Created by Russell Archer on 15/08/2024.
//

import SwiftUI

#if os(iOS)
@available(iOS 17.0, *)
public struct SKSheetBarView: View {
    @State private var showXmark = false
    @Binding var showSheet: Bool
    private let title: String?
    private let sysImg: String?
    private let insetsTitle = EdgeInsets(top: 10, leading: 0, bottom: 0, trailing: 0)

    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    public var body: some View {
        HStack {
            ZStack {
                if let img = sysImg { Label(title ?? "", systemImage: img).padding(insetsTitle)}
                else if let t = title { Text(t).padding(insetsTitle)}
                
                HStack {
                    Spacer()
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.secondary)
                        .padding(EdgeInsets(top: 10, leading: 10, bottom: 0, trailing: 10))
                        .onTapGesture { withAnimation { showSheet.toggle() }}
                }
            }
        }
        Divider()
        Spacer()
    }
}
#endif

#if os(macOS)
@available(macOS 12.0, *)
public struct SKSheetBarView: View {
    @State private var showXmark = false
    @Binding var showSheet: Bool
    var title: String?
    var sysImg: String?
    
    private var insets = EdgeInsets(top: 13, leading: 20, bottom: 5, trailing: 0)
    private var insetsTitle = EdgeInsets(top: 13, leading: 0, bottom: 5, trailing: 0)
    
    public init(showSheet: Binding<Bool>, title: String? = nil, sysImage: String? = nil) {
        self._showSheet = showSheet
        self.title = title
        self.sysImg = sysImage
    }
    
    public var body: some View {
        HStack {
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
                    .SKOnTapGesture { withAnimation { showSheet.toggle() }}
                    Spacer()
                }
            }
        }
        Divider()
    }
}
#endif

#Preview {
    SKSheetBarView(showSheet: Binding.constant(true), title: "Test", sysImage: "face.smiling")
}
