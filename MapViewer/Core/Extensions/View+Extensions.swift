//
//  View+Extensions.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

extension View {
    /// Applies an ultra-thin glassmorphic material background with subtle border and shadow.
    public func glassBackground(cornerRadius: CGFloat = 16) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.12), radius: 10, x: 0, y: 4)
    }
    
    /// Floating map control pill background.
    public func mapControlPill() -> some View {
        self
            .background(.regularMaterial, in: Circle())
            .overlay(
                Circle()
                    .strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.8)
            )
            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 3)
    }
}
