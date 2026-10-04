//
//  QuickActionsWidgetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import WidgetKit

/// Widget view rendering quick actions to launch directly into Map features.
public struct QuickActionsWidgetView: View {
    public init() {}
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Label("Map Actions", systemImage: "map.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                Spacer()
                Text("QUICK LAUNCH")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            HStack(spacing: 8) {
                actionTile(
                    title: "Locate",
                    subtitle: "Center map",
                    icon: "location.fill",
                    color: .cyan,
                    url: DeepLinkHandler.locateURL
                )
                
                actionTile(
                    title: "Search",
                    subtitle: "Find places",
                    icon: "magnifyingglass",
                    color: .orange,
                    url: DeepLinkHandler.searchURL
                )
                
                actionTile(
                    title: "Measure",
                    subtitle: "Dist & area",
                    icon: "ruler.fill",
                    color: .green,
                    url: DeepLinkHandler.measureURL
                )
            }
        }
        .padding(14)
    }
    
    private func actionTile(
        title: String,
        subtitle: String,
        icon: String,
        color: Color,
        url: URL
    ) -> some View {
        Link(destination: url) {
            VStack(alignment: .leading, spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(color)
                    .frame(width: 28, height: 28)
                    .background(color.opacity(0.2))
                    .clipShape(Circle())
                
                Spacer()
                
                Text(title)
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(.white.opacity(0.65))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(10)
            .background(Color.white.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }
}
