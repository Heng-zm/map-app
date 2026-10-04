//
//  PrivacyInfoView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Clear disclosure explaining zero tracking, local persistence, and location usage.
public struct PrivacyInfoView: View {
    public var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Privacy First", systemImage: "hand.raised.fill")
                        .font(.headline)
                        .foregroundColor(.green)
                    
                    Text("Map Viewer was designed with user privacy as a fundamental requirement. We believe your geographic data, searches, and bookmarks belong exclusively to you.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Location Usage") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why We Ask for Location")
                        .font(.subheadline.bold())
                    
                    Text("Your GPS location is accessed solely while using the application to center the map on your position, calculate accurate turn-by-turn directions, and calculate distances.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    
                    Text("Your coordinates are never uploaded to any third-party server, analytics provider, or advertising network.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Data Storage") {
                VStack(alignment: .leading, spacing: 8) {
                    Text("On-Device SwiftData")
                        .font(.subheadline.bold())
                    
                    Text("Saved places, custom pins, search history, and settings preferences are stored exclusively on your device using Apple's SwiftData. You can clear your search history or delete saved places at any time.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            
            Section("Third-Party SDKs") {
                HStack {
                    Image(systemName: "checkmark.shield.fill")
                        .foregroundColor(.blue)
                    Text("Zero 3rd-party trackers, ad SDKs, or analytics.")
                        .font(.subheadline)
                }
            }
        }
        .navigationTitle("Privacy & Data Protection")
        .navigationBarTitleDisplayMode(.inline)
    }
}
