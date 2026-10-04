//
//  SearchHistoryView.swift
//  MapViewer
//
//  Created for Map Viewer Production App.
//

import SwiftUI

/// View displaying recent search queries with swipe-to-delete and clear actions.
public struct SearchHistoryView: View {
    public let history: [SearchHistoryItem]
    public let onSelect: (SearchHistoryItem) -> Void
    public let onDelete: (SearchHistoryItem) -> Void
    public let onClearAll: () -> Void
    
    public init(
        history: [SearchHistoryItem],
        onSelect: @escaping (SearchHistoryItem) -> Void,
        onDelete: @escaping (SearchHistoryItem) -> Void,
        onClearAll: @escaping () -> Void
    ) {
        self.history = history
        self.onSelect = onSelect
        self.onDelete = onDelete
        self.onClearAll = onClearAll
    }
    
    public var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Recent Searches")
                    .font(.subheadline.bold())
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !history.isEmpty {
                    Button("Clear All", action: onClearAll)
                        .font(.caption.bold())
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            
            if history.isEmpty {
                Text("No recent searches")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
            } else {
                ForEach(history) { item in
                    Button(action: { onSelect(item) }) {
                        HStack(spacing: 12) {
                            Image(systemName: "clock.arrow.circlepath")
                                .foregroundColor(.secondary)
                                .font(.system(size: 15))
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text(item.title)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                
                                if !item.subtitle.isEmpty {
                                    Text(item.subtitle)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .lineLimit(1)
                                }
                            }
                            
                            Spacer()
                            
                            Button(action: { onDelete(item) }) {
                                Image(systemName: "xmark")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 12))
                                    .padding(6)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Remove \(item.title) from history")
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                    
                    Divider()
                        .padding(.leading, 44)
                }
            }
        }
    }
}
