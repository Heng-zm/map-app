//
//  CustomPinAnnotationView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Modern visual marker for custom user pins on the MapKit canvas.
public struct CustomPinAnnotationView: View {
    public let pin: LocationPin
    public let isSelected: Bool
    public let onTap: () -> Void
    
    public init(pin: LocationPin, isSelected: Bool = false, onTap: @escaping () -> Void) {
        self.pin = pin
        self.isSelected = isSelected
        self.onTap = onTap
    }
    
    public var body: some View {
        Button(action: onTap) {
            VStack(spacing: 2) {
                // Pin head
                ZStack {
                    Circle()
                        .fill(Color(hex: pin.colorHex) ?? .red)
                        .frame(width: isSelected ? 38 : 30, height: isSelected ? 38 : 30)
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: pin.isFavorite ? "star.fill" : "mappin")
                        .font(.system(size: isSelected ? 16 : 14, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(
                    Circle()
                        .strokeBorder(Color.white, lineWidth: 2)
                )
                
                // Pin stem/triangle tip
                Image(systemName: "triangle.fill")
                    .font(.system(size: 8))
                    .foregroundColor(Color(hex: pin.colorHex) ?? .red)
                    .rotationEffect(.degrees(180))
                    .offset(y: -4)
                
                // Pin Title Label
                if isSelected {
                    Text(pin.title)
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.ultraThinMaterial, in: Capsule())
                        .overlay(
                            Capsule().strokeBorder(Color.primary.opacity(0.1), lineWidth: 0.5)
                        )
                        .shadow(radius: 2)
                        .offset(y: -2)
                }
            }
        }
        .buttonStyle(.plain)
        .accessibilityLabel(pin.title)
        .accessibilityHint(pin.isFavorite ? "Favorite custom pin. Tap to view details." : "Custom pin. Tap to view details.")
    }
}

// Color hex helper
extension Color {
    public init?(hex: String) {
        var cleanHex = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if cleanHex.hasPrefix("#") {
            cleanHex.removeFirst()
        }
        
        guard cleanHex.count == 6, let rgbValue = UInt64(cleanHex, radix: 16) else {
            return nil
        }
        
        let red = Double((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = Double((rgbValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgbValue & 0x0000FF) / 255.0
        
        self.init(red: red, green: green, blue: blue)
    }
}
