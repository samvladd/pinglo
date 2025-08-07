//
//  PingloApp.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

@main
struct PingloApp: App {
    @AppStorage("appTheme") private var appTheme = "System"
    @AppStorage("appAccentColor") private var appAccentColor = "Blue"
    @State private var isAuthenticated = false
    
    var body: some Scene {
        WindowGroup {
            if isAuthenticated {
                ContentView()
                    .preferredColorScheme(colorScheme)
                    .accentColor(accentColor)
            } else {
                AuthView(onContinue: { isAuthenticated = true })
            }
        }
    }
    
    private var colorScheme: ColorScheme? {
        switch appTheme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
    private var accentColor: Color {
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
}
