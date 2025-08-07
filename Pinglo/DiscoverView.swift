//
//  DiscoverView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct DiscoverView: View {
    @State private var peers: [Peer] = []
    @State private var isRefreshing = false
    @State private var selectedPeer: Peer?
    @State private var showingPeerDetail = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Mesh status and count
                HStack {
                    HStack(spacing: 8) {
                        PulsingCircle(color: .green, diameter: 10)
                        Text("Mesh Active")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    Spacer()
                    Text("\(peers.count) Nearby")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: { Task { await refreshPeers() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                }
                .padding(.horizontal)
                .padding(.top)
                .padding(.bottom, 8)
                
                // Central 'You' circle with pulsing green ring
                ZStack {
                    PulsingCircle(color: .green, diameter: 80)
                    Circle()
                        .fill(LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]), startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 60, height: 60)
                        .shadow(color: .blue.opacity(0.2), radius: 6, x: 0, y: 2)
                    Text("You")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .padding(.bottom, 16)
                
                // Peer list
                VStack(alignment: .leading, spacing: 12) {
                    Text("Nearby Peers")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    ScrollView {
                        LazyVStack(spacing: 10) {
                            ForEach(peers) { peer in
                                PeerCardView(peer: peer)
                                    .onTapGesture {
                                        selectedPeer = peer
                                        showingPeerDetail = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .background(Color(.systemGroupedBackground))
            }
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.systemBackground), Color.blue.opacity(0.05), Color(.systemBackground)]), startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            )
            .navigationTitle("Discover Nearby")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingPeerDetail) {
                if let peer = selectedPeer {
                    PeerDetailView(peer: peer)
                }
            }
            .onAppear { loadPeers() }
        }
    }
    
    private func loadPeers() {
        peers = generateMockPeers()
    }
    
    private func refreshPeers() async {
        isRefreshing = true
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        peers = generateMockPeers()
        isRefreshing = false
    }
    
    private func generateMockPeers() -> [Peer] {
        let names = [
            ("Rachel Green", "@rgreen", "Coffee enthusiast"),
            ("Alex Chen", "@achen", "Tech geek"),
            ("Sarah Johnson", "@sjohnson", "Fitness lover"),
            ("Mike Rodriguez", "@mrodriguez", "Music producer"),
            ("Emma Davis", "@edavis", "Bookworm"),
            ("David Kim", "@dkim", "Gamer"),
            ("Lisa Wang", "@lwang", "Artist"),
            ("Tom Wilson", "@twilson", "Chef"),
            ("Jessica Brown", "@jbrown", "Traveler"),
            ("Chris Lee", "@clee", "Photographer"),
            ("Amanda Taylor", "@ataylor", "Yoga instructor"),
            ("Ryan Garcia", "@rgarcia", "Developer"),
            ("Michelle White", "@mwhite", "Designer"),
            ("Kevin Martinez", "@kmartinez", "Student"),
            ("Nicole Anderson", "@nanderson", "Entrepreneur")
        ]
        return names.map { name, username, bio in
            Peer(
                id: UUID().uuidString,
                displayName: name,
                username: username,
                bio: bio,
                signalStrength: Int.random(in: 3...5),
                hasActivity: Bool.random(),
                lastSeen: Date().addingTimeInterval(-Double.random(in: 0...3600)),
                isOnline: Bool.random()
            )
        }.shuffled()
    }
}

struct PulsingCircle: View {
    let color: Color
    let diameter: CGFloat
    @State private var animate = false
    var body: some View {
        Circle()
            .stroke(color.opacity(0.5), lineWidth: 6)
            .frame(width: diameter, height: diameter)
            .scaleEffect(animate ? 1.2 : 1)
            .opacity(animate ? 0.0 : 1.0)
            .animation(Animation.easeOut(duration: 1.5).repeatForever(autoreverses: false), value: animate)
            .onAppear { animate = true }
    }
}

struct PeerCardView: View {
    let peer: Peer
    var body: some View {
        HStack(spacing: 12) {
            // Gradient avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 50, height: 50)
                Text(String(peer.displayName.prefix(1)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                if peer.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2)
                        )
                        .offset(x: 18, y: 18)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                Text(peer.displayName)
                    .font(.body)
                    .fontWeight(.medium)
                Text(peer.username)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(peer.bio)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4) {
                // Signal bars
                HStack(spacing: 2) {
                    ForEach(1...5, id: \.self) { bar in
                        Rectangle()
                            .fill(bar <= peer.signalStrength ? Color.green : Color.gray.opacity(0.3))
                            .frame(width: 3, height: CGFloat(bar) * 3)
                            .cornerRadius(1.5)
                    }
                }
                if peer.hasActivity {
                    HStack(spacing: 4) {
                        Image(systemName: "dot.radiowaves.left.and.right")
                            .font(.caption2)
                            .foregroundColor(.blue)
                        Text("Active")
                            .font(.caption2)
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct PeerDetailView: View {
    let peer: Peer
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                ZStack {
                    Circle()
                        .fill(LinearGradient(
                            gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ))
                        .frame(width: 100, height: 100)
                    Text(String(peer.displayName.prefix(1)))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                VStack(spacing: 8) {
                    Text(peer.displayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    Text(peer.username)
                        .font(.body)
                        .foregroundColor(.secondary)
                    Text(peer.bio)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                HStack(spacing: 30) {
                    VStack {
                        Text("\(peer.signalStrength)")
                            .font(.title2)
                            .fontWeight(.bold)
                        Text("Signal")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    VStack {
                        Text(peer.isOnline ? "Online" : "Offline")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(peer.isOnline ? .green : .orange)
                        Text("Status")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                Spacer()
                Button("Start Chat") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Peer Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct Peer: Identifiable {
    let id: String
    let displayName: String
    let username: String
    let bio: String
    let signalStrength: Int
    let hasActivity: Bool
    let lastSeen: Date
    let isOnline: Bool
}

#Preview {
    DiscoverView()
} 