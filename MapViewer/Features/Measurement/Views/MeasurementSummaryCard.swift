//
//  MeasurementSummaryCard.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Detailed card breaking down individual segment distances and polygon coordinates.
public struct MeasurementSummaryCard: View {
    public let result: MeasurementResult
    public let mode: MeasurementMode
    public let unitSystem: UnitSystem
    
    public init(result: MeasurementResult, mode: MeasurementMode, unitSystem: UnitSystem) {
        self.result = result
        self.mode = mode
        self.unitSystem = unitSystem
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Measurement Breakdown")
                .font(.headline)
            
            if mode == .distance {
                HStack {
                    Text("Total Path Distance:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(UnitFormatter.shared.formatDistance(result.totalDistance, system: unitSystem))
                        .font(.headline.bold())
                }
                
                if !result.segmentDistances.isEmpty {
                    Divider()
                    Text("Individual Segments")
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    
                    ForEach(Array(result.segmentDistances.enumerated()), id: \.offset) { index, dist in
                        HStack {
                            Text("Segment \(index + 1) → \(index + 2)")
                                .font(.caption)
                                .foregroundColor(.primary)
                            Spacer()
                            Text(UnitFormatter.shared.formatDistance(dist, system: unitSystem))
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                    }
                }
            } else {
                HStack {
                    Text("Polygon Area:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(UnitFormatter.shared.formatArea(result.polygonArea, system: unitSystem))
                        .font(.headline.bold())
                }
                
                HStack {
                    Text("Total Perimeter:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(UnitFormatter.shared.formatDistance(result.perimeter, system: unitSystem))
                        .font(.subheadline.bold())
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14))
    }
}
