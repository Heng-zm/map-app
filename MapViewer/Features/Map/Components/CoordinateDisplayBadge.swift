//
//  CoordinateDisplayBadge.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Floating pill badge showing current map center coordinates with copy-to-clipboard functionality.
public struct CoordinateDisplayBadge: View {
    public let coordinate: CLLocationCoordinate2D
    public let format: CoordinateFormat
    
    @State private var showCopiedFeedback: Bool = false
    
    public init(coordinate: CLLocationCoordinate2D, format: CoordinateFormat) {
        self.coordinate = coordinate
        self.format = format
    }
    
    public var body: some View {
        Button(action: copyToClipboard) {
            HStack(spacing: 8) {
                Image(systemName: showCopiedFeedback ? "checkmark.circle.fill" : "scope")
                    .foregroundColor(showCopiedFeedback ? .green : .accentColor)
                    .font(.system(size: 13, weight: .semibold))
                
                Text(showCopiedFeedback ? "Coordinates Copied" : formattedCoordinate)
                    .font(.system(size: 12, weight: .medium, design: .monospaced))
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .glassBackground(cornerRadius: 20)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Map center coordinates: \(formattedCoordinate)")
        .accessibilityHint("Double tap to copy coordinates to clipboard.")
    }
    
    private var formattedCoordinate: String {
        CoordinateFormatter.shared.format(coordinate, format: format)
    }
    
    private func copyToClipboard() {
        let text = CoordinateFormatter.shared.formatRawDecimal(coordinate)
        UIPasteboard.general.string = text
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            showCopiedFeedback = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation(.easeInOut(duration: 0.3)) {
                self.showCopiedFeedback = false
            }
        }
    }
}
