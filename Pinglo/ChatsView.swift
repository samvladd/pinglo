//
//  ChatsView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.
//

import SwiftUI

struct ChatsView: View {
    @State private var searchText = ""
    @State private var selectedChat: Chat?
    @StateObject private var chatManager = ChatManager()
    
    var filteredChats: [Chat] {
        if searchText.isEmpty {
            return chatManager.chats
        } else {
            return chatManager.chats.filter { 
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.username.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search chats", text: $searchText)
                }
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(10)
            }
            .padding(.horizontal)
            .padding(.bottom, 10)
            
            // Chat list
            List(filteredChats) { chat in
                ChatRowView(chat: chat)
                    .contentShape(Rectangle())
                                    .onTapGesture {
                    selectedChat = chat
                }
            }
            .listStyle(PlainListStyle())
            .refreshable {
                // Simulate refresh
                await chatManager.refreshChats()
            }
        }
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Show new chat
                }) {
                    Image(systemName: "plus")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationDestination(item: $selectedChat) { chat in
            ChatDetailView(chat: chat, chatManager: chatManager)
                .onAppear {
                    // Mark chat as read when detail view appears
                    chatManager.markChatAsRead(chatId: chat.id)
                }
        }
        .onAppear {
            chatManager.startSimulatingMessages()
        }
        .onDisappear {
            chatManager.stopSimulatingMessages()
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    
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
                Text(String(chat.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                if chat.isOnline {
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
                HStack {
                    Text(chat.name)
                        .font(.body)
                        .fontWeight(chat.unreadCount > 0 ? .semibold : .medium)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(chat.formattedTimestamp)
                        .font(.caption)
                        .foregroundColor(chat.unreadCount > 0 ? .blue : .secondary)
                }
                
                HStack {
                    Text(chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(chat.unreadCount > 0 ? .primary : .secondary)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    
                    // Unread count badge
                    if chat.unreadCount > 0 {
                        Text("\(chat.unreadCount)")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(minWidth: 20, minHeight: 20)
                            .background(Color.blue)
                            .clipShape(Capsule())
                            .scaleEffect(chat.unreadCount > 99 ? 0.8 : 1.0)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
}

struct ChatDetailView: View {
    let chat: Chat
    let chatManager: ChatManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var messageText = ""
    @State private var messages: [Message] = []
    @State private var lastMessageId: String = ""
    @State private var isNearBottom = true
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    loadSampleMessages()
                }
                .onChange(of: lastMessageId) { oldValue, newValue in
                    if !newValue.isEmpty {
                        withAnimation(.easeOut(duration: 0.3)) {
                            proxy.scrollTo(newValue, anchor: .bottom)
                        }
                    }
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            // Dismiss keyboard when scrolling
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)) { _ in
                    // When keyboard shows, scroll to bottom if near bottom
                    if isNearBottom {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            withAnimation(.easeOut(duration: 0.3)) {
                                if let lastMessage = messages.last {
                                    proxy.scrollTo(lastMessage.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
            }
            
            // Divider line
            Divider()
                .background(Color(.separator))
            
            // Input bar
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Add attachment
                }) {
                    Image(systemName: "paperclip")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                
                HStack {
                    TextField("Message", text: $messageText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onSubmit {
                            sendMessage()
                        }
                    
                    Button(action: {
                        sendMessage()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .foregroundColor(messageText.isEmpty ? .gray : .blue)
                            .font(.title2)
                    }
                    .disabled(messageText.isEmpty)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle(chat.name)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // TODO: Show chat options
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.blue)
                }
            }
        }
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        let newMessage = Message(
            id: UUID().uuidString,
            text: messageText,
            isFromMe: true,
            timestamp: Date()
        )
        
        messages.append(newMessage)
        messageText = ""
        
        // Update chat manager with new message
        chatManager.addMessage(to: chat.id, message: newMessage)
        
        // Always scroll to bottom when sending a message
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            lastMessageId = newMessage.id
        }
        
        // Simulate response after 1-3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 1...3)) {
            let responses = [
                "Thanks! 👍",
                "Got it!",
                "Sounds good",
                "I'll get back to you",
                "Perfect!",
                "On it!",
                "Great idea!",
                "Will do!",
                "Got your message",
                "Thanks for letting me know"
            ]
            
            let response = responses.randomElement() ?? "OK"
            let responseMessage = Message(
                id: UUID().uuidString,
                text: response,
                isFromMe: false,
                timestamp: Date()
            )
            
            messages.append(responseMessage)
            
            // Update chat manager with response
            chatManager.addMessage(to: chat.id, message: responseMessage)
            
            // Auto-scroll to response
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                lastMessageId = responseMessage.id
            }
        }
    }
    
    private func loadSampleMessages() {
        let sampleMessages = [
            Message(id: "1", text: "Hey! How's it going?", isFromMe: false, timestamp: Date().addingTimeInterval(-3600)),
            Message(id: "2", text: "Pretty good! Working on the project", isFromMe: true, timestamp: Date().addingTimeInterval(-3500)),
            Message(id: "3", text: "How's your progress?", isFromMe: false, timestamp: Date().addingTimeInterval(-3400)),
            Message(id: "4", text: "Almost done with the first phase", isFromMe: true, timestamp: Date().addingTimeInterval(-3300)),
            Message(id: "5", text: "That's great! Can't wait to see it", isFromMe: false, timestamp: Date().addingTimeInterval(-3200))
        ]
        
        messages = sampleMessages
    }
}

struct MessageBubbleView: View {
    let message: Message
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
            }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? Color.blue : (colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray4)))
                    .foregroundColor(message.isFromMe ? .white : .primary)
                    .cornerRadius(18)
                
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 4)
            }
            
            if !message.isFromMe {
                Spacer()
            }
        }
        .padding(.horizontal, 8)
    }
    
    private func formatTimestamp(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

// MARK: - Chat Manager
class ChatManager: ObservableObject {
    @Published var chats: [Chat] = []
    private var messageSimulationTimer: Timer?
    
    init() {
        loadInitialChats()
    }
    
    private func loadInitialChats() {
        chats = [
            Chat(id: "1", name: "Sarah Johnson", username: "@sjohnson", lastMessage: "Hey! How's the project going?", timestamp: Date().addingTimeInterval(-900), unreadCount: 1, isOnline: true),
            Chat(id: "2", name: "Mike Chen", username: "@mchen", lastMessage: "Meeting at 3 PM today", timestamp: Date().addingTimeInterval(-6300), unreadCount: 0, isOnline: false),
            Chat(id: "3", name: "Emma Davis", username: "@edavis", lastMessage: "Thanks for the help!", timestamp: Date().addingTimeInterval(-7200), unreadCount: 1, isOnline: true),
            Chat(id: "4", name: "Alex Rodriguez", username: "@arodriguez", lastMessage: "Can you send me the files?", timestamp: Date().addingTimeInterval(-39600), unreadCount: 0, isOnline: false),
            Chat(id: "5", name: "Lisa Wang", username: "@lwang", lastMessage: "Great work on the presentation!", timestamp: Date().addingTimeInterval(-86400), unreadCount: 1, isOnline: true),
            Chat(id: "6", name: "David Kim", username: "@dkim", lastMessage: "Let's catch up soon", timestamp: Date().addingTimeInterval(-172800), unreadCount: 0, isOnline: false),
            Chat(id: "7", name: "Rachel Green", username: "@rgreen", lastMessage: "Happy birthday! 🎉", timestamp: Date().addingTimeInterval(-259200), unreadCount: 0, isOnline: true),
            Chat(id: "8", name: "Tom Wilson", username: "@twilson", lastMessage: "Project deadline moved to Friday", timestamp: Date().addingTimeInterval(-345600), unreadCount: 1, isOnline: false)
        ]
        
        // Sort chats by most recent activity
        sortChats()
    }
    
    func markChatAsRead(chatId: String) {
        DispatchQueue.main.async {
            if let index = self.chats.firstIndex(where: { $0.id == chatId }) {
                self.chats[index].unreadCount = 0
                self.objectWillChange.send()
            }
        }
    }
    
    func addMessage(to chatId: String, message: Message) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            // Update chat with new message
            chats[index].lastMessage = message.text
            chats[index].timestamp = message.timestamp
            
            // Increment unread count if message is from other person
            if !message.isFromMe {
                chats[index].unreadCount += 1
            }
            
            // Move chat to top (most recent)
            sortChats()
        }
    }
    
    private func sortChats() {
        chats.sort { $0.timestamp > $1.timestamp }
    }
    
    func startSimulatingMessages() {
        messageSimulationTimer = Timer.scheduledTimer(withTimeInterval: 15.0, repeats: true) { _ in
            self.simulateIncomingMessage()
        }
    }
    
    func stopSimulatingMessages() {
        messageSimulationTimer?.invalidate()
        messageSimulationTimer = nil
    }
    
    private func simulateIncomingMessage() {
        let randomChats = chats.filter { $0.isOnline }.shuffled()
        guard let randomChat = randomChats.first else { return }
        
        let sampleMessages = [
            "Hey, quick question!",
            "Did you see the latest update?",
            "Thanks for your help!",
            "Can we schedule a call?",
            "Great work on this!",
            "I'll send you the details",
            "Let me know when you're free",
            "Perfect timing!",
            "Looking forward to it!",
            "Thanks for the update"
        ]
        
        let randomMessage = sampleMessages.randomElement() ?? "Hello!"
        let newMessage = Message(
            id: UUID().uuidString,
            text: randomMessage,
            isFromMe: false,
            timestamp: Date()
        )
        
        addMessage(to: randomChat.id, message: newMessage)
    }
    
    @MainActor
    func refreshChats() async {
        // Simulate network delay
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // Update timestamps to be more recent
        for i in 0..<chats.count {
            chats[i].timestamp = Date().addingTimeInterval(-Double.random(in: 0...3600))
        }
        
        sortChats()
    }
}

// MARK: - Data Models
struct Chat: Identifiable, Hashable {
    let id: String
    let name: String
    let username: String
    var lastMessage: String
    var timestamp: Date
    var unreadCount: Int
    let isOnline: Bool
    
    var formattedTimestamp: String {
        let now = Date()
        let timeDifference = now.timeIntervalSince(timestamp)
        
        if timeDifference < 60 {
            return "now"
        } else if timeDifference < 3600 {
            let minutes = Int(timeDifference / 60)
            return "\(minutes)m"
        } else if timeDifference < 86400 {
            let hours = Int(timeDifference / 3600)
            return "\(hours)h"
        } else if timeDifference < 172800 {
            return "Yesterday"
        } else {
            let days = Int(timeDifference / 86400)
            return "\(days)d"
        }
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Chat, rhs: Chat) -> Bool {
        lhs.id == rhs.id
    }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let isFromMe: Bool
    let timestamp: Date
}

#Preview {
    ChatsView()
} 