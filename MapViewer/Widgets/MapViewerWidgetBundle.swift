//
//  MapViewerWidgetBundle.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Entries

public struct CoordinateEntry: TimelineEntry {
    public let date: Date
    public let snapshot: WidgetCoordinateSnapshot?
    
    public init(date: Date, snapshot: WidgetCoordinateSnapshot?) {
        self.date = date
        self.snapshot = snapshot
    }
}

public struct FavoritesEntry: TimelineEntry {
    public let date: Date
    public let places: [WidgetPlaceItem]
    
    public init(date: Date, places: [WidgetPlaceItem]) {
        self.date = date
        self.places = places
    }
}

// MARK: - Coordinate Provider

public struct CoordinateTimelineProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> CoordinateEntry {
        CoordinateEntry(date: Date(), snapshot: WidgetSnapshotData.preview.coordinate)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (CoordinateEntry) -> Void) {
        let data = WidgetDataSyncService.shared.readSnapshot()
        let entry = CoordinateEntry(date: Date(), snapshot: data.coordinate ?? WidgetSnapshotData.preview.coordinate)
        completion(entry)
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<CoordinateEntry>) -> Void) {
        let data = WidgetDataSyncService.shared.readSnapshot()
        let entry = CoordinateEntry(date: Date(), snapshot: data.coordinate)
        
        // Refresh every 15 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date()) ?? Date().addingTimeInterval(900)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Favorites Provider

public struct FavoritesTimelineProvider: TimelineProvider {
    public init() {}
    
    public func placeholder(in context: Context) -> FavoritesEntry {
        FavoritesEntry(date: Date(), places: WidgetSnapshotData.preview.favoritePlaces)
    }
    
    public func getSnapshot(in context: Context, completion: @escaping (FavoritesEntry) -> Void) {
        let data = WidgetDataSyncService.shared.readSnapshot()
        let places = data.favoritePlaces.isEmpty ? WidgetSnapshotData.preview.favoritePlaces : data.favoritePlaces
        completion(FavoritesEntry(date: Date(), places: places))
    }
    
    public func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesEntry>) -> Void) {
        let data = WidgetDataSyncService.shared.readSnapshot()
        let entry = FavoritesEntry(date: Date(), places: data.favoritePlaces)
        
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date()) ?? Date().addingTimeInterval(1800)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widgets

public struct CoordinateWidget: Widget {
    public let kind: String = "com.antigravity.mapviewer.widget.coordinate"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CoordinateTimelineProvider()) { entry in
            CoordinateWidgetView(snapshot: entry.snapshot)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.12, blue: 0.22), Color(red: 0.03, green: 0.05, blue: 0.12)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Current Coordinates")
        .description("View your real-time latitude, longitude, and heading on Home and Lock Screens.")
        .supportedFamilies([.systemSmall, .accessoryCircular, .accessoryRectangular])
    }
}

public struct FavoritePlacesWidget: Widget {
    public let kind: String = "com.antigravity.mapviewer.widget.favorites"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoritesTimelineProvider()) { entry in
            FavoritesWidgetView(places: entry.places)
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(red: 0.10, green: 0.14, blue: 0.24), Color(red: 0.04, green: 0.06, blue: 0.14)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Favorite Places")
        .description("Quick access to your bookmarked locations with distance and one-tap navigation.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

public struct QuickActionsWidget: Widget {
    public let kind: String = "com.antigravity.mapviewer.widget.actions"
    
    public init() {}
    
    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoritesTimelineProvider()) { _ in
            QuickActionsWidgetView()
                .containerBackground(for: .widget) {
                    LinearGradient(
                        colors: [Color(red: 0.08, green: 0.12, blue: 0.22), Color(red: 0.02, green: 0.04, blue: 0.10)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
        }
        .configurationDisplayName("Quick Map Actions")
        .description("One-tap shortcuts to Locate, Search, and Measure directly from your Home Screen.")
        .supportedFamilies([.systemMedium])
    }
}
