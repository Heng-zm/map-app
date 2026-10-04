//
//  LocationCardRow.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Row view displaying a saved place with category tag, address, and favorite indicator.
public struct LocationCardRow: View {
    public let location: SavedLocation
    public let userCoordinate: CLLocationCoordinate2D?
    public let unitSystem: UnitSystem
    public let onToggleFavorite: () -> Void
    
    public init(
        location: SavedLocation,
        userCoordinate: CLLocationCoordinate2D?,
        unitSystem: UnitSystem,
        onToggleFavorite: @escaping () -> Void
    ) {
        self.location = location
        self.userCoordinate = userCoordinate
        self.unitSystem = unitSystem
        self.onToggleFavorite = onToggleFavorite
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.12))
                    .frame(width: 44, height: 44)
                
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.accentColor)
                    .font(.system(size: 20))
            }
            
            // Text info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(location.name)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    if location.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .font(.caption)
                    }
                }
                
                if let address = location.address, !address.isEmpty {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }
                
                HStack(spacing: 8) {
                    if let cat = location.category, !cat.isEmpty {
                        Text(cat)
                            .font(.caption2.bold())
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.secondary.opacity(0.12), in: Capsule())
                            .foregroundColor(.secondary)
                    }
                    
                    if let userCoord = userCoordinate {
                        let distance = location.coordinate.distance(to: userCoord)
                        Text(UnitFormatter.shared.formatDistance(distance, system: unitSystem))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            Button(action: onToggleFavorite) {
                Image(systemName: location.isFavorite ? "star.fill" : "star")
                    .foregroundColor(location.isFavorite ? .yellow : .secondary)
                    .font(.system(size: 18))
                    .padding(8)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(location.isFavorite ? "Remove favorite" : "Mark as favorite")
        }
        .padding(.vertical, 4)
    }
}
