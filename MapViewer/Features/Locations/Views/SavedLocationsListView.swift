//
//  SavedLocationsListView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Screen displaying user's saved locations with search, sorting, filtering, and CRUD management.
public struct SavedLocationsListView: View {
    @Bindable public var viewModel: SavedLocationsViewModel
    public let userCoordinate: CLLocationCoordinate2D?
    public let unitSystem: UnitSystem
    public let onSelectLocation: (SavedLocation) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var locationToEdit: SavedLocation?
    
    public init(
        viewModel: SavedLocationsViewModel,
        userCoordinate: CLLocationCoordinate2D?,
        unitSystem: UnitSystem,
        onSelectLocation: @escaping (SavedLocation) -> Void
    ) {
        self.viewModel = viewModel
        self.userCoordinate = userCoordinate
        self.unitSystem = unitSystem
        self.onSelectLocation = onSelectLocation
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 10) {
                // Search & Filter
                SearchBarField(
                    text: $viewModel.filterText,
                    placeholder: "Filter saved places..."
                )
                .padding(.horizontal, 16)
                .padding(.top, 8)
                
                // Category Pills
                CategoryFilterBar(
                    categories: viewModel.availableCategories,
                    selectedCategory: $viewModel.selectedCategory
                )
                
                // Sorting & Favorites Filter Bar
                HStack {
                    Toggle(isOn: $viewModel.showFavoritesOnly) {
                        Label("Favorites Only", systemImage: "star.fill")
                            .font(.caption.bold())
                            .foregroundColor(.yellow)
                    }
                    .toggleStyle(.button)
                    .tint(.yellow.opacity(0.2))
                    
                    Spacer()
                    
                    Menu {
                        Picker("Sort By", selection: $viewModel.sortOption) {
                            ForEach(SavedLocationSortOption.allCases) { option in
                                Text(option.rawValue).tag(option)
                            }
                        }
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.up.arrow.down")
                            Text(viewModel.sortOption.rawValue)
                        }
                        .font(.caption.bold())
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color(.secondarySystemBackground), in: Capsule())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 4)
                
                Divider()
                
                // Locations List
                if viewModel.filteredLocations.isEmpty {
                    VStack(spacing: 16) {
                        Spacer()
                        Image(systemName: "bookmark.slash")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No Saved Locations")
                            .font(.headline)
                        
                        Text(viewModel.filterText.isEmpty ? "Bookmark places or drop custom pins to view them here." : "No saved places match your filter.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(viewModel.filteredLocations) { location in
                            Button(action: {
                                onSelectLocation(location)
                                dismiss()
                            }) {
                                LocationCardRow(
                                    location: location,
                                    userCoordinate: userCoordinate,
                                    unitSystem: unitSystem,
                                    onToggleFavorite: {
                                        viewModel.toggleFavorite(location)
                                    }
                                )
                            }
                            .buttonStyle(.plain)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    viewModel.deleteLocation(location)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                
                                Button {
                                    locationToEdit = location
                                } label: {
                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                            .swipeActions(edge: .leading) {
                                Button {
                                    viewModel.toggleFavorite(location)
                                } label: {
                                    Label(
                                        location.isFavorite ? "Unfavorite" : "Favorite",
                                        systemImage: location.isFavorite ? "star.slash" : "star.fill"
                                    )
                                }
                                .tint(.yellow)
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("Saved Places")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(item: $locationToEdit) { location in
                LocationDetailEditView(location: location) {
                    viewModel.loadLocations()
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
