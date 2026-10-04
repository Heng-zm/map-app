//
//  MeasurementControlBar.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Floating bottom control bar when Map Viewer is in geodesic measurement mode.
public struct MeasurementControlBar: View {
    @Binding public var mode: MeasurementMode
    public let pointCount: Int
    public let primaryValue: String
    public let secondaryValue: String
    
    public let onUndo: () -> Void
    public let onClear: () -> Void
    public let onDone: () -> Void
    
    public init(
        mode: Binding<MeasurementMode>,
        pointCount: Int,
        primaryValue: String,
        secondaryValue: String,
        onUndo: @escaping () -> Void,
        onClear: @escaping () -> Void,
        onDone: @escaping () -> Void
    ) {
        self._mode = mode
        self.pointCount = pointCount
        self.primaryValue = primaryValue
        self.secondaryValue = secondaryValue
        self.onUndo = onUndo
        self.onClear = onClear
        self.onDone = onDone
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            // Mode Segmented Control
            Picker("Mode", selection: $mode) {
                ForEach(MeasurementMode.allCases) { m in
                    Label(m.displayName, systemImage: m.iconName).tag(m)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 4)
            
            // Value display & actions
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(pointCount >= 2 ? primaryValue : "Tap map to add points")
                        .font(.headline.bold())
                        .foregroundColor(pointCount >= 2 ? .primary : .secondary)
                    
                    if pointCount >= 2 {
                        Text(secondaryValue)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // Undo Button
                Button(action: onUndo) {
                    Image(systemName: "arrow.uturn.backward")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.primary)
                        .frame(width: 36, height: 36)
                        .background(Color.primary.opacity(0.08), in: Circle())
                }
                .disabled(pointCount == 0)
                .accessibilityLabel("Undo last measurement point")
                
                // Clear Button
                Button(action: onClear) {
                    Image(systemName: "trash")
                        .font(.system(size: 15, weight: .semibold))
                        .foregroundColor(.red)
                        .frame(width: 36, height: 36)
                        .background(Color.red.opacity(0.12), in: Circle())
                }
                .disabled(pointCount == 0)
                .accessibilityLabel("Clear all measurement points")
                
                // Done Button
                Button(action: onDone) {
                    Text("Done")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(Color.accentColor, in: Capsule())
                }
                .accessibilityLabel("Exit measurement mode")
            }
        }
        .padding(14)
        .glassBackground(cornerRadius: 18)
    }
}
