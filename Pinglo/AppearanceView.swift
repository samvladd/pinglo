//
//  AppearanceView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

class GlobalAppearance: ObservableObject {
    static let shared = GlobalAppearance()
    
    @Published var accentColor: Color = .blue
    @Published var theme: String = "System"
    @Published var fontSize: String = "System"
    
    private init() {
        loadSettings()
    }
    
    func loadSettings() {
        accentColor = colorValue(for: UserDefaults.standard.string(forKey: "appAccentColor") ?? "Blue")
        theme = UserDefaults.standard.string(forKey: "appTheme") ?? "System"
        fontSize = UserDefaults.standard.string(forKey: "appFontSize") ?? "System"
    }
    
    func updateAccentColor(_ colorName: String) {
        accentColor = colorValue(for: colorName)
        UserDefaults.standard.set(colorName, forKey: "appAccentColor")
        objectWillChange.send()
    }
    
    func updateTheme(_ themeName: String) {
        theme = themeName
        UserDefaults.standard.set(themeName, forKey: "appTheme")
        objectWillChange.send()
    }
    
    func updateFontSize(_ sizeName: String) {
        fontSize = sizeName
        UserDefaults.standard.set(sizeName, forKey: "appFontSize")
        objectWillChange.send()
    }
    
    private func colorValue(for colorName: String) -> Color {
        switch colorName {
        case "Blue": return .blue
        case "Green": return .green
        case "Purple": return .purple
        case "Orange": return .orange
        case "Pink": return .pink
        case "Red": return .red
        case "Teal": return .teal
        case "Indigo": return .indigo
        default: return .blue
        }
    }
}

struct AppearanceView: View {
    @StateObject private var globalAppearance = GlobalAppearance.shared
    @State private var selectedColor = "Blue"
    @State private var selectedTheme = "System"
    @State private var showingPreview = false
    
    let themeOptions = ["Light", "Dark", "System"]
    let accentColors = ["Blue", "Green", "Purple", "Orange", "Pink", "Red", "Teal", "Indigo"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Preview Section
                VStack(spacing: 16) {
                    Text("Preview")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    // Live preview card
                    VStack(spacing: 12) {
                        HStack {
                            Circle()
                                .fill(globalAppearance.accentColor)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("P")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                )
                            
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Pinglo")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                Text("Your messaging app")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Circle()
                                .fill(globalAppearance.accentColor.opacity(0.2))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image(systemName: "message.fill")
                                        .foregroundColor(globalAppearance.accentColor)
                                        .font(.caption)
                                )
                        }
                        
                        Divider()
                        
                        HStack(spacing: 12) {
                            ForEach(0..<3) { index in
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(globalAppearance.accentColor.opacity(0.1))
                                    .frame(height: 8)
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(20)
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                }
                
                // Theme Selection
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "paintbrush.fill")
                            .foregroundColor(globalAppearance.accentColor)
                            .font(.title3)
                        Text("Theme")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    HStack(spacing: 12) {
                        ForEach(themeOptions, id: \.self) { theme in
                            ThemeOptionButton(
                                title: theme,
                                isSelected: selectedTheme == theme,
                                accentColor: globalAppearance.accentColor
                            ) {
                                selectedTheme = theme
                                globalAppearance.updateTheme(theme)
                            }
                        }
                    }
                }
                
                // Accent Color Selection
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "paintpalette.fill")
                            .foregroundColor(globalAppearance.accentColor)
                            .font(.title3)
                        Text("Accent Color")
                            .font(.title3)
                            .fontWeight(.semibold)
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 16) {
                        ForEach(accentColors, id: \.self) { color in
                            ColorOptionButton(
                                color: color,
                                isSelected: selectedColor == color,
                                accentColor: globalAppearance.accentColor
                            ) {
                                selectedColor = color
                                globalAppearance.updateAccentColor(color)
                            }
                        }
                    }
                }
                

            }
            .padding(24)
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Appearance")
        .navigationBarTitleDisplayMode(.large)
        .onAppear {
            selectedColor = UserDefaults.standard.string(forKey: "appAccentColor") ?? "Blue"
            selectedTheme = UserDefaults.standard.string(forKey: "appTheme") ?? "System"
        }
    }
}

struct ThemeOptionButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: themeIcon)
                    .font(.title2)
                    .foregroundColor(isSelected ? .white : accentColor)
                
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isSelected ? accentColor : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var themeIcon: String {
        switch title {
        case "Light": return "sun.max.fill"
        case "Dark": return "moon.fill"
        case "System": return "gear"
        default: return "gear"
        }
    }
}

struct ColorOptionButton: View {
    let color: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(colorValue)
                    .frame(width: 60, height: 60)
                    .shadow(color: colorValue.opacity(0.3), radius: 8, x: 0, y: 4)
                
                if isSelected {
                    Circle()
                        .stroke(Color.white, lineWidth: 3)
                        .frame(width: 66, height: 66)
                    
                    Image(systemName: "checkmark")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
    
    private var colorValue: Color {
        switch color {
        case "Blue": return .blue
        case "Green": return .green
        case "Purple": return .purple
        case "Orange": return .orange
        case "Pink": return .pink
        case "Red": return .red
        case "Teal": return .teal
        case "Indigo": return .indigo
        default: return .blue
        }
    }
}



#Preview {
    NavigationView {
        AppearanceView()
    }
} 