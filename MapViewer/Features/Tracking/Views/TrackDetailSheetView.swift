//
//  TrackDetailSheetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Sheet displaying summary statistics of a completed GPS track and GPX export options.
public struct TrackDetailSheetView: View {
    @Binding var track: RecordedTrack?
    var unitSystem: UnitSystem = .metric
    @Environment(\.dismiss) private var dismiss
    
    @State private var exportURL: URL?
    @State private var isExporting = false
    
    public init(track: Binding<RecordedTrack?>, unitSystem: UnitSystem = .metric) {
        self._track = track
        self.unitSystem = unitSystem
    }
    
    public var body: some View {
        NavigationStack {
            Group {
                if let currentTrack = track {
                    ScrollView {
                        VStack(spacing: 20) {
                            // Header Card
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.accentColor.opacity(0.15))
                                        .frame(width: 56, height: 56)
                                    Image(systemName: currentTrack.activityType.iconName)
                                        .font(.title2.weight(.bold))
                                        .foregroundStyle(Color.accentColor)
                                }
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(currentTrack.title)
                                        .font(.title3.weight(.bold))
                                    Text(currentTrack.startTime.formatted(date: .abbreviated, time: .shortened))
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            
                            // Metrics Grid
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                MetricCard(
                                    title: "Distance",
                                    value: UnitFormatter.shared.formatDistance(currentTrack.distanceMeters, system: unitSystem),
                                    icon: "arrow.triangle.swap",
                                    color: .blue
                                )
                                MetricCard(
                                    title: "Duration",
                                    value: formatDuration(currentTrack.durationSeconds),
                                    icon: "stopwatch.fill",
                                    color: .orange
                                )
                                MetricCard(
                                    title: "Avg Speed",
                                    value: formatSpeed(currentTrack.averageSpeedKmh),
                                    icon: "gauge.with.needle.fill",
                                    color: .green
                                )
                                MetricCard(
                                    title: "Max Speed",
                                    value: formatSpeed(currentTrack.maxSpeedKmh),
                                    icon: "bolt.fill",
                                    color: .red
                                )
                                MetricCard(
                                    title: "Elevation Gain",
                                    value: String(format: "+%.0f m", currentTrack.elevationGainMeters),
                                    icon: "mountain.2.fill",
                                    color: .purple
                                )
                                MetricCard(
                                    title: "Waypoints",
                                    value: "\(currentTrack.points.count)",
                                    icon: "point.topleft.down.to.point.bottomright.curvepath",
                                    color: .teal
                                )
                            }
                            
                            // GPX Export Section
                            VStack(spacing: 12) {
                                if let url = exportURL {
                                    ShareLink(item: url, preview: SharePreview(currentTrack.title, icon: Image(systemName: "point.filled.topleft.down.curvedto.point.bottomright.up"))) {
                                        Label("Share / Export GPX File", systemImage: "square.and.arrow.up.fill")
                                            .font(.headline)
                                            .foregroundStyle(.white)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.accentColor)
                                            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                } else {
                                    Button(action: prepareExport) {
                                        HStack {
                                            if isExporting {
                                                ProgressView()
                                                    .tint(.white)
                                                    .padding(.trailing, 4)
                                            }
                                            Label("Prepare GPX Export", systemImage: "arrow.down.doc.fill")
                                                .font(.headline)
                                        }
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.accentColor)
                                        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                                    }
                                    .disabled(isExporting)
                                }
                                
                                Text("GPX files can be imported into Garmin, Strava, Google Earth, and Apple Fitness.")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                            .padding(.top, 12)
                        }
                        .padding()
                    }
                } else {
                    ContentUnavailableView(
                        "No Track Data",
                        systemImage: "map.fill",
                        description: Text("No recorded track is currently loaded.")
                    )
                }
            }
            .navigationTitle("Recorded Track")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                prepareExport()
            }
        }
    }
    
    private func prepareExport() {
        guard let currentTrack = track else { return }
        isExporting = true
        Task {
            do {
                let url = try GPXExporter.createExportFile(for: currentTrack)
                await MainActor.run {
                    self.exportURL = url
                    self.isExporting = false
                }
            } catch {
                await MainActor.run {
                    self.isExporting = false
                }
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let total = Int(duration)
        let h = total / 3600
        let m = (total % 3600) / 60
        let s = total % 60
        if h > 0 {
            return "\(h)h \(m)m"
        } else {
            return "\(m)m \(s)s"
        }
    }
    
    private func formatSpeed(_ kmh: Double) -> String {
        if unitSystem == .metric {
            return String(format: "%.1f km/h", kmh)
        } else {
            return String(format: "%.1f mph", kmh * 0.621371)
        }
    }
}

private struct MetricCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.subheadline)
                Spacer()
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(.primary)
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
