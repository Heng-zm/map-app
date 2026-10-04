//
//  MeasurementViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import Observation

/// ViewModel managing interactive distance and polygon area measurements.
@Observable
@MainActor
public final class MeasurementViewModel {
    private let measurementService: MeasurementServiceProtocol
    private let settingsRepository: SettingsRepositoryProtocol
    
    public var mode: MeasurementMode = .distance
    public var points: [MeasurementPoint] = []
    public var result: MeasurementResult = .empty
    public var isActive: Bool = false
    
    public var unitSystem: UnitSystem {
        settingsRepository.unitSystem
    }
    
    public var coordinates: [CLLocationCoordinate2D] {
        points.map { $0.coordinate }
    }
    
    public init(
        measurementService: MeasurementServiceProtocol,
        settingsRepository: SettingsRepositoryProtocol
    ) {
        self.measurementService = measurementService
        self.settingsRepository = settingsRepository
    }
    
    public func addPoint(_ coordinate: CLLocationCoordinate2D) {
        guard coordinate.isValidCoordinate else { return }
        let newPoint = MeasurementPoint(coordinate: coordinate, index: points.count + 1)
        points.append(newPoint)
        recalculate()
    }
    
    public func removePoint(at index: Int) {
        guard index >= 0 && index < points.count else { return }
        points.remove(at: index)
        // Re-index remaining points
        for i in 0..<points.count {
            points[i] = MeasurementPoint(id: points[i].id, coordinate: points[i].coordinate, index: i + 1)
        }
        recalculate()
    }
    
    public func undoLastPoint() {
        guard !points.isEmpty else { return }
        points.removeLast()
        recalculate()
    }
    
    public func clear() {
        points = []
        result = .empty
    }
    
    public func toggleMode() {
        mode = (mode == .distance) ? .area : .distance
        recalculate()
    }
    
    private func recalculate() {
        let coords = coordinates
        self.result = measurementService.evaluateMeasurement(coordinates: coords, mode: mode)
    }
    
    // MARK: - Formatted Strings
    
    public var formattedPrimaryValue: String {
        switch mode {
        case .distance:
            return UnitFormatter.shared.formatDistance(result.totalDistance, system: unitSystem)
        case .area:
            return UnitFormatter.shared.formatArea(result.polygonArea, system: unitSystem)
        }
    }
    
    public var formattedSecondaryValue: String {
        switch mode {
        case .distance:
            return "\(points.count) points"
        case .area:
            let perimeterStr = UnitFormatter.shared.formatDistance(result.perimeter, system: unitSystem)
            return "Perimeter: \(perimeterStr)"
        }
    }
}
