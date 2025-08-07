//
//  AccountView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct AccountView: View {
    @State private var fullName = "John Doe"
    @State private var username = "johndoe"
    @State private var email = "john.doe@example.com"
    @State private var isGoogleConnected = true
    @State private var showingPasswordChange = false
    
    var body: some View {
        List {
            Section {
                // Name
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Name")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(fullName)
                            .font(.body)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // TODO: Show name edit modal
                }
                
                // Username
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text("@\(username)")
                            .font(.body)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // TODO: Show username edit modal
                }
            }
            
            Section {
                // Email
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(email)
                            .font(.body)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    // TODO: Show email edit modal
                }
                
                // OAuth Connection
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("OAuth")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(isGoogleConnected ? "Connected to Google" : "Not connected")
                            .font(.body)
                    }
                    Spacer()
                    Button(action: {
                        isGoogleConnected.toggle()
                    }) {
                        Text(isGoogleConnected ? "Disconnect" : "Connect Google")
                            .font(.body)
                            .foregroundColor(.blue)
                    }
                }
                
                // Change Password
                Button(action: {
                    showingPasswordChange = true
                }) {
                    HStack {
                        Text("Change Password")
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Account")
        .navigationBarTitleDisplayMode(.large)
        .alert("Change Password", isPresented: $showingPasswordChange) {
            Button("OK") { }
        } message: {
            Text("Password change functionality coming soon!")
        }
    }
}

#Preview {
    NavigationView {
        AccountView()
    }
} 