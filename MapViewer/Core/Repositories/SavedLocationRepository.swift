//
//  SavedLocationRepository.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

/// Repository contract for persisting and querying saved locations and custom pins.
@MainActor
public protocol SavedLocationRepositoryProtocol: AnyObject, Sendable {
    func fetchAll() throws -> [SavedLocation]
    func fetchFavorites() throws -> [SavedLocation]
    func save(_ location: SavedLocation) throws
    func update(_ location: SavedLocation) throws
    func delete(_ location: SavedLocation) throws
    func toggleFavorite(_ location: SavedLocation) throws
    
    // Custom Pins
    func fetchAllPins() throws -> [CustomPin]
    func savePin(_ pin: CustomPin) throws
    func updatePin(_ pin: CustomPin) throws
    func deletePin(_ pin: CustomPin) throws
}
