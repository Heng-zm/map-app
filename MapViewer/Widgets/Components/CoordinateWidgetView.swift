//
//  CoordinateWidgetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import WidgetKit
import CoreLocation

/// View rendering the live coordinate badge across Home Screen and Lock Screen widgets.
public struct CoordinateWidgetView: View {
    public let snapshot: WidgetCoordinateSnapshot?
    @Environment(\.widgetFamily) private var family
    
    public init(snapshot: WidgetCoordinateSnapshot?) {
        self.snapshot = snapshot
    }
    
    public var body: some View {
        switch family {
        case .accessoryCircular:
            circularLockScreenView
        case .accessoryRectangular:
            rectangularLockScreenView
        default:
            homeScreenSmallView
        }
    }
    
    // MARK: - Home Screen Small
    
    private var homeScreenSmallView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "location.north.circle.fill")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(.cyan)
                    .rotationEffect(.degrees(snapshot?.headingDegrees ?? 0))
                
                Spacer()
                
                Text("COORDINATES")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            if let snap = snapshot {
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Text(String(format: "%.4f°", abs(snap.latitude)))
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                        Text(snap.latitude >= 0 ? "N" : "S")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.cyan)
                    }
                    
                    HStack(spacing: 4) {
                        Text(String(format: "%.4f°", abs(snap.longitude)))
                            .font(.system(size: 15, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                        Text(snap.longitude >= 0 ? "E" : "W")
                            .font(.system(size: 12, weight: .black))
                            .foregroundStyle(.cyan)
                    }
                }
                
                if let alt = snap.altitudeMeters {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.up.and.down.and.sparkles")
                            .font(.system(size: 8))
                        Text(String(format: "%.0f m alt", alt))
                            .font(.system(size: 10, weight: .medium, design: .monospaced))
                    }
                    .foregroundStyle(.white.opacity(0.75))
                    .padding(.top, 2)
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Location Idle")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Tap to open map and locate your position")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(14)
        .widgetURL(deepLinkURL)
    }
    
    // MARK: - Lock Screen Circular
    
    private var circularLockScreenView: some View {
        VStack(spacing: 1) {
            Image(systemName: "location.north.circle.fill")
                .font(.system(size: 16))
                .rotationEffect(.degrees(snapshot?.headingDegrees ?? 0))
            
            if let snap = snapshot {
                Text(String(format: "%.1f°", abs(snap.latitude)))
                    .font(.system(size: 11, weight: .bold, design: .monospaced))
                Text(snap.latitude >= 0 ? "N" : "S")
                    .font(.system(size: 8, weight: .heavy))
            } else {
                Text("MAP")
                    .font(.system(size: 10, weight: .bold))
            }
        }
        .widgetURL(deepLinkURL)
    }
    
    // MARK: - Lock Screen Rectangular
    
    private var rectangularLockScreenView: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: "location.fill")
                    .font(.system(size: 10))
                Text("MAP VIEWER")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
            }
            
            if let snap = snapshot {
                Text("\(String(format: "%.4f°", abs(snap.latitude))) \(snap.latitude >= 0 ? "N" : "S")")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
                Text("\(String(format: "%.4f°", abs(snap.longitude))) \(snap.longitude >= 0 ? "E" : "W")")
                    .font(.system(size: 12, weight: .semibold, design: .monospaced))
            } else {
                Text("Tap to update location")
                    .font(.system(size: 11))
            }
        }
        .widgetURL(deepLinkURL)
    }
    
    private var deepLinkURL: URL {
        if let snap = snapshot {
            return DeepLinkHandler.coordinateURL(latitude: snap.latitude, longitude: snap.longitude) ?? DeepLinkHandler.locateURL
        }
        return DeepLinkHandler.locateURL
    }
}
