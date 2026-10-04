//
//  SearchHistoryRepository.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Repository contract for managing persisted search history.
@MainActor
public protocol SearchHistoryRepositoryProtocol: AnyObject, Sendable {
    func fetchRecent(limit: Int) throws -> [SearchHistoryItem]
    func add(query: String, title: String, subtitle: String, coordinate: CLLocationCoordinate2D?) throws
    func delete(_ item: SearchHistoryItem) throws
    func clearAll() throws
}
