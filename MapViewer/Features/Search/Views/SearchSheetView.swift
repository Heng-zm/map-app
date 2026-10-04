//
//  SearchSheetView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI
import MapKit

/// Modal sheet for searching places, categories, and browsing search history.
public struct SearchSheetView: View {
    @Bindable public var viewModel: SearchViewModel
    public let onSelectPlace: (PlaceSearchResult) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        viewModel: SearchViewModel,
        onSelectPlace: @escaping (PlaceSearchResult) -> Void
    ) {
        self.viewModel = viewModel
        self.onSelectPlace = onSelectPlace
    }
    
    public var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                // Search Field
                SearchBarField(
                    text: $viewModel.queryText,
                    placeholder: "Search places, addresses...",
                    isLoading: viewModel.isLoading,
                    onSubmit: {
                        viewModel.performSearch()
                    }
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                
                // Categories
                CategoryChipsView { category in
                    viewModel.searchCategory(category.poiCategory)
                }
                
                Divider()
                
                // Content Scroll
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        if let error = viewModel.errorMessage {
                            VStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.orange)
                                    .font(.system(size: 28))
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 24)
                        } else if !viewModel.searchResults.isEmpty || !viewModel.completions.isEmpty {
                            SearchResultsListView(
                                completions: viewModel.completions,
                                results: viewModel.searchResults,
                                onSelectCompletion: { completion in
                                    viewModel.selectCompletion(completion)
                                },
                                onSelectResult: { place in
                                    onSelectPlace(place)
                                    dismiss()
                                }
                            )
                        } else if viewModel.queryText.isEmpty {
                            SearchHistoryView(
                                history: viewModel.recentSearches,
                                onSelect: { historyItem in
                                    if let coord = historyItem.coordinate {
                                        let place = PlaceSearchResult(
                                            name: historyItem.title,
                                            title: historyItem.title,
                                            subtitle: historyItem.subtitle,
                                            coordinate: coord
                                        )
                                        onSelectPlace(place)
                                        dismiss()
                                    } else {
                                        viewModel.queryText = historyItem.query
                                        viewModel.performSearch(query: historyItem.query)
                                    }
                                },
                                onDelete: { item in
                                    viewModel.deleteHistoryItem(item)
                                },
                                onClearAll: {
                                    viewModel.clearHistory()
                                }
                            )
                        } else if !viewModel.isLoading {
                            VStack(spacing: 12) {
                                Image(systemName: "magnifyingglass")
                                    .font(.system(size: 36))
                                    .foregroundColor(.secondary)
                                Text("No results for \"\(viewModel.queryText)\"")
                                    .font(.headline)
                                Text("Check your spelling or try broader keywords.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 48)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
