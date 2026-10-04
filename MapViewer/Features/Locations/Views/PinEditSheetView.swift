//
//  PinEditSheetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Sheet dialog for configuring title, notes, color, and favorite state of a custom map pin.
public struct PinEditSheetView: View {
    public let pin: LocationPin
    public let isNewPin: Bool
    public let onSave: (LocationPin) -> Void
    public let onDelete: ((LocationPin) -> Void)?
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var notes: String
    @State private var selectedColorHex: String
    @State private var isFavorite: Bool
    
    private let availableColors = [
        "#FF3B30", // Red
        "#FF9500", // Orange
        "#FFCC00", // Yellow
        "#34C759", // Green
        "#00C7BE", // Teal
        "#007AFF", // Blue
        "#5856D6", // Purple
        "#AF52DE"  // Pink
    ]
    
    public init(
        pin: LocationPin,
        isNewPin: Bool = false,
        onSave: @escaping (LocationPin) -> Void,
        onDelete: ((LocationPin) -> Void)? = nil
    ) {
        self.pin = pin
        self.isNewPin = isNewPin
        self.onSave = onSave
        self.onDelete = onDelete
        
        self._title = State(initialValue: pin.title)
        self._notes = State(initialValue: pin.notes)
        self._selectedColorHex = State(initialValue: pin.colorHex)
        self._isFavorite = State(initialValue: pin.isFavorite)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Pin Details") {
                    TextField("Pin Name", text: $title)
                        .font(.body)
                    
                    if let subtitle = pin.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Toggle("Favorite Pin", isOn: $isFavorite)
                }
                
                Section("Marker Color") {
                    HStack(spacing: 12) {
                        ForEach(availableColors, id: \.self) { hex in
                            Circle()
                                .fill(Color(hex: hex) ?? .red)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Circle()
                                        .strokeBorder(Color.white, lineWidth: selectedColorHex == hex ? 3 : 0)
                                )
                                .shadow(color: .black.opacity(0.15), radius: 2)
                                .scaleEffect(selectedColorHex == hex ? 1.15 : 1.0)
                                .onTapGesture {
                                    selectedColorHex = hex
                                    let generator = UISelectionFeedbackGenerator()
                                    generator.selectionChanged()
                                }
                                .accessibilityLabel("Color \(hex)")
                        }
                    }
                    .padding(.vertical, 6)
                }
                
                Section("Notes") {
                    TextField("Add notes, reminders, or details...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Geographic Location") {
                    LabeledContent("Coordinates", value: CoordinateFormatter.shared.formatRawDecimal(pin.coordinate))
                }
                
                if !isNewPin, let onDelete = onDelete {
                    Section {
                        Button(role: .destructive, action: {
                            onDelete(pin)
                            dismiss()
                        }) {
                            HStack {
                                Spacer()
                                Text("Delete Pin")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isNewPin ? "Drop Custom Pin" : "Edit Pin")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        var updatedPin = pin
                        updatedPin.title = title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Dropped Pin" : title
                        updatedPin.notes = notes
                        updatedPin.colorHex = selectedColorHex
                        updatedPin.isFavorite = isFavorite
                        updatedPin.updatedAt = Date()
                        
                        onSave(updatedPin)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
