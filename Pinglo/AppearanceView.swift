//
//  AppearanceView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct AppearanceView: View {
    @AppStorage("appTheme") private var appTheme = "System"
    @AppStorage("appAccentColor") private var appAccentColor = "Blue"
    @AppStorage("appFontSize") private var appFontSize = "System"
    
    let themeOptions = ["Light", "Dark", "System"]
    let accentColors = ["Blue", "Green", "Purple", "Orange", "Pink", "Red"]
    let fontSizeOptions = ["Small", "Medium", "Large", "System"]
    
    var accentColorValue: Color {
        switch appAccentColor {
        case "Blue": return .blue
        case "Green": return .green
        case "Purple": return .purple
        case "Orange": return .orange
        case "Pink": return .pink
        case "Red": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        List {
            Section {
                // Theme Selection
                VStack(alignment: .leading, spacing: 12) {
                    Text("Theme")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Picker("Theme", selection: $appTheme) {
                        ForEach(themeOptions, id: \.self) { theme in
                            Text(theme).tag(theme)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: appTheme) { oldValue, newValue in
                        updateAppTheme()
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                // Accent Color
                VStack(alignment: .leading, spacing: 12) {
                    Text("Accent Color")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 12) {
                        ForEach(accentColors, id: \.self) { color in
                            Button(action: {
                                appAccentColor = color
                                updateAppAccentColor()
                            }) {
                                Circle()
                                    .fill(colorValue(for: color))
                                    .frame(width: 50, height: 50)
                                    .overlay(
                                        Circle()
                                            .stroke(appAccentColor == color ? Color.primary : Color.clear, lineWidth: 3)
                                    )
                                    .overlay(
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.white)
                                            .font(.title2)
                                            .fontWeight(.bold)
                                            .opacity(appAccentColor == color ? 1 : 0)
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.vertical, 4)
            }
            
            Section {
                // Font Size
                VStack(alignment: .leading, spacing: 12) {
                    Text("Font Size")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Picker("Font Size", selection: $appFontSize) {
                        ForEach(fontSizeOptions, id: \.self) { size in
                            Text(size).tag(size)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .onChange(of: appFontSize) { oldValue, newValue in
                        updateAppFontSize()
                    }
                    
                    Text("Note: Font size follows your device settings")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
    }
    
    private func colorValue(for colorName: String) -> Color {
        switch colorName {
        case "Blue": return .blue
        case "Green": return .green
        case "Purple": return .purple
        case "Orange": return .orange
        case "Pink": return .pink
        case "Red": return .red
        default: return .blue
        }
    }
    
    private func updateAppTheme() {
        // This would typically update the app's color scheme
        // For now, we'll just store the preference
        print("Theme updated to: \(appTheme)")
    }
    
    private func updateAppAccentColor() {
        // This would typically update the app's accent color
        // For now, we'll just store the preference
        print("Accent color updated to: \(appAccentColor)")
    }
    
    private func updateAppFontSize() {
        // This would typically update the app's font size
        // For now, we'll just store the preference
        print("Font size updated to: \(appFontSize)")
    }
}

#Preview {
    NavigationView {
        AppearanceView()
    }
} 