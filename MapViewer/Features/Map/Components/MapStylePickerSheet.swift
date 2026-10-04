//
//  MapStylePickerSheet.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Bottom sheet dialog for configuring map styles, 3D elevation, and visual layers.
public struct MapStylePickerSheet: View {
    @Binding public var selectedStyle: MapStyleOption
    @Binding public var elevation: MapElevation
    @Binding public var showsTraffic: Bool
    @Binding public var showsBuildings: Bool
    @Binding public var showsCompass: Bool
    @Binding public var showsScale: Bool
    
    @Environment(\.dismiss) private var dismiss
    
    public init(
        selectedStyle: Binding<MapStyleOption>,
        elevation: Binding<MapElevation>,
        showsTraffic: Binding<Bool>,
        showsBuildings: Binding<Bool>,
        showsCompass: Binding<Bool>,
        showsScale: Binding<Bool>
    ) {
        self._selectedStyle = selectedStyle
        self._elevation = elevation
        self._showsTraffic = showsTraffic
        self._showsBuildings = showsBuildings
        self._showsCompass = showsCompass
        self._showsScale = showsScale
    }
    
    public var body: some View {
        NavigationStack {
            List {
                Section("Base Map Style") {
                    ForEach(MapStyleOption.allCases) { style in
                        Button(action: {
                            selectedStyle = style
                            let generator = UISelectionFeedbackGenerator()
                            generator.selectionChanged()
                        }) {
                            HStack(spacing: 14) {
                                Image(systemName: style.iconName)
                                    .font(.system(size: 20))
                                    .foregroundColor(.accentColor)
                                    .frame(width: 28)
                                
                                Text(style.displayName)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if selectedStyle == style {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.accentColor)
                                        .font(.system(size: 15, weight: .bold))
                                }
                            }
                        }
                    }
                }
                
                Section("Perspective & Terrain") {
                    Picker("Elevation", selection: $elevation) {
                        ForEach(MapElevation.allCases) { elev in
                            Text(elev.displayName).tag(elev)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.vertical, 4)
                }
                
                Section("Map Overlays") {
                    Toggle("Real-Time Traffic", isOn: $showsTraffic)
                    Toggle("3D Buildings", isOn: $showsBuildings)
                    Toggle("Show Compass", isOn: $showsCompass)
                    Toggle("Show Scale Ruler", isOn: $showsScale)
                }
            }
            .navigationTitle("Map Configuration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
}
