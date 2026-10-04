//
//  SettingsView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Settings screen for preferences, coordinates, units, appearance, and cache management.
public struct SettingsView: View {
    @Bindable public var viewModel: SettingsViewModel
    
    @Environment(\.dismiss) private var dismiss
    
    public init(viewModel: SettingsViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Map Display
                Section("Map Display") {
                    Picker("Default Map Style", selection: $viewModel.mapStyle) {
                        ForEach(MapStyleOption.allCases) { style in
                            Label(style.displayName, systemImage: style.iconName).tag(style)
                        }
                    }
                    
                    Picker("Elevation / Perspective", selection: $viewModel.mapElevation) {
                        ForEach(MapElevation.allCases) { elev in
                            Text(elev.displayName).tag(elev)
                        }
                    }
                    
                    Toggle("Show Real-Time Traffic", isOn: $viewModel.showsTraffic)
                    Toggle("Show 3D Buildings", isOn: $viewModel.showsBuildings)
                    Toggle("Show Compass Control", isOn: $viewModel.showsCompass)
                    Toggle("Show Distance Scale", isOn: $viewModel.showsScale)
                    Toggle("Center on User on Launch", isOn: $viewModel.followUserOnLaunch)
                }
                
                // Section 2: Coordinates & Units
                Section("Coordinates & Units") {
                    Picker("Coordinate Format", selection: $viewModel.coordinateFormat) {
                        ForEach(CoordinateFormat.allCases) { format in
                            Text(format.displayName).tag(format)
                        }
                    }
                    
                    Text("Example: \(viewModel.coordinateFormat.exampleString)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Picker("Unit System", selection: $viewModel.unitSystem) {
                        ForEach(UnitSystem.allCases) { system in
                            Text(system.displayName).tag(system)
                        }
                    }
                }
                
                // Section 3: Location Authorization
                Section("Location Access") {
                    SettingsRowView(
                        iconName: "location.fill",
                        iconColor: .blue,
                        title: "Permission Status",
                        subtitle: viewModel.locationPermissionDescription
                    ) {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            Link("Settings", destination: settingsURL)
                                .font(.subheadline)
                        }
                    }
                }
                
                // Section 4: Appearance
                Section("Appearance") {
                    Picker("Color Scheme", selection: $viewModel.appearance) {
                        ForEach(AppAppearance.allCases) { app in
                            Text(app.displayName).tag(app)
                        }
                    }
                }
                
                // Section 5: Data & Privacy
                Section("Data & History") {
                    Button(role: .destructive, action: {
                        viewModel.showClearHistoryAlert = true
                    }) {
                        Label("Clear Search History", systemImage: "trash")
                    }
                }
                
                // Section 6: About & Privacy
                Section("Application Information") {
                    NavigationLink(destination: AboutAppView()) {
                        SettingsRowView(
                            iconName: "info.circle.fill",
                            iconColor: .indigo,
                            title: "About Map Viewer",
                            subtitle: "v\(viewModel.appVersion) (\(viewModel.buildNumber))"
                        ) {
                            EmptyView()
                        }
                    }
                    
                    NavigationLink(destination: PrivacyInfoView()) {
                        SettingsRowView(
                            iconName: "hand.raised.fill",
                            iconColor: .green,
                            title: "Privacy & Data Protection",
                            subtitle: "Zero tracking, on-device only"
                        ) {
                            EmptyView()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .alert("Clear Search History?", isPresented: $viewModel.showClearHistoryAlert) {
                Button("Clear All", role: .destructive) {
                    viewModel.clearSearchHistory()
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently remove all cached and recent searches from your device.")
            }
        }
    }
}
