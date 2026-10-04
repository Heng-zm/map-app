//
//  SearchResultsListView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import MapKit

/// List displaying search autocomplete completions and resolved place search results.
public struct SearchResultsListView: View {
    public let completions: [MKLocalSearchCompletion]
    public let results: [PlaceSearchResult]
    public let onSelectCompletion: (MKLocalSearchCompletion) -> Void
    public let onSelectResult: (PlaceSearchResult) -> Void
    
    public init(
        completions: [MKLocalSearchCompletion],
        results: [PlaceSearchResult],
        onSelectCompletion: @escaping (MKLocalSearchCompletion) -> Void,
        onSelectResult: @escaping (PlaceSearchResult) -> Void
    ) {
        self.completions = completions
        self.results = results
        self.onSelectCompletion = onSelectCompletion
        self.onSelectResult = onSelectResult
    }
    
    public var body: some View {
        VStack(spacing: 0) {
            if !results.isEmpty {
                // Resolved Search Results
                ForEach(results) { place in
                    Button(action: { onSelectResult(place) }) {
                        HStack(spacing: 12) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.red)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text(place.name)
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                
                                if let address = place.address {
                                    Text(address)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                                
                                if let cat = place.category {
                                    Text(cat)
                                        .font(.caption2.bold())
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(Color.accentColor.opacity(0.12), in: Capsule())
                                        .foregroundColor(.accentColor)
                                }
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.leading, 52)
                }
            } else if !completions.isEmpty {
                // Autocomplete completions
                ForEach(completions, id: \.self) { completion in
                    Button(action: { onSelectCompletion(completion) }) {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 16))
                                .foregroundColor(.secondary)
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(completion.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if !completion.subtitle.isEmpty {
                                    Text(completion.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider().padding(.leading, 44)
                }
            }
        }
    }
}
