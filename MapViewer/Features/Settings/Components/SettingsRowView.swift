//
//  SettingsRowView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Standardized row component for Settings screens with SF Symbol and accessory.
public struct SettingsRowView<Accessory: View>: View {
    public let iconName: String
    public let iconColor: Color
    public let title: String
    public let subtitle: String?
    public let accessory: Accessory
    
    public init(
        iconName: String,
        iconColor: Color = .accentColor,
        title: String,
        subtitle: String? = nil,
        @ViewBuilder accessory: () -> Accessory
    ) {
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.accessory = accessory()
    }
    
    public var body: some View {
        HStack(spacing: 12) {
            Image(systemName: iconName)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let sub = subtitle {
                    Text(sub)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            accessory
        }
    }
}
