//
//  CategoryChipsView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import MapKit

/// Preset category item for quick nearby searches.
public struct SearchCategoryItem: Identifiable {
    public let id: String
    public let title: String
    public let iconName: String
    public let poiCategory: MKPointOfInterestCategory
    public let color: Color
    
    public static let standardCategories: [SearchCategoryItem] = [
        SearchCategoryItem(id: "restaurant", title: "Restaurants", iconName: "fork.knife", poiCategory: .restaurant, color: .orange),
        SearchCategoryItem(id: "cafe", title: "Coffee", iconName: "cup.and.saucer.fill", poiCategory: .cafe, color: .brown),
        SearchCategoryItem(id: "gas", title: "Gas Stations", iconName: "fuelpump.fill", poiCategory: .gasStation, color: .blue),
        SearchCategoryItem(id: "groceries", title: "Groceries", iconName: "cart.fill", poiCategory: .store, color: .green),
        SearchCategoryItem(id: "hospital", title: "Hospitals", iconName: "cross.case.fill", poiCategory: .hospital, color: .red),
        SearchCategoryItem(id: "park", title: "Parks", iconName: "tree.fill", poiCategory: .park, color: .mint),
        SearchCategoryItem(id: "hotel", title: "Hotels", iconName: "bed.double.fill", poiCategory: .hotel, color: .purple)
    ]
}

/// Horizontal scroll of quick POI category search chips.
public struct CategoryChipsView: View {
    public let onSelectCategory: (SearchCategoryItem) -> Void
    
    public init(onSelectCategory: @escaping (SearchCategoryItem) -> Void) {
        self.onSelectCategory = onSelectCategory
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(SearchCategoryItem.standardCategories) { item in
                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .light)
                        generator.impactOccurred()
                        onSelectCategory(item)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: item.iconName)
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(item.color)
                            
                            Text(item.title)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .glassBackground(cornerRadius: 16)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Search for nearby \(item.title)")
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
