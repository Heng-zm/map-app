//
//  SearchBarField.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// Accessible search input field with clear button and loading indicator.
public struct SearchBarField: View {
    @Binding public var text: String
    public var placeholder: String = "Search places, addresses..."
    public var isLoading: Bool = false
    public var onSubmit: () -> Void
    
    public init(
        text: Binding<String>,
        placeholder: String = "Search places, addresses...",
        isLoading: Bool = false,
        onSubmit: @escaping () -> Void = {}
    ) {
        self._text = text
        self.placeholder = placeholder
        self.isLoading = isLoading
        self.onSubmit = onSubmit
    }
    
    public var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16, weight: .medium))
            
            TextField(placeholder, text: $text)
                .font(.body)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .submitLabel(.search)
                .onSubmit(onSubmit)
            
            if isLoading {
                ProgressView()
                    .controlSize(.small)
            } else if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                        .font(.system(size: 16))
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Clear search text")
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .glassBackground(cornerRadius: 12)
    }
}
