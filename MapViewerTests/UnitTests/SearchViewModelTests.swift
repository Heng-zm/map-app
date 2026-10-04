//
//  SearchViewModelTests.swift
//  MapViewerTests
//
//  Created for Map Viewer Production App.
//

import XCTest
import MapKit
import SwiftData
@testable import MapViewer

@MainActor
final class SearchViewModelTests: XCTestCase {
    private var container: ModelContainer!
    private var searchService: SearchService!
    private var historyRepo: SwiftDataSearchHistoryRepository!
    private var viewModel: SearchViewModel!
    
    override func setUp() async throws {
        try await super.setUp()
        
        let schema = Schema([
            SavedLocation.self,
            SearchHistoryItem.self,
            CustomPin.self
        ])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        
        searchService = SearchService()
        historyRepo = SwiftDataSearchHistoryRepository(modelContainer: container)
        viewModel = SearchViewModel(
            searchService: searchService,
            searchHistoryRepository: historyRepo
        )
    }
    
    override func tearDown() async throws {
        viewModel = nil
        searchService = nil
        historyRepo = nil
        container = nil
        try await super.tearDown()
    }
    
    func testInitialState() {
        XCTAssertEqual(viewModel.queryText, "")
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.recentSearches.isEmpty)
        XCTAssertFalse(viewModel.isLoading)
        XCTAssertNil(viewModel.errorMessage)
    }
    
    func testEmptyQueryClearsResults() {
        viewModel.queryText = ""
        XCTAssertTrue(viewModel.searchResults.isEmpty)
        XCTAssertTrue(viewModel.completions.isEmpty)
    }
    
    func testSelectResultUpdatesSelection() {
        let coord = CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194)
        let place = PlaceSearchResult(
            name: "Ferry Building",
            title: "Ferry Building",
            subtitle: "San Francisco",
            coordinate: coord
        )
        
        viewModel.selectResult(place)
        XCTAssertEqual(viewModel.selectedPlace?.name, "Ferry Building")
    }
    
    func testClearHistory() throws {
        try historyRepo.add(query: "Golden Gate Bridge", title: "Golden Gate Bridge", subtitle: "SF", coordinate: nil)
        viewModel.loadHistory()
        XCTAssertEqual(viewModel.recentSearches.count, 1)
        
        viewModel.clearHistory()
        XCTAssertTrue(viewModel.recentSearches.isEmpty)
    }
}
