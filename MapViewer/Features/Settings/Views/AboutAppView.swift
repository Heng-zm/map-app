//
//  AboutAppView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Information view presenting app version, architecture, and technology overview.
public struct AboutAppView: View {
    public var body: some View {
        List {
            Section {
                VStack(spacing: 12) {
                    Image(systemName: "map.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                        .padding(.top, 8)
                    
                    Text("Map Viewer")
                        .font(.title2.bold())
                    
                    Text("Production iOS Geographic Explorer")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text("Version 1.0.0 (Build 1)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section("Built With Apple Native Technologies") {
                LabeledContent("UI Framework", value: "SwiftUI")
                LabeledContent("Map Engine", value: "MapKit")
                LabeledContent("Location Services", value: "Core Location")
                LabeledContent("Persistence", value: "SwiftData")
                LabeledContent("State Management", value: "Observation Framework")
                LabeledContent("Concurrency", value: "Swift Concurrency (async/await)")
            }
            
            Section("Architecture") {
                Text("Clean MVVM with decoupled Service & Repository layers and Dependency Injection.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Section("Open Source & Attribution") {
                Text("Map data provided by Apple Maps and Apple MapKit Services. Authalic spherical geodesic calculations based on Chamberlain-Duquette algorithm.")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .navigationTitle("About Map Viewer")
        .navigationBarTitleDisplayMode(.inline)
    }
}
