//
//  TrackRecordingHUDView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import CoreLocation

/// Floating HUD displayed during an active GPS track recording session.
public struct TrackRecordingHUDView: View {
    @Bindable var viewModel: TrackRecordingViewModel
    var unitSystem: UnitSystem = .metric
    
    @State private var isBlinking = false
    
    public init(viewModel: TrackRecordingViewModel, unitSystem: UnitSystem = .metric) {
        self.viewModel = viewModel
        self.unitSystem = unitSystem
    }
    
    public var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                // Recording status indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(viewModel.isPaused ? Color.orange : Color.red)
                        .frame(width: 10, height: 10)
                        .opacity(viewModel.isPaused ? 1.0 : (isBlinking ? 0.2 : 1.0))
                        .animation(
                            viewModel.isPaused ? .default : .easeInOut(duration: 0.8).repeatForever(autoreverses: true),
                            value: isBlinking
                        )
                    
                    Text(viewModel.isPaused ? "PAUSED" : "REC")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(viewModel.isPaused ? .orange : .red)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(
                    Capsule()
                        .fill(viewModel.isPaused ? Color.orange.opacity(0.15) : Color.red.opacity(0.15))
                )
                
                // Activity & Elapsed Time
                HStack(spacing: 4) {
                    Image(systemName: viewModel.selectedActivity.iconName)
                        .font(.caption.weight(.semibold))
                    Text(viewModel.formattedDuration)
                        .font(.subheadline.monospacedDigit().weight(.semibold))
                }
                
                Spacer()
                
                // Distance
                VStack(alignment: .trailing, spacing: 1) {
                    Text(UnitFormatter.shared.formatDistance(viewModel.distanceMeters, system: unitSystem))
                        .font(.subheadline.weight(.bold))
                    Text("Distance")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Divider()
                    .frame(height: 24)
                
                // Speed
                VStack(alignment: .trailing, spacing: 1) {
                    let speedKmh = viewModel.currentSpeedMps * 3.6
                    let speedText = unitSystem == .metric
                        ? String(format: "%.1f km/h", speedKmh)
                        : String(format: "%.1f mph", speedKmh * 0.621371)
                    Text(speedText)
                        .font(.subheadline.weight(.bold))
                    Text("Speed")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            
            // Action Controls
            HStack(spacing: 12) {
                Button(action: {
                    if viewModel.isPaused {
                        viewModel.resumeRecording()
                    } else {
                        viewModel.pauseRecording()
                    }
                }) {
                    Label(
                        viewModel.isPaused ? "Resume" : "Pause",
                        systemImage: viewModel.isPaused ? "play.fill" : "pause.fill"
                    )
                    .font(.caption.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
                
                Button(action: {
                    viewModel.stopRecording()
                }) {
                    Label("Finish Track", systemImage: "checkmark.circle.fill")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.accentColor)
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .shadow(color: .black.opacity(0.12), radius: 8, x: 0, y: 4)
        .padding(.horizontal, 16)
        .onAppear {
            isBlinking = true
        }
    }
}
