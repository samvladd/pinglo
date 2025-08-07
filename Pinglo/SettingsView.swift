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
    
    var body: some View {
        NavigationView {
            List {
                // Account Section
                Section {
                    NavigationLink(destination: AccountView()) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Account")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("John Doe")
                                    .font(.body)
                                    .fontWeight(.medium)
                                Text("@johndoe")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                
                // Connectivity Section
                Section {
                    NavigationLink(destination: ConnectivityView()) {
                        HStack {
                            Image(systemName: "wifi")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            Text("Connectivity")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Privacy Section
                Section {
                    NavigationLink(destination: PrivacyView()) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            Text("Privacy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // Appearance Section
                Section {
                    NavigationLink(destination: AppearanceView()) {
                        HStack {
                            Image(systemName: "paintbrush")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            Text("Appearance")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                // About Section
                Section {
                    HStack {
                        Image(systemName: "info.circle")
                            .foregroundColor(.gray)
                            .frame(width: 24)
                        Text("Version")
                        Spacer()
                        Text("Creation mode :)")
                            .foregroundColor(.secondary)
                    }
                    
                    NavigationLink(destination: TermsView()) {
                        HStack {
                            Image(systemName: "doc.text")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Terms of Service")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    NavigationLink(destination: PrivacyPolicyView()) {
                        HStack {
                            Image(systemName: "hand.raised")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Privacy Policy")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Button(action: {
                        if let url = URL(string: "mailto:appsproutorg@gmail.com") {
                            UIApplication.shared.open(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "envelope")
                                .foregroundColor(.gray)
                                .frame(width: 24)
                            Text("Send Feedback")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .foregroundColor(.primary)
                }
                
                // Account Actions Section
                Section {
                    Button(action: {
                        // TODO: Implement logout
                    }) {
                        HStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            Text("Log Out")
                                .foregroundColor(.orange)
                            Spacer()
                        }
                    }
                    
                    Button(action: {
                        // TODO: Implement delete account
                    }) {
                        HStack {
                            Image(systemName: "person.crop.circle.badge.minus")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            Text("Delete Account")
                                .foregroundColor(.red)
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    SettingsView()
} 