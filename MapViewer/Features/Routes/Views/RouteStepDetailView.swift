//
//  RouteStepDetailView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Displays turn-by-turn instructions, advisory notices, and step distances for a calculated route.
public struct RouteStepDetailView: View {
    public let steps: [RouteStep]
    public let unitSystem: UnitSystem
    
    public init(steps: [RouteStep], unitSystem: UnitSystem) {
        self.steps = steps
        self.unitSystem = unitSystem
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Turn-by-Turn Steps")
                .font(.headline)
                .padding(.horizontal, 16)
                .padding(.top, 8)
            
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack(alignment: .top, spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.accentColor.opacity(0.12))
                            .frame(width: 28, height: 28)
                        
                        Text("\(index + 1)")
                            .font(.caption2.bold())
                            .foregroundColor(.accentColor)
                    }
                    
                    VStack(alignment: .leading, spacing: 3) {
                        Text(step.instructions)
                            .font(.body)
                            .foregroundColor(.primary)
                        
                        if let notice = step.notice, !notice.isEmpty {
                            Text(notice)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                        
                        if step.distance > 0 {
                            Text(UnitFormatter.shared.formatDistance(step.distance, system: unitSystem))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                if index < steps.count - 1 {
                    Divider().padding(.leading, 56)
                }
            }
        }
        .padding(.vertical, 8)
    }
}
