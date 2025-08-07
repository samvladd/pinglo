//
//  ContentView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            DiscoverView()
                .tabItem {
                    Image(systemName: "safari")
                    Text("Discover")
                }
            
            NavigationStack {
                ChatsView()
            }
            .tabItem {
                Image(systemName: "message.fill")
                Text("Chats")
            }
            
            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("Settings")
                }
        }
        .preferredColorScheme(.none) // This allows the app to follow device settings
    }
}

#Preview {
    ContentView()
}
