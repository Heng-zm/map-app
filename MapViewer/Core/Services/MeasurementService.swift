//
//  MeasurementService.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation

/// Protocol declaring measurement calculation capabilities for distance paths and polygon areas.
public protocol MeasurementServiceProtocol: Sendable {
    func calculateDistance(coordinates: [CLLocationCoordinate2D]) -> Double
    func calculateSegmentDistances(coordinates: [CLLocationCoordinate2D]) -> [Double]
    func calculatePolygonArea(coordinates: [CLLocationCoordinate2D]) -> Double
    func calculatePerimeter(coordinates: [CLLocationCoordinate2D]) -> Double
    func evaluateMeasurement(coordinates: [CLLocationCoordinate2D], mode: MeasurementMode) -> MeasurementResult
}

/// Production implementation of MeasurementServiceProtocol using GeodesicCalculator.
public final class MeasurementService: MeasurementServiceProtocol, Sendable {
    private let calculator: GeodesicCalculator
    
    public init(calculator: GeodesicCalculator = .shared) {
        self.calculator = calculator
    }
    
    public func calculateDistance(coordinates: [CLLocationCoordinate2D]) -> Double {
        calculator.pathDistance(coordinates: coordinates)
    }
    
    public func calculateSegmentDistances(coordinates: [CLLocationCoordinate2D]) -> [Double] {
        calculator.segmentDistances(coordinates: coordinates)
    }
    
    public func calculatePolygonArea(coordinates: [CLLocationCoordinate2D]) -> Double {
        calculator.polygonArea(coordinates: coordinates)
    }
    
    public func calculatePerimeter(coordinates: [CLLocationCoordinate2D]) -> Double {
        calculator.polygonPerimeter(coordinates: coordinates)
    }
    
    public func evaluateMeasurement(coordinates: [CLLocationCoordinate2D], mode: MeasurementMode) -> MeasurementResult {
        let totalDist = calculateDistance(coordinates: coordinates)
        let segments = calculateSegmentDistances(coordinates: coordinates)
        let area = mode == .area ? calculatePolygonArea(coordinates: coordinates) : 0.0
        let perimeter = mode == .area ? calculatePerimeter(coordinates: coordinates) : totalDist
        
        return MeasurementResult(
            totalDistance: totalDist,
            segmentDistances: segments,
            polygonArea: area,
            perimeter: perimeter,
            pointCount: coordinates.count
        )
    }
}
