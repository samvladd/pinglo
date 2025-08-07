//
//  DiscoverView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct DiscoverView: View {
    @State private var nearbyUsers: [NearbyUser] = []
    @State private var isRefreshing = false
    @State private var meshActive = true
    @ObservedObject var chatManager: ChatManager
    @Binding var selectedTab: Int
    @Binding var chatToOpen: String?
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    init(chatManager: ChatManager, selectedTab: Binding<Int>, chatToOpen: Binding<String?>) {
        self.chatManager = chatManager
        self._selectedTab = selectedTab
        self._chatToOpen = chatToOpen
    }
    
    var body: some View {
            VStack(spacing: 0) {
            // Top section with title, profile, and refresh
            VStack(spacing: 16) {
                HStack {
                        // User profile picture with pulsating ring
                        ZStack {
                            // Pulsating ring behind everything
                            if meshActive {
                                PulsatingRing(color: globalAppearance.accentColor, diameter: 70)
                            }
                            
                            // Profile circle
                            Circle()
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [globalAppearance.accentColor.opacity(0.9), globalAppearance.accentColor.opacity(0.7)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 50, height: 50)
                                .shadow(color: globalAppearance.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                            
                            Text("You")
                            .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                        }
                        
                        Spacer()
                        
                                                // Title with enhanced glow effect
                        VStack(spacing: 2) {
                            Text("Discover")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.primary)
                                .shadow(color: meshActive ? globalAppearance.accentColor.opacity(0.4) : .clear, radius: 8, x: 0, y: 0)
                            
                            if meshActive {
                                Text("Mesh Network Active")
                                    .font(.caption2)
                                    .foregroundColor(globalAppearance.accentColor)
                            .fontWeight(.medium)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 8)
                            }
                    }
                        
                    Spacer()
                        
                        // Enhanced refresh button with radar animation
                        Button(action: {
                            Task { await refreshUsers() }
                        }) {
                            ZStack {
                                if isRefreshing {
                                    RadarSweepAnimation()
                                }
                                Circle()
                                    .fill(Color(.systemGray6))
                                    .frame(width: 40, height: 40)
                        Image(systemName: "arrow.clockwise")
                                    .font(.title3)
                                    .foregroundColor(globalAppearance.accentColor)
                            .rotationEffect(.degrees(isRefreshing ? 360 : 0))
                            .animation(isRefreshing ? .linear(duration: 1).repeatForever(autoreverses: false) : .default, value: isRefreshing)
                    }
                }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.horizontal, 20)
                    
                                        // Enhanced status line with scanning indicator
                    HStack(spacing: 0) {
                        Spacer()
                        
                        HStack(spacing: 8) {
                    Circle()
                                .fill(meshActive ? .green : .gray)
                                .frame(width: 8, height: 8)
                                .shadow(color: meshActive ? .green.opacity(0.3) : .clear, radius: 2)
                            
                            VStack(alignment: .leading, spacing: 1) {
                                Text(statusText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .fontWeight(.medium)
                                
                                if meshActive {
                                    Text("Scanning for nearby users...")
                                        .font(.caption2)
                                        .foregroundColor(globalAppearance.accentColor.opacity(0.8))
                                        .fontWeight(.medium)
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Enhanced scanning animation
                        if meshActive {
                            HStack(spacing: 3) {
                                ForEach(0..<4) { index in
                                    RoundedRectangle(cornerRadius: 1)
                                        .fill(globalAppearance.accentColor.opacity(0.7))
                                        .frame(width: 3, height: 12)
                                        .scaleEffect(y: 1.0)
                                        .animation(
                                            .easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true)
                                            .delay(Double(index) * 0.15),
                                            value: meshActive
                                        )
                                }
                            }
                        }
                        
                        Spacer()
                    }
                    .padding(.bottom, 12)
                }
                .padding(.top, 20)
                
                // Enhanced nearby users list
                if nearbyUsers.isEmpty && meshActive {
                    // Loading state with shimmer placeholders
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(0..<6, id: \.self) { _ in
                                ShimmerUserRow()
                                    .padding(.horizontal, 20)
                            }
                        }
                        .padding(.top, 8)
                    }
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(Array(nearbyUsers.enumerated()), id: \.element.id) { index, user in
                                NearbyUserRow(user: user)
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                            startChatWithUser(user)
                                        }
                                    }
                                    .transition(.asymmetric(
                                        insertion: .opacity.combined(with: .move(edge: .top)),
                                        removal: .opacity
                                    ))
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1), value: nearbyUsers.count)
                                    .scaleEffect(1.0)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: nearbyUsers.count)
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                }
                .background(Color(.systemGroupedBackground))
            .onAppear {
                loadUsers()
            }
    }
    
    private var statusText: String {
        if meshActive {
            if nearbyUsers.isEmpty {
                return "Mesh active – Searching for users..."
            } else {
                return "Mesh active – \(nearbyUsers.count) users nearby"
            }
        } else {
            return "Mesh inactive"
        }
    }
    
    private func loadUsers() {
        nearbyUsers = generateMockUsers()
    }
    
    private func refreshUsers() async {
        isRefreshing = true
        
        // Simulate radar scan
        try? await Task.sleep(nanoseconds: 1_500_000_000)
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            nearbyUsers = generateMockUsers()
        }
        
        isRefreshing = false
    }
    
    private func startChatWithUser(_ user: NearbyUser) {
        print("Starting chat with user: \(user.name)")
        
        // Check if chat already exists
        if chatManager.chats.contains(where: { $0.name == user.name }) {
            print("Chat already exists for \(user.name), navigating to existing chat")
            // Navigate to the Chats tab and select the existing chat
            DispatchQueue.main.async {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                    chatToOpen = user.name
                    selectedTab = 1  // Switch to Chats tab
                }
            }
            return
        }
        
        // Create a new chat and add it to the chat manager
        let newChat = user.toChat()
        chatManager.addNewChat(newChat)
        
        // Add initial welcome message
        let welcomeMessage = Message(
            id: UUID().uuidString,
            text: "Hi! I found you on Pinglo mesh network. Let's chat!",
            isFromMe: false,
            timestamp: Date()
        )
        chatManager.addMessage(to: newChat.id, message: welcomeMessage)
        
        // Navigate to the Chats tab
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                chatToOpen = user.name
                selectedTab = 1  // Switch to Chats tab
            }
        }
        
        print("Chat created successfully with \(user.name), navigating to Chats tab")
    }
    
    private func generateMockUsers() -> [NearbyUser] {
        let names = [
            ("Rachel Green", "@rgreen", 12),
            ("Alex Chen", "@achen", 8),
            ("Sarah Johnson", "@sjohnson", 15),
            ("Mike Rodriguez", "@mrodriguez", 6),
            ("Emma Davis", "@edavis", 22),
            ("David Kim", "@dkim", 11),
            ("Lisa Wang", "@lwang", 18),
            ("Tom Wilson", "@twilson", 9),
            ("Jessica Brown", "@jbrown", 14),
            ("Chris Lee", "@clee", 7)
        ]
        
        return names.map { name, username, distance in
            NearbyUser(
                id: UUID().uuidString,
                name: name,
                username: username,
                distance: distance,
                signalStrength: Int.random(in: 1...4),
                isOnline: Bool.random()
            )
        }.shuffled()
    }
}

struct PulsatingRing: View {
    let color: Color
    let diameter: CGFloat
    @State private var animate = false
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    var body: some View {
        Circle()
            .stroke(globalAppearance.accentColor.opacity(0.6), lineWidth: 2)
            .frame(width: diameter, height: diameter)
            .scaleEffect(animate ? 1.3 : 1.0)
            .opacity(animate ? 0.0 : 1.0)
            .animation(
                Animation.easeOut(duration: 2.0)
                    .repeatForever(autoreverses: false),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

struct RadarSweepAnimation: View {
    @State private var animate = false
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    var body: some View {
        Circle()
            .stroke(globalAppearance.accentColor.opacity(0.3), lineWidth: 1)
            .frame(width: 40, height: 40)
            .scaleEffect(animate ? 2.0 : 1.0)
            .opacity(animate ? 0.0 : 1.0)
            .animation(
                Animation.easeOut(duration: 1.0)
                    .repeatForever(autoreverses: false),
                value: animate
            )
            .onAppear {
                animate = true
            }
    }
}

struct NearbyUserRow: View {
    let user: NearbyUser
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Enhanced user avatar
            ZStack {
                Circle()
                    .fill(LinearGradient(
                        gradient: Gradient(colors: [globalAppearance.accentColor.opacity(0.9), globalAppearance.accentColor.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                    .frame(width: 52, height: 52)
                    .shadow(color: globalAppearance.accentColor.opacity(0.2), radius: 4, x: 0, y: 2)
                
                Text(String(user.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                // Add subtle gradient overlay
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.white.opacity(0.2),
                                Color.clear
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 52, height: 52)
                
                if user.isOnline {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color(.systemBackground), lineWidth: 2.5)
                        )
                        .offset(x: 19, y: 19)
                        .shadow(color: .green.opacity(0.3), radius: 2, x: 0, y: 1)
                }
            }
            
            // Enhanced user info
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Text(user.name)
                    .font(.body)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    if user.isOnline {
                        Text("• Online")
                            .font(.caption2)
                            .foregroundColor(.green)
                    .fontWeight(.medium)
                    }
                }
                
                HStack(spacing: 12) {
                    HStack(spacing: 4) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        .foregroundColor(.secondary)
                        Text("~\(user.distance)m away")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    HStack(spacing: 4) {
                        Image(systemName: "wifi")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("\(user.signalStrength)/4")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // Enhanced signal strength bars
            VStack(spacing: 4) {
                HStack(spacing: 2) {
                    ForEach(1...4, id: \.self) { bar in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(bar <= user.signalStrength ? 
                                  (user.signalStrength >= 3 ? globalAppearance.accentColor : globalAppearance.accentColor.opacity(0.7)) : 
                                  Color.gray.opacity(0.2))
                            .frame(width: 4, height: CGFloat(bar) * 5)
                            .animation(.easeInOut(duration: 0.2), value: user.signalStrength)
                    }
                }
                
                HStack(spacing: 2) {
                    Image(systemName: "wifi")
                        .font(.caption2)
                        .foregroundColor(globalAppearance.accentColor)
                    Text("Signal")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .fontWeight(.medium)
                }
            }
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.08), radius: 3, x: 0, y: 2)
        )
        .contentShape(Rectangle())
    }
}

struct NearbyUser: Identifiable {
    let id: String
    let name: String
    let username: String
    let distance: Int
    let signalStrength: Int
    let isOnline: Bool
    
    func toChat() -> Chat {
        return Chat(
            id: id,
            name: name,
            username: username,
            lastMessage: "",
            timestamp: Date(),
            unreadCount: 0,
            isOnline: isOnline
        )
    }
}

struct ShimmerUserRow: View {
    @State private var phase: CGFloat = 0
    var body: some View {
        HStack(spacing: 16) {
            RoundedRectangle(cornerRadius: 26)
                .fill(shimmer)
                .frame(width: 52, height: 52)
            VStack(alignment: .leading, spacing: 8) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(shimmer)
                    .frame(width: 140, height: 12)
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(shimmer)
                        .frame(width: 80, height: 10)
                    RoundedRectangle(cornerRadius: 6)
                        .fill(shimmer)
                        .frame(width: 60, height: 10)
                }
            }
            Spacer()
            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { i in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(shimmer)
                        .frame(width: 4, height: CGFloat(4 + i * 5))
                }
            }
        }
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
        )
        .onAppear {
            withAnimation(.linear(duration: 1.2).repeatForever(autoreverses: false)) {
                phase = 1
            }
        }
    }
    private var shimmer: LinearGradient {
        let base = Color(.systemGray5)
        let highlight = Color.white.opacity(0.7)
        return LinearGradient(
            gradient: Gradient(colors: [base.opacity(0.6), highlight, base.opacity(0.6)]),
            startPoint: .leading,
            endPoint: .trailing
        )
    }
}

#Preview {
    DiscoverView(chatManager: ChatManager(), selectedTab: .constant(0), chatToOpen: .constant(nil))
} 