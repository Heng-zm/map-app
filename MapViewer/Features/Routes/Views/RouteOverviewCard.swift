//
//  RouteOverviewCard.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Floating card displayed above the map when a route overlay is active.
public struct RouteOverviewCard: View {
    public let route: RouteInfo
    public let unitSystem: UnitSystem
    public let onOpenSteps: () -> Void
    public let onClearRoute: () -> Void
    
    public init(
        route: RouteInfo,
        unitSystem: UnitSystem,
        onOpenSteps: @escaping () -> Void,
        onClearRoute: @escaping () -> Void
    ) {
        self.route = route
        self.unitSystem = unitSystem
        self.onOpenSteps = onOpenSteps
        self.onClearRoute = onClearRoute
    }
    
    public var body: some View {
        HStack(spacing: 14) {
            Image(systemName: route.transportType.iconName)
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 44, height: 44)
                .background(Color.blue, in: Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(route.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(UnitFormatter.shared.formatDuration(route.expectedTravelTime))
                        .font(.subheadline.bold())
                        .foregroundColor(.green)
                    
                    Text("•")
                        .foregroundColor(.secondary)
                    
                    Text(UnitFormatter.shared.formatDistance(route.distance, system: unitSystem))
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            Button(action: onOpenSteps) {
                Image(systemName: "list.bullet")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.primary)
                    .frame(width: 36, height: 36)
                    .background(Color.primary.opacity(0.08), in: Circle())
            }
            .accessibilityLabel("View turn-by-turn steps")
            
            Button(action: onClearRoute) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.secondary)
                    .frame(width: 32, height: 32)
                    .background(Color.secondary.opacity(0.12), in: Circle())
            }
            .accessibilityLabel("Clear route from map")
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .glassBackground(cornerRadius: 18)
        .padding(.horizontal, 16)
    }
}
