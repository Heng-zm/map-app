//
//  FloatingMapControls.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Floating glassmorphic button controls overlaid on the MapKit canvas.
public struct FloatingMapControls: View {
    public let is3D: Bool
    public let isTrafficEnabled: Bool
    public let isMeasuring: Bool
    public let hasActiveRoute: Bool
    
    public let onLocateMe: () -> Void
    public let onZoomIn: () -> Void
    public let onZoomOut: () -> Void
    public let onToggle3D: () -> Void
    public let onToggleTraffic: () -> Void
    public let onOpenStylePicker: () -> Void
    public let onToggleMeasure: () -> Void
    public let onOpenRoutes: () -> Void
    public let onOpenSaved: () -> Void
    public let onOpenSettings: () -> Void
    
    public init(
        is3D: Bool,
        isTrafficEnabled: Bool,
        isMeasuring: Bool,
        hasActiveRoute: Bool,
        onLocateMe: @escaping () -> Void,
        onZoomIn: @escaping () -> Void,
        onZoomOut: @escaping () -> Void,
        onToggle3D: @escaping () -> Void,
        onToggleTraffic: @escaping () -> Void,
        onOpenStylePicker: @escaping () -> Void,
        onToggleMeasure: @escaping () -> Void,
        onOpenRoutes: @escaping () -> Void,
        onOpenSaved: @escaping () -> Void,
        onOpenSettings: @escaping () -> Void
    ) {
        self.is3D = is3D
        self.isTrafficEnabled = isTrafficEnabled
        self.isMeasuring = isMeasuring
        self.hasActiveRoute = hasActiveRoute
        self.onLocateMe = onLocateMe
        self.onZoomIn = onZoomIn
        self.onZoomOut = onZoomOut
        self.onToggle3D = onToggle3D
        self.onToggleTraffic = onToggleTraffic
        self.onOpenStylePicker = onOpenStylePicker
        self.onToggleMeasure = onToggleMeasure
        self.onOpenRoutes = onOpenRoutes
        self.onOpenSaved = onOpenSaved
        self.onOpenSettings = onOpenSettings
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 8) {
                // Layer & Perspective Controls Group
                VStack(spacing: 1) {
                    mapControlButton(
                        icon: "square.2.layers.3d",
                        title: "Map Style",
                        hint: "Change between standard, satellite, and hybrid map styles.",
                        action: onOpenStylePicker
                    )
                    
                    Divider().frame(width: 32)
                    
                    mapControlButton(
                        icon: is3D ? "view.2d" : "view.3d",
                        title: is3D ? "Switch to 2D" : "Switch to 3D",
                        hint: "Toggle between flat 2D perspective and tilted 3D realistic terrain.",
                        isActive: is3D,
                        action: onToggle3D
                    )
                    
                    Divider().frame(width: 32)
                    
                    mapControlButton(
                        icon: "car.2.fill",
                        title: "Traffic",
                        hint: "Toggle real-time traffic conditions overlay.",
                        isActive: isTrafficEnabled,
                        activeColor: .orange,
                        action: onToggleTraffic
                    )
                }
                .glassBackground(cornerRadius: 14)
                
                // Location & Directions Group
                VStack(spacing: 1) {
                    mapControlButton(
                        icon: "location.fill",
                        title: "Locate Me",
                        hint: "Centers the map on your current GPS position.",
                        action: onLocateMe
                    )
                    
                    Divider().frame(width: 32)
                    
                    mapControlButton(
                        icon: "arrow.triangle.turn.up.right.diamond.fill",
                        title: "Directions",
                        hint: "Plan driving, walking, or transit routes.",
                        isActive: hasActiveRoute,
                        activeColor: .blue,
                        action: onOpenRoutes
                    )
                }
                .glassBackground(cornerRadius: 14)
                
                // Measurement Tool Button
                mapControlButton(
                    icon: "ruler.fill",
                    title: "Measure",
                    hint: "Activate geodesic distance and polygon area measurement mode.",
                    isActive: isMeasuring,
                    activeColor: .indigo,
                    action: onToggleMeasure
                )
                .mapControlPill()
                
                // Zoom Controls Group
                VStack(spacing: 1) {
                    mapControlButton(
                        icon: "plus",
                        title: "Zoom In",
                        hint: "Magnifies the map closer.",
                        action: onZoomIn
                    )
                    
                    Divider().frame(width: 32)
                    
                    mapControlButton(
                        icon: "minus",
                        title: "Zoom Out",
                        hint: "Zooms out to view a broader area.",
                        action: onZoomOut
                    )
                }
                .glassBackground(cornerRadius: 14)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 2)
        }
        .frame(maxHeight: 380)
        .fixedSize(horizontal: true, vertical: false)
    }
    
    private func mapControlButton(
        icon: String,
        title: String,
        hint: String,
        isActive: Bool = false,
        activeColor: Color = .accentColor,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isActive ? activeColor : .primary)
                .frame(width: 44, height: 44)
                .contentShape(Rectangle())
        }
        .accessibilityLabel(title)
        .accessibilityHint(hint)
    }
}
