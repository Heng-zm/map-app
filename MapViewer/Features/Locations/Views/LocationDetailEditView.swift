//
//  LocationDetailEditView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Form view to edit metadata of a saved location.
public struct LocationDetailEditView: View {
    @Bindable public var location: SavedLocation
    public let onSave: () -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var name: String
    @State private var notes: String
    @State private var category: String
    @State private var isFavorite: Bool
    
    public init(location: SavedLocation, onSave: @escaping () -> Void) {
        self.location = location
        self.onSave = onSave
        
        self._name = State(initialValue: location.name)
        self._notes = State(initialValue: location.notes)
        self._category = State(initialValue: location.category ?? "Personal")
        self._isFavorite = State(initialValue: location.isFavorite)
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                Section("Place Details") {
                    TextField("Name", text: $name)
                    TextField("Category (e.g. Work, Vacation)", text: $category)
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section("Notes") {
                    TextField("Personal notes...", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section("Location Info") {
                    if let address = location.address {
                        LabeledContent("Address", value: address)
                    }
                    LabeledContent("Coordinates", value: CoordinateFormatter.shared.formatRawDecimal(location.coordinate))
                    LabeledContent("Added On", value: location.createdAt.formatted(date: .abbreviated, time: .shortened))
                }
            }
            .navigationTitle("Edit Saved Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        location.name = name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "Saved Place" : name
                        location.notes = notes
                        location.category = category
                        location.isFavorite = isFavorite
                        location.updatedAt = Date()
                        
                        onSave()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
