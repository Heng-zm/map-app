//
//  TrackRecordingViewModel.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import CoreLocation
import Observation

/// Manages active GPS track recording session, live metrics accumulation, and export triggers.
@Observable
@MainActor
public final class TrackRecordingViewModel {
    public private(set) var isRecording: Bool = false
    public private(set) var isPaused: Bool = false
    public var selectedActivity: TrackActivityType = .hiking
    
    public private(set) var trackPoints: [TrackPoint] = []
    public private(set) var distanceMeters: Double = 0.0
    public private(set) var elapsedTime: TimeInterval = 0.0
    public private(set) var currentSpeedMps: Double = 0.0
    public private(set) var maxSpeedMps: Double = 0.0
    public private(set) var elevationGainMeters: Double = 0.0
    
    public var completedTrack: RecordedTrack?
    public var isDetailSheetPresented: Bool = false
    
    private var lastRecordedLocation: CLLocation?
    private var timer: Timer?
    private var sessionStartTime: Date?
    
    public init() {}
    
    /// Starts recording a new track session.
    public func startRecording(activity: TrackActivityType = .hiking) {
        self.selectedActivity = activity
        self.trackPoints = []
        self.distanceMeters = 0.0
        self.elapsedTime = 0.0
        self.currentSpeedMps = 0.0
        self.maxSpeedMps = 0.0
        self.elevationGainMeters = 0.0
        self.lastRecordedLocation = nil
        self.completedTrack = nil
        
        self.isRecording = true
        self.isPaused = false
        self.sessionStartTime = Date()
        
        startTimer()
    }
    
    /// Pauses recording (e.g. during a rest stop).
    public func pauseRecording() {
        guard isRecording, !isPaused else { return }
        isPaused = true
        stopTimer()
    }
    
    /// Resumes active recording.
    public func resumeRecording() {
        guard isRecording, isPaused else { return }
        isPaused = false
        startTimer()
    }
    
    /// Appends a new GPS location update if valid and movement meets threshold.
    public func processLocationUpdate(_ location: CLLocation) {
        guard isRecording, !isPaused else { return }
        guard location.coordinate.isValidCoordinate else { return }
        
        // Horizontal accuracy filter (reject fixes worse than 35m)
        guard location.horizontalAccuracy >= 0 && location.horizontalAccuracy <= 35.0 else { return }
        
        if let last = lastRecordedLocation {
            let stepDistance = location.distance(from: last)
            // Filter noise if user hasn't moved more than 1.5 meters
            guard stepDistance >= 1.5 else { return }
            
            distanceMeters += stepDistance
            
            // Calculate elevation gain
            let altDelta = location.altitude - last.altitude
            if altDelta > 0.8 { // Filter barometric noise
                elevationGainMeters += altDelta
            }
        }
        
        let speed = max(location.speed, 0.0)
        currentSpeedMps = speed
        if speed > maxSpeedMps {
            maxSpeedMps = speed
        }
        
        let pt = TrackPoint(
            latitude: location.coordinate.latitude,
            longitude: location.coordinate.longitude,
            altitude: location.altitude,
            speed: speed,
            timestamp: location.timestamp
        )
        trackPoints.append(pt)
        lastRecordedLocation = location
    }
    
    /// Stops recording and produces a finalized RecordedTrack.
    @discardableResult
    public func stopRecording() -> RecordedTrack? {
        guard isRecording else { return nil }
        stopTimer()
        
        let start = sessionStartTime ?? Date()
        let track = RecordedTrack(
            title: "\(selectedActivity.rawValue) Track",
            notes: "Recorded with MapViewer",
            activityType: selectedActivity,
            points: trackPoints,
            startTime: start,
            endTime: Date(),
            distanceMeters: distanceMeters,
            durationSeconds: elapsedTime,
            elevationGainMeters: elevationGainMeters,
            maxSpeedMps: maxSpeedMps
        )
        
        self.completedTrack = track
        self.isRecording = false
        self.isPaused = false
        self.isDetailSheetPresented = true
        return track
    }
    
    /// Discards the current recording session.
    public func discardRecording() {
        stopTimer()
        self.isRecording = false
        self.isPaused = false
        self.trackPoints = []
        self.distanceMeters = 0.0
        self.elapsedTime = 0.0
        self.completedTrack = nil
        self.lastRecordedLocation = nil
    }
    
    public var routeCoordinates: [CLLocationCoordinate2D] {
        trackPoints.map { $0.coordinate }
    }
    
    public var formattedDuration: String {
        let totalSeconds = Int(elapsedTime)
        let hours = totalSeconds / 3600
        let minutes = (totalSeconds % 3600) / 60
        let seconds = totalSeconds % 60
        if hours > 0 {
            return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
        } else {
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.elapsedTime += 1.0
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
