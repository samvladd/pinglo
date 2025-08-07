//
//  SettingsView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct SettingsView: View {
    @State private var showingAccountView = false
    @State private var showingConnectivityView = false
    @State private var showingPrivacyView = false
    @State private var showingAppearanceView = false
    @State private var showingTermsView = false
    @State private var showingPrivacyPolicyView = false
    @AppStorage("isAuthenticated") private var isAuthenticated = true
    
    var body: some View {
        NavigationView {
            List {
                // Profile Header
                Section {
                    HStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.9), Color.purple.opacity(0.7)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 56, height: 56)
                            Text("J")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        }
                        VStack(alignment: .leading, spacing: 4) {
                            Text("John Doe")
                                .font(.headline)
                            Text("@johndoe")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Account")
                }
                .onTapGesture { showingAccountView = true }
                
                // App Settings
                Section(header: Text("App").textCase(.none)) {
                    NavigationLink(destination: ConnectivityView()) {
                        settingsRow(icon: "wifi", color: .blue, title: "Connectivity")
                    }
                    NavigationLink(destination: PrivacyView()) {
                        settingsRow(icon: "lock.shield", color: .green, title: "Privacy")
                    }
                    NavigationLink(destination: AppearanceView()) {
                        settingsRow(icon: "paintbrush", color: .purple, title: "Appearance")
                    }
                }
                
                // About
                Section(header: Text("About").textCase(.none)) {
                    HStack {
                        Image(systemName: "info.circle").foregroundColor(.gray).frame(width: 24)
                        Text("Version")
                        Spacer()
                        Text("Creation mode :)").foregroundColor(.secondary)
                    }
                    NavigationLink(destination: TermsView()) { settingsRow(icon: "doc.text", color: .gray, title: "Terms of Service") }
                    NavigationLink(destination: PrivacyPolicyView()) { settingsRow(icon: "hand.raised", color: .gray, title: "Privacy Policy") }
                    Button(action: { if let url = URL(string: "mailto:appsproutorg@gmail.com") { UIApplication.shared.open(url) } }) {
                        settingsRow(icon: "envelope", color: .gray, title: "Send Feedback")
                    }.foregroundColor(.primary)
                }
                
                // Actions
                Section(header: Text("Actions").textCase(.none)) {
                    Button(action: { isAuthenticated = false }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right").foregroundColor(.orange).frame(width: 24)
                            Text("Log Out").foregroundColor(.orange)
                            Spacer()
                        }
                    }
                    Button(action: { /* TODO delete account */ }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.minus").foregroundColor(.red).frame(width: 24)
                            Text("Delete Account").foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
            .background(Color(.systemGroupedBackground))
        }
        .sheet(isPresented: $showingAccountView) {
            NavigationView { AccountView() }
        }
    }
    
    @ViewBuilder
    private func settingsRow(icon: String, color: Color, title: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 24)
            Text(title)
            Spacer()
            Image(systemName: "chevron.right").font(.caption).foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
} 