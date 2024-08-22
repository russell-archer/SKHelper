//
//  SKButtons.swift
//  SKHelper
//
//  Created by Russell Archer on 19/08/2024.
//

import SwiftUI

@MainActor
public extension View {
    @ViewBuilder func SKButtonStyleBorderless() -> some View {
        #if os(iOS) || os(macOS) || os(visionOS)
        buttonStyle(.borderless)
        #else
        if #available(tvOS 17.0, *) {
            buttonStyle(.borderless)
        } else {
            buttonStyle(.plain)
        }
        #endif
    }
    
    func SKButtonStyleBorderedProminent(
        foregroundColor: Color = .white,
        backgroundColor: Color = .blue,
        pressedColor: Color = .secondary,
        padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) -> some View {
            
        #if os(iOS) || os(visionOS) || os(tvOS)
        buttonStyle(.borderedProminent)
        #else
        buttonStyle(
            SKmacOSButtonStyle(
                foregroundColor: foregroundColor,
                backgroundColor: backgroundColor,
                pressedColor: pressedColor,
                padding: padding
            )
        )
        #endif
    }
}

#if os(macOS)
@MainActor
public struct SKmacOSButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    var pressedColor: Color = .secondary
    var opacity: Double = 1
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    public init(foregroundColor: Color = .white,
                backgroundColor: Color = .blue,
                pressedColor: Color = .secondary,
                opacity: Double = 1,
                padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) {
        
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.pressedColor = pressedColor
        self.opacity = opacity
        self.padding = padding
    }
    
    public func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.title2)
            .padding(15)
            .foregroundColor(foregroundColor)
            .background(configuration.isPressed ? pressedColor : backgroundColor).opacity(opacity)
            .cornerRadius(5)
            .padding(padding)
    }
}

public extension View {
    @MainActor func SKmacOSStyle(foregroundColor: Color = .white, backgroundColor: Color = .blue, pressedColor: Color = .secondary, padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)) -> some View {
        self.buttonStyle(SKmacOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, padding: padding))
    }
    
    @MainActor func SKmacOSTransparentStyle(foregroundColor: Color = .blue, backgroundColor: Color = .white, pressedColor: Color = .secondary) -> some View {
        self.buttonStyle(SKmacOSButtonStyle(foregroundColor: foregroundColor, backgroundColor: backgroundColor, pressedColor: pressedColor, opacity: 0))
    }
}

public extension Button {
    @MainActor func SKmacOSRoundedStyle() -> some View {
        self
            .frame(width: 30, height: 30)
            .buttonStyle(.plain)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(Circle())
    }
}

public extension Text {
    @MainActor func SKmacOSNarrowButtonStyle() -> some View {
        self
            .frame(width: 100, height: 40)
            .buttonStyle(.plain)
            .foregroundColor(Color.white)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    @MainActor func SKmacOSNarrowButtonStyle(disabled: Bool = false) -> some View {
        self
            .frame(width: 100, height: 40)
            .buttonStyle(.plain)
            .foregroundColor(disabled ? Color.secondary : Color.white)
            .background(disabled ? Color.gray : Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
#endif

