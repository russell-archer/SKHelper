//
//  SKButtons.swift
//  SKHelper
//
//  Created by Russell Archer on 19/08/2024.
//

import SwiftUI

/// Cross-platform button styles.
@MainActor
public extension View {
    
    /// Creates a borderless button style.
    ///
    /// - Returns: Returns a cross-platform borderless button style.
    ///
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
    
    /// Creates a prominent button style.
    ///
    /// - Parameters:
    ///   - foregroundColor: The button foreground.
    ///   - backgroundColor: The button background.
    ///   - pressedColor: The pressed color.
    ///   - padding: Button padding.
    /// - Returns: Returns a cross-platform prominent button style.
    ///
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
/// macOS button styles.
@MainActor
public struct SKmacOSButtonStyle: ButtonStyle {
    var foregroundColor: Color = .white
    var backgroundColor: Color = .blue
    var pressedColor: Color = .secondary
    var opacity: Double = 1
    var padding: EdgeInsets = EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10)
    
    /// Creates a custom macOS button style.
    ///
    /// - Parameters:
    ///   - foregroundColor: The button foreground.
    ///   - backgroundColor: The button background.
    ///   - pressedColor: The pressed color.
    ///   - opacity: The button opacity.
    ///   - padding: Button padding.
    ///
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
    
    /// Create the body of the macOS button style.
    /// 
    /// - Parameter configuration: The button configuration.
    /// - Returns: Returns the custom button.
    /// 
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

#endif

