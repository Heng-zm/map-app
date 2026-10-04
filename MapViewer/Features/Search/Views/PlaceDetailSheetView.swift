//
//  PlaceDetailSheetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Bottom sheet displaying detailed place metadata, actions, and directions launcher.
public struct PlaceDetailSheetView: View {
    public let place: PlaceSearchResult
    public let userCoordinate: CLLocationCoordinate2D?
    public let coordinateFormat: CoordinateFormat
    public let unitSystem: UnitSystem
    public let isFavorite: Bool
    
    public let onToggleFavorite: () -> Void
    public let onSavePlace: () -> Void
    public let onDirections: () -> Void
    public let onDismiss: () -> Void
    
    @State private var showCopiedAlert: Bool = false
    
    public init(
        place: PlaceSearchResult,
        userCoordinate: CLLocationCoordinate2D?,
        coordinateFormat: CoordinateFormat,
        unitSystem: UnitSystem,
        isFavorite: Bool = false,
        onToggleFavorite: @escaping () -> Void,
        onSavePlace: @escaping () -> Void,
        onDirections: @escaping () -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.place = place
        self.userCoordinate = userCoordinate
        self.coordinateFormat = coordinateFormat
        self.unitSystem = unitSystem
        self.isFavorite = isFavorite
        self.onToggleFavorite = onToggleFavorite
        self.onSavePlace = onSavePlace
        self.onDirections = onDirections
        self.onDismiss = onDismiss
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header Title & Category
                    VStack(alignment: .leading, spacing: 6) {
                        Text(place.name)
                            .font(.title2.bold())
                            .foregroundColor(.primary)
                        
                        if let address = place.address {
                            Text(address)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack(spacing: 8) {
                            if let cat = place.category {
                                Text(cat)
                                    .font(.caption.bold())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 3)
                                    .background(Color.accentColor.opacity(0.12), in: Capsule())
                                    .foregroundColor(.accentColor)
                            }
                            
                            if let userCoord = userCoordinate {
                                let dist = place.coordinate.distance(to: userCoord)
                                Text(UnitFormatter.shared.formatDistance(dist, system: unitSystem) + " away")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.top, 2)
                    }
                    
                    // Primary Action Buttons
                    HStack(spacing: 12) {
                        // Directions Button
                        Button(action: onDirections) {
                            HStack {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                Text("Directions")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Save Button
                        Button(action: onSavePlace) {
                            HStack {
                                Image(systemName: "bookmark.fill")
                                Text("Save")
                            }
                            .font(.headline)
                            .foregroundColor(.primary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                        
                        // Favorite Button
                        Button(action: onToggleFavorite) {
                            Image(systemName: isFavorite ? "star.fill" : "star")
                                .font(.title3)
                                .foregroundColor(isFavorite ? .yellow : .primary)
                                .frame(width: 48, height: 48)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 12))
                        }
                        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                    }
                    
                    Divider().padding(.vertical, 4)
                    
                    // Coordinates Row
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Coordinates")
                            .font(.caption.bold())
                            .foregroundColor(.secondary)
                        
                        HStack {
                            Text(CoordinateFormatter.shared.format(place.coordinate, format: coordinateFormat))
                                .font(.system(size: 14, weight: .medium, design: .monospaced))
                            
                            Spacer()
                            
                            Button(action: copyCoordinates) {
                                Image(systemName: showCopiedAlert ? "checkmark.circle.fill" : "doc.on.doc")
                                    .foregroundColor(showCopiedAlert ? .green : .accentColor)
                            }
                            .accessibilityLabel("Copy coordinates")
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                    
                    // Optional Contact Info (Phone & Website)
                    if place.phoneNumber != nil || place.url != nil {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Contact & Info")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                            
                            if let phone = place.phoneNumber, let phoneURL = URL(string: "tel://\(phone.replacingOccurrences(of: " ", with: ""))") {
                                Link(destination: phoneURL) {
                                    HStack {
                                        Image(systemName: "phone.fill")
                                            .foregroundColor(.green)
                                        Text(phone)
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                            
                            if let url = place.url {
                                Link(destination: url) {
                                    HStack {
                                        Image(systemName: "safari.fill")
                                            .foregroundColor(.blue)
                                        Text(url.host ?? url.absoluteString)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        Spacer()
                                        Image(systemName: "arrow.up.right")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(12)
                                    .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    
                    // Secondary Actions
                    VStack(spacing: 10) {
                        // Share Place
                        ShareLink(
                            item: place.address ?? place.name,
                            subject: Text(place.name),
                            message: Text("Check out \(place.name) on the map: \(CoordinateFormatter.shared.formatRawDecimal(place.coordinate))")
                        ) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share Location")
                                Spacer()
                            }
                            .foregroundColor(.primary)
                            .padding(12)
                            .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        }
                        
                        // Open in Apple Maps
                        if let appleMapsURL = CoordinateFormatter.shared.appleMapsURL(for: place.coordinate, name: place.name) {
                            Link(destination: appleMapsURL) {
                                HStack {
                                    Image(systemName: "map.fill")
                                        .foregroundColor(.accentColor)
                                    Text("Open in Apple Maps")
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                .foregroundColor(.primary)
                                .padding(12)
                                .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                            }
                        }
                    }
                    .padding(.top, 4)
                }
                .padding(20)
            }
            .navigationTitle("Place Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done", action: onDismiss)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    private func copyCoordinates() {
        let text = CoordinateFormatter.shared.formatRawDecimal(place.coordinate)
        UIPasteboard.general.string = text
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            showCopiedAlert = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) {
            withAnimation {
                showCopiedAlert = false
            }
        }
    }
}
