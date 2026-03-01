//
//  SettingsView.swift
//  Skyrift
//

import SwiftUI

struct SettingsView: View {
    @State private var languageManager = LanguageManager.shared
    @State private var showLanguageSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showLanguageSheet = true
                    } label: {
                        HStack {
                            Label {
                                Text("language".localized)
                            } icon: {
                                if languageManager.currentLanguage == .system {
                                    Image(systemName: "globe")
                                        .foregroundStyle(.blue)
                                } else {
                                    Text(languageManager.currentLanguage.flag)
                                        .font(.title3)
                                }
                            }
                            
                            Spacer()
                            
                            Text(languageManager.currentLanguage.displayName)
                                .foregroundStyle(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                    .foregroundStyle(.primary)
                }
                
                Section {
                    HStack {
                        Text("App Version")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.tertiary)
                    }
                    .font(.subheadline)
                }
            }
            .navigationTitle("settings".localized)
        }
        .sheet(isPresented: $showLanguageSheet) {
            LanguageSelectionView(languageManager: languageManager)
        }
    }
}

// MARK: - Language Selection View

struct LanguageSelectionView: View {
    @Bindable var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(AppLanguage.allCases) { language in
                    Button {
                        languageManager.currentLanguage = language
                        dismiss()
                    } label: {
                        HStack(spacing: 16) {
                            // Flag or icon
                            if language == .system {
                                Image(systemName: "globe")
                                    .font(.title3)
                                    .foregroundStyle(.blue)
                                    .frame(width: 32)
                            } else {
                                Text(language.flag)
                                    .font(.title2)
                                    .frame(width: 32)
                            }
                            
                            // Language name
                            Text(language.displayName)
                                .foregroundStyle(.primary)
                            
                            Spacer()
                            
                            // Checkmark
                            if languageManager.currentLanguage == language {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                                    .fontWeight(.semibold)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("select_language".localized)
#if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
#endif
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("done".localized) {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    SettingsView()
}
