//
//  ContentView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var globalAppearance = GlobalAppearance.shared
    @StateObject private var chatManager = ChatManager()
    @State private var selectedTab = 0
    @State private var chatToOpen: String? = nil
    
    private var colorScheme: ColorScheme? {
        switch globalAppearance.theme {
        case "Light": return .light
        case "Dark": return .dark
        default: return nil
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DiscoverView(chatManager: chatManager, selectedTab: $selectedTab, chatToOpen: $chatToOpen)
                .tabItem {
                    Image(systemName: "safari")
                    Text("Discover")
                }
                .tag(0)
            
            NavigationStack {
                ChatsView(chatManager: chatManager, chatToOpen: $chatToOpen, selectedTab: $selectedTab)
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chats")
            }
            .tag(1)
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
                .tag(2)
        }
        .preferredColorScheme(colorScheme)
        .accentColor(globalAppearance.accentColor)
        .onAppear {
            globalAppearance.loadSettings()
        }
    }
}

#Preview {
    ContentView()
}
