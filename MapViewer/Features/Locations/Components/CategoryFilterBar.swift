//
//  CategoryFilterBar.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Horizontal scroll bar for filtering saved places by category.
public struct CategoryFilterBar: View {
    public let categories: [String]
    @Binding public var selectedCategory: String?
    
    public init(categories: [String], selectedCategory: Binding<String?>) {
        self.categories = categories
        self._selectedCategory = selectedCategory
    }
    
    public var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(categories, id: \.self) { category in
                    let isSelected = (selectedCategory == category) || (selectedCategory == nil && category == "All")
                    
                    Button(action: {
                        let generator = UISelectionFeedbackGenerator()
                        generator.selectionChanged()
                        if category == "All" {
                            selectedCategory = nil
                        } else {
                            selectedCategory = category
                        }
                    }) {
                        Text(category)
                            .font(.subheadline.weight(isSelected ? .semibold : .regular))
                            .foregroundColor(isSelected ? .white : .primary)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                isSelected ? Color.accentColor : Color(.secondarySystemBackground),
                                in: Capsule()
                            )
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Filter by \(category)")
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
