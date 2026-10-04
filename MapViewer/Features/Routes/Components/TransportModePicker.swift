//
//  TransportModePicker.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Segmented selector for Driving, Walking, and Transit routing modes.
public struct TransportModePicker: View {
    @Binding public var selection: TransportationMode
    public let onChange: (TransportationMode) -> Void
    
    public init(selection: Binding<TransportationMode>, onChange: @escaping (TransportationMode) -> Void = { _ in }) {
        self._selection = selection
        self.onChange = onChange
    }
    
    public var body: some View {
        HStack(spacing: 8) {
            ForEach(TransportationMode.allCases) { mode in
                let isSelected = selection == mode
                
                Button(action: {
                    let generator = UISelectionFeedbackGenerator()
                    generator.selectionChanged()
                    selection = mode
                    onChange(mode)
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: mode.iconName)
                            .font(.system(size: 14, weight: .semibold))
                        Text(mode.displayName)
                            .font(.subheadline.weight(isSelected ? .bold : .medium))
                    }
                    .foregroundColor(isSelected ? .white : .primary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                        in: RoundedRectangle(cornerRadius: 10, style: .continuous)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel(mode.displayName)
            }
        }
    }
}
