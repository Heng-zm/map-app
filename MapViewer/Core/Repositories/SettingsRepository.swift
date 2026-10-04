//
//  SettingsRepository.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation
import SwiftUI

/// App color scheme appearance choice.
public enum AppAppearance: String, CaseIterable, Identifiable, Codable, Sendable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    
    public var id: String { rawValue }
    
    public var displayName: String {
        switch self {
        case .system:
            return "System"
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        }
    }
    
    public var colorScheme: ColorScheme? {
        switch self {
        case .system:
            return nil
        case .light:
            return .light
        case .dark:
            return .dark
        }
    }
}

/// Contract for reading and writing user preferences and persistent settings.
public protocol SettingsRepositoryProtocol: Sendable {
    var coordinateFormat: CoordinateFormat { get set }
    var unitSystem: UnitSystem { get set }
    var mapStyle: MapStyleOption { get set }
    var mapElevation: MapElevation { get set }
    var showsTraffic: Bool { get set }
    var showsBuildings: Bool { get set }
    var showsCompass: Bool { get set }
    var showsScale: Bool { get set }
    var appearance: AppAppearance { get set }
    var followUserOnLaunch: Bool { get set }
    var defaultPitch: Double { get set }
}

/// Production implementation of SettingsRepositoryProtocol using UserDefaults.
public final class UserDefaultsSettingsRepository: SettingsRepositoryProtocol, @unchecked Sendable {
    private let defaults: UserDefaults
    
    private enum Keys {
        static let coordinateFormat = "mv_pref_coordinate_format"
        static let unitSystem = "mv_pref_unit_system"
        static let mapStyle = "mv_pref_map_style"
        static let mapElevation = "mv_pref_map_elevation"
        static let showsTraffic = "mv_pref_shows_traffic"
        static let showsBuildings = "mv_pref_shows_buildings"
        static let showsCompass = "mv_pref_shows_compass"
        static let showsScale = "mv_pref_shows_scale"
        static let appearance = "mv_pref_appearance"
        static let followUserOnLaunch = "mv_pref_follow_user_on_launch"
        static let defaultPitch = "mv_pref_default_pitch"
    }
    
    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }
    
    public var coordinateFormat: CoordinateFormat {
        get {
            guard let raw = defaults.string(forKey: Keys.coordinateFormat),
                  let val = CoordinateFormat(rawValue: raw) else {
                return .decimalDegrees
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.coordinateFormat)
        }
    }
    
    public var unitSystem: UnitSystem {
        get {
            guard let raw = defaults.string(forKey: Keys.unitSystem),
                  let val = UnitSystem(rawValue: raw) else {
                return .metric
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.unitSystem)
        }
    }
    
    public var mapStyle: MapStyleOption {
        get {
            guard let raw = defaults.string(forKey: Keys.mapStyle),
                  let val = MapStyleOption(rawValue: raw) else {
                return .standard
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.mapStyle)
        }
    }
    
    public var mapElevation: MapElevation {
        get {
            guard let raw = defaults.string(forKey: Keys.mapElevation),
                  let val = MapElevation(rawValue: raw) else {
                return .realistic
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.mapElevation)
        }
    }
    
    public var showsTraffic: Bool {
        get { defaults.bool(forKey: Keys.showsTraffic) }
        set { defaults.set(newValue, forKey: Keys.showsTraffic) }
    }
    
    public var showsBuildings: Bool {
        get {
            if defaults.object(forKey: Keys.showsBuildings) == nil {
                return true // default enabled
            }
            return defaults.bool(forKey: Keys.showsBuildings)
        }
        set { defaults.set(newValue, forKey: Keys.showsBuildings) }
    }
    
    public var showsCompass: Bool {
        get {
            if defaults.object(forKey: Keys.showsCompass) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.showsCompass)
        }
        set { defaults.set(newValue, forKey: Keys.showsCompass) }
    }
    
    public var showsScale: Bool {
        get {
            if defaults.object(forKey: Keys.showsScale) == nil {
                return true
            }
            return defaults.bool(forKey: Keys.showsScale)
        }
        set { defaults.set(newValue, forKey: Keys.showsScale) }
    }
    
    public var appearance: AppAppearance {
        get {
            guard let raw = defaults.string(forKey: Keys.appearance),
                  let val = AppAppearance(rawValue: raw) else {
                return .system
            }
            return val
        }
        set {
            defaults.set(newValue.rawValue, forKey: Keys.appearance)
        }
    }
    
    public var followUserOnLaunch: Bool {
        get { defaults.bool(forKey: Keys.followUserOnLaunch) }
        set { defaults.set(newValue, forKey: Keys.followUserOnLaunch) }
    }
    
    public var defaultPitch: Double {
        get {
            if defaults.object(forKey: Keys.defaultPitch) == nil {
                return 0.0
            }
            return defaults.double(forKey: Keys.defaultPitch)
        }
        set { defaults.set(newValue, forKey: Keys.defaultPitch) }
    }
}
