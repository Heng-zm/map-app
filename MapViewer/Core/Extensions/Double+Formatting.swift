//
//  Double+Formatting.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import Foundation

extension Double {
    /// Formats a double to a fixed number of decimal places.
    public func formatted(decimalPlaces: Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = decimalPlaces
        formatter.maximumFractionDigits = decimalPlaces
        formatter.numberStyle = .decimal
        return formatter.string(from: NSNumber(value: self)) ?? String(format: "%.\(decimalPlaces)f", self)
    }
}
