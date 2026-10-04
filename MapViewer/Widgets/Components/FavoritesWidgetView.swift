//
//  FavoritesWidgetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import WidgetKit

/// View rendering favorite places on Home Screen widgets with individual place deep links.
public struct FavoritesWidgetView: View {
    public let places: [WidgetPlaceItem]
    @Environment(\.widgetFamily) private var family
    
    public init(places: [WidgetPlaceItem]) {
        self.places = places
    }
    
    public var body: some View {
        switch family {
        case .systemMedium:
            mediumFavoritesView
        default:
            smallFavoriteView
        }
    }
    
    // MARK: - Small View
    
    private var smallFavoriteView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "star.fill")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(.yellow)
                Spacer()
                Text("FAVORITE")
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white.opacity(0.7))
            }
            
            Spacer()
            
            if let topPlace = places.first {
                VStack(alignment: .leading, spacing: 3) {
                    Text(topPlace.name)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    
                    Text(topPlace.subtitle)
                        .font(.system(size: 11))
                        .foregroundStyle(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    if let dist = topPlace.formattedDistance {
                        HStack(spacing: 3) {
                            Image(systemName: "arrow.triangle.turn.up.right.diamond.fill")
                                .font(.system(size: 9))
                            Text(dist)
                                .font(.system(size: 10, weight: .semibold))
                        }
                        .foregroundStyle(.cyan)
                        .padding(.top, 2)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 4) {
                    Text("No Favorites Yet")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(.white)
                    Text("Bookmark places in Map Viewer to see them here")
                        .font(.system(size: 10))
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .padding(14)
        .widgetURL(firstPlaceURL)
    }
    
    // MARK: - Medium View
    
    private var mediumFavoritesView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label("Favorite Places", systemImage: "bookmark.fill")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundStyle(.white)
                
                Spacer()
                
                Link(destination: DeepLinkHandler.searchURL) {
                    Label("Explore", systemImage: "magnifyingglass")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundStyle(.cyan)
                }
            }
            
            Divider().background(Color.white.opacity(0.2))
            
            if places.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 20))
                            .foregroundStyle(.white.opacity(0.5))
                        Text("No saved favorite places yet")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    Spacer()
                }
                Spacer()
            } else {
                VStack(spacing: 6) {
                    ForEach(places.prefix(3)) { place in
                        Link(destination: placeDeepLink(place)) {
                            HStack(spacing: 8) {
                                Image(systemName: categoryIcon(place.category))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.cyan)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 1) {
                                    Text(place.name)
                                        .font(.system(size: 12, weight: .semibold))
                                        .foregroundStyle(.white)
                                        .lineLimit(1)
                                    Text(place.subtitle)
                                        .font(.system(size: 10))
                                        .foregroundStyle(.white.opacity(0.65))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                if let dist = place.formattedDistance {
                                    Text(dist)
                                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                                        .foregroundStyle(.cyan)
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.cyan.opacity(0.18))
                                        .clipShape(Capsule())
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
            }
        }
        .padding(14)
    }
    
    private var firstPlaceURL: URL {
        if let first = places.first {
            return placeDeepLink(first)
        }
        return DeepLinkHandler.locateURL
    }
    
    private func placeDeepLink(_ place: WidgetPlaceItem) -> URL {
        DeepLinkHandler.placeURL(
            latitude: place.latitude,
            longitude: place.longitude,
            title: place.name
        ) ?? DeepLinkHandler.locateURL
    }
    
    private func categoryIcon(_ category: String) -> String {
        switch category.lowercased() {
        case "landmark", "sightseeing": return "building.columns.fill"
        case "scenic", "nature", "park": return "mountain.2.fill"
        case "restaurant", "food", "cafe": return "fork.knife"
        case "personal", "home": return "house.fill"
        case "work", "office": return "briefcase.fill"
        default: return "mappin.circle.fill"
        }
    }
}
