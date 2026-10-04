//
//  RoutePlanningSheetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Modal sheet for configuring route endpoints, calculating directions, and viewing route alternatives.
public struct RoutePlanningSheetView: View {
    @Bindable public var viewModel: RouteViewModel
    public let unitSystem: UnitSystem
    public let onApplyRoute: (RouteInfo) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        viewModel: RouteViewModel,
        unitSystem: UnitSystem,
        onApplyRoute: @escaping (RouteInfo) -> Void
    ) {
        self.viewModel = viewModel
        self.unitSystem = unitSystem
        self.onApplyRoute = onApplyRoute
    }
    
    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // Endpoint selectors with swap button
                    VStack(spacing: 8) {
                        HStack {
                            Image(systemName: "circle.circle.fill")
                                .foregroundColor(.green)
                                .font(.system(size: 16))
                            
                            TextField("Start Location", text: $viewModel.startName)
                                .font(.subheadline)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                        
                        HStack {
                            Spacer()
                            Button(action: {
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                                viewModel.swapEndpoints()
                            }) {
                                Image(systemName: "arrow.up.arrow.down.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundColor(.accentColor)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Swap start and destination")
                            Spacer()
                        }
                        
                        HStack {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 16))
                            
                            TextField("Destination", text: $viewModel.destinationName)
                                .font(.subheadline)
                        }
                        .padding(12)
                        .background(Color(.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 10))
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    
                    // Transport Mode Picker
                    TransportModePicker(selection: $viewModel.transportMode) { mode in
                        viewModel.setTransportMode(mode)
                    }
                    .padding(.horizontal, 16)
                    
                    // Calculate Route Button
                    Button(action: {
                        viewModel.calculateRoute()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                                    .padding(.trailing, 4)
                            } else {
                                Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                            }
                            Text(viewModel.isLoading ? "Calculating Route..." : "Calculate Route")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .disabled(viewModel.isLoading || viewModel.startCoordinate == nil || viewModel.destinationCoordinate == nil)
                    .padding(.horizontal, 16)
                    
                    // Error message
                    if let error = viewModel.errorMessage {
                        HStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                    }
                    
                    // Route Alternatives
                    if !viewModel.routes.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Suggested Routes")
                                .font(.headline)
                                .padding(.horizontal, 16)
                            
                            ForEach(Array(viewModel.routes.enumerated()), id: \.offset) { index, route in
                                let isSelected = viewModel.selectedRouteIndex == index
                                
                                Button(action: {
                                    viewModel.selectedRouteIndex = index
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(route.name)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            HStack(spacing: 12) {
                                                Text(UnitFormatter.shared.formatDuration(route.expectedTravelTime))
                                                    .font(.subheadline.bold())
                                                    .foregroundColor(.green)
                                                
                                                Text(UnitFormatter.shared.formatDistance(route.distance, system: unitSystem))
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                        
                                        Spacer()
                                        
                                        if isSelected {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundColor(.accentColor)
                                                .font(.title3)
                                        }
                                    }
                                    .padding(14)
                                    .background(
                                        isSelected ? Color.accentColor.opacity(0.12) : Color(.secondarySystemBackground),
                                        in: RoundedRectangle(cornerRadius: 12)
                                    )
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .strokeBorder(isSelected ? Color.accentColor : Color.clear, lineWidth: 1.5)
                                    )
                                }
                                .buttonStyle(.plain)
                                .padding(.horizontal, 16)
                            }
                            
                            // Apply Button
                            if let active = viewModel.activeRoute {
                                Button(action: {
                                    onApplyRoute(active)
                                    dismiss()
                                }) {
                                    Text("Display on Map")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 12)
                                        .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 12))
                                }
                                .padding(.horizontal, 16)
                                .padding(.top, 4)
                                
                                // Turn-by-Turn Steps
                                if !active.steps.isEmpty {
                                    RouteStepDetailView(steps: active.steps, unitSystem: unitSystem)
                                }
                            }
                        }
                    }
                }
                .padding(.bottom, 24)
            }
            .navigationTitle("Directions")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
