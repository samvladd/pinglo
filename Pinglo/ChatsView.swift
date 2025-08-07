//
//  ChatsView.swift
//  Pinglo
//
//  Created by Shmuli V on 8/4/25.

import SwiftUI
import UIKit
import Combine

struct ChatsView: View {
    @State private var searchText = ""
    @State private var selectedChat: Chat?
    @ObservedObject var chatManager: ChatManager
    @Binding var chatToOpen: String?
    @StateObject private var globalAppearance = GlobalAppearance.shared
    @Binding var selectedTab: Int
    
    // Delete confirmation & undo
    @State private var chatPendingDelete: Chat? = nil
    @State private var showDeleteConfirm: Bool = false
    @State private var deletedSnapshot: ChatManager.DeletedSnapshot? = nil
    @State private var showUndoBanner: Bool = false
    
    // Failed toast
    @State private var showFailedToast: Bool = false
    @State private var failedToastText: String = ""
    @State private var failedToastChatId: String = ""
    @State private var failedToastMessageId: String = ""
    
    init(chatManager: ChatManager = ChatManager(), chatToOpen: Binding<String?> = .constant(nil), selectedTab: Binding<Int> = .constant(1)) {
        self.chatManager = chatManager
        self._chatToOpen = chatToOpen
        self._selectedTab = selectedTab
    }
    
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

    private func presentDeleteConfirm(for chat: Chat) {
        chatPendingDelete = chat
        chatManager.freezeRealtimeUpdates()
        withAnimation(nil) {
            showDeleteConfirm = true
        }
    }

    private func handleListDelete(at offsets: IndexSet) {
        let ids = offsets.compactMap { filteredChats[safe: $0]?.id }
        guard let firstId = ids.first, let chat = chatManager.chats.first(where: { $0.id == firstId }) else { return }
        presentDeleteConfirm(for: chat)
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
        VStack(spacing: 0) {
            // Search bar
                HStack {
                    HStack(spacing: 12) {
                    Image(systemName: "magnifyingglass")
                            .foregroundColor(globalAppearance.accentColor)
                            .font(.title3)
                    TextField("Search chats", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                    }
                    .padding(16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.systemGray6))
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(globalAppearance.accentColor.opacity(0.2), lineWidth: 1)
                            )
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 4)
                .padding(.bottom, 28)
                
                // Chat list (always render for consistent layout)
                List {
                    ForEach(filteredChats) { chat in
                        ChatRowView(chat: chat, chatManager: chatManager)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedChat = chat
                                chatManager.markChatAsRead(chatId: chat.id)
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    presentDeleteConfirm(for: chat)
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                                .tint(.red)
                                Button {
                                    if chat.unreadCount > 0 {
                                        chatManager.markChatAsRead(chatId: chat.id)
                                    } else {
                                        chatManager.markChatAsUnread(chatId: chat.id)
                                    }
                                } label: {
                                    if chat.unreadCount > 0 {
                                        Label("Mark Read", systemImage: "envelope.open")
                                    } else {
                                        Label("Mark Unread", systemImage: "envelope.badge")
                                    }
                                }
                            }
                            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                                Button {
                                    chatManager.togglePin(chatId: chat.id)
                                } label: {
                                    Label(chat.isPinned ? "Unpin" : "Pin", systemImage: chat.isPinned ? "pin.slash" : "pin")
                                }
                                .tint(.orange)
                                Button {
                                    chatManager.toggleMute(chatId: chat.id)
                                } label: {
                                    Label(chat.isMuted ? "Unmute" : "Mute", systemImage: chat.isMuted ? "bell" : "bell.slash")
                                }
                                .tint(.gray)
                            }
                            .listRowBackground(Color(.systemBackground))
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets(top: 6, leading: 8, bottom: 6, trailing: 8))
                    }
                    .onDelete(perform: handleListDelete)
                }
                .listStyle(PlainListStyle())
                .animation(nil, value: showDeleteConfirm)
                .refreshable { await chatManager.refreshChats() }
                
                .overlay(alignment: .top) {
                    if filteredChats.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "person.3")
                                .font(.largeTitle)
                                .foregroundColor(.secondary)
                            Text("Find users to start a chat")
                                .font(.headline)
                                .foregroundColor(.primary)
                            Button(action: { withAnimation { selectedTab = 0 } }) {
                                Text("Discover Nearby")
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 10)
                                    .background(Capsule().fill(globalAppearance.accentColor))
                                    .foregroundColor(.white)
                            }
                        }
                        .padding(.top, 8)
                    }
                }

            }
            
            // Undo banner
            if showUndoBanner, let snap = deletedSnapshot {
                HStack {
                    Text("Chat deleted").foregroundColor(.white)
                    Spacer()
                    Button("Undo") {
                        chatManager.restoreDeletedChat(snap)
                        deletedSnapshot = nil
                        withAnimation { showUndoBanner = false }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.black.opacity(0.85)))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            
            // Failed toast
            if showFailedToast {
                HStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill").foregroundColor(.white)
                    Text(failedToastText).foregroundColor(.white)
                    Spacer()
                    Button("Retry") {
                        chatManager.retryMessage(chatId: failedToastChatId, messageId: failedToastMessageId)
                        withAnimation { showFailedToast = false }
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 12).fill(Color.red.opacity(0.9)))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle("Chats")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) { selectedTab = 0 }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(globalAppearance.accentColor)
                }
                .accessibilityLabel("Find users to chat with")
            }
        }
        .navigationDestination(item: $selectedChat) { chat in
            ChatDetailView(chat: chat, chatManager: chatManager)
        }
        .onAppear { chatManager.startSimulatingMessages() }
        .onDisappear { chatManager.stopSimulatingMessages() }
        .onChange(of: chatToOpen) { _, newValue in
            if let chatName = newValue, let chat = chatManager.selectChatByName(chatName) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                    withAnimation(.easeInOut(duration: 0.2)) { selectedChat = chat }
                    chatToOpen = nil
                }
            }
        }
        .onChange(of: showDeleteConfirm) { _, isPresented in
            if !isPresented {
                chatManager.unfreezeRealtimeUpdates()
                chatPendingDelete = nil
            }
        }
        .onReceive(chatManager.$lastSendFailure.compactMap { $0 }) { failure in
            failedToastChatId = failure.chatId
            failedToastMessageId = failure.messageId
            failedToastText = "Failed to send to \(failure.chatName)"
            withAnimation { showFailedToast = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 4.0) {
                withAnimation { showFailedToast = false }
            }
        }
        .confirmationDialog("Are you sure you want to delete this chat?", isPresented: $showDeleteConfirm, titleVisibility: .visible) {
            Button("Delete Chat", role: .destructive) {
                if let chat = chatPendingDelete {
                    if selectedChat?.id == chat.id { selectedChat = nil }
                    if let snap = chatManager.deleteChatWithSnapshot(id: chat.id) {
                        deletedSnapshot = snap
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUndoBanner = true }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                            withAnimation(.spring(response: 0.35, dampingFraction: 0.85)) { showUndoBanner = false }
                            deletedSnapshot = nil
                        }
                    }
                    chatManager.unfreezeRealtimeUpdates()
                }
            }
            Button("Cancel", role: .cancel) {
                chatPendingDelete = nil
                chatManager.unfreezeRealtimeUpdates()
            }
        }
    }
}

struct ChatRowView: View {
    let chat: Chat
    @ObservedObject var chatManager: ChatManager
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    private var currentChat: Chat? { chatManager.chats.first { $0.id == chat.id } }
    private var unreadCountValue: Int { currentChat?.unreadCount ?? chat.unreadCount }
    private var lastMessageObject: Message? { chatManager.getMessages(for: chat.id).last }
    private var lastFailedOutgoing: Bool { (lastMessageObject?.isFromMe ?? false) && (lastMessageObject?.status == .failed) }
    private var isPinnedValue: Bool { currentChat?.isPinned ?? chat.isPinned }
    private var isMutedValue: Bool { currentChat?.isMuted ?? chat.isMuted }
    
    var body: some View {
        HStack(spacing: 12) {
            // Avatar with subtle mute overlay
                Circle()
                    .fill(LinearGradient(
                    gradient: Gradient(colors: [globalAppearance.accentColor.opacity(0.9), globalAppearance.accentColor.opacity(0.7)]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ))
                .frame(width: 52, height: 52)
                .shadow(color: globalAppearance.accentColor.opacity(0.3), radius: 6, x: 0, y: 3)
                .overlay(
                    Text(String(currentChat?.name.prefix(1) ?? chat.name.prefix(1)))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                )
                .overlay(alignment: .topTrailing) {
                    if isMutedValue {
                    Circle()
                            .fill(Color.black.opacity(0.35))
                            .frame(width: 20, height: 20)
                        .overlay(
                                Image(systemName: "bell.slash.fill")
                                    .font(.system(size: 10))
                                    .foregroundColor(.white)
                            )
                            .offset(x: -2, y: 2)
                    }
                }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 6) {
                    if isPinnedValue {
                        Image(systemName: "pin.fill").font(.caption).foregroundColor(.orange)
                    }
                    Text(currentChat?.name ?? chat.name)
                        .font(unreadCountValue > 0 ? .headline : .body)
                        .fontWeight(unreadCountValue > 0 ? .bold : .medium)
                    .foregroundColor(.primary)
                    if isMutedValue {
                        Image(systemName: "bell.slash.fill").font(.caption).foregroundColor(.secondary)
            }
            Spacer()
                    Text(currentChat?.formattedTimestamp ?? chat.formattedTimestamp)
                        .font(.caption)
                        .fontWeight(unreadCountValue > 0 ? .semibold : .regular)
                        .foregroundColor(unreadCountValue > 0 ? globalAppearance.accentColor : .secondary)
                }
                HStack {
                    Text(currentChat?.lastMessage ?? chat.lastMessage)
                        .font(.subheadline)
                        .foregroundColor(lastFailedOutgoing ? .red : (unreadCountValue > 0 ? .primary : .secondary))
                        .lineLimit(1)
                        .truncationMode(.tail)
                    Spacer()
                    if lastFailedOutgoing {
                        Text("Failed")
                            .font(.caption)
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(Color.red))
                            .shadow(color: Color.red.opacity(0.25), radius: 3, x: 0, y: 1)
                    } else if unreadCountValue > 0 {
                        Text(unreadCountValue > 99 ? "99+" : "\(unreadCountValue)")
                            .font(.caption)
                            .fontWeight(.heavy)
                        .foregroundColor(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Capsule().fill(globalAppearance.accentColor))
                            .shadow(color: globalAppearance.accentColor.opacity(0.3), radius: 3, x: 0, y: 1)
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        )
        .contentShape(Rectangle())
    }
}

struct ChatDetailView: View {
    let chat: Chat
    @ObservedObject var chatManager: ChatManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    @State private var messageText = ""
    @State private var showUserProfile = false
    @State private var groupedCached: [MessageGroup] = []
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    private var messages: [Message] {
        chatManager.getMessages(for: chat.id)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Messages
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(groupedCached, id: \.date) { group in
                            // Date separator
                            DateSeparatorView(date: group.date)
                            // Messages for this date
                            ForEach(group.messages) { message in
                            MessageBubbleView(message: message)
                                .id(message.id)
                            }
                        }
                    }
                    .padding()
                }
                .background(Color(.systemGroupedBackground))
                .onAppear {
                    recomputeGroupedAsync()
                    scrollToBottom(proxy: proxy)
                }
                .onChange(of: messages.count) { _, _ in
                    recomputeGroupedAsync()
                    scrollToBottom(proxy: proxy)
                }
                .simultaneousGesture(
                    DragGesture()
                        .onChanged { _ in
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }
                )
            }
            
            // Divider line
            Divider()
                .background(Color(.separator))
            
            // Input bar (isolated to avoid re-rendering the list while typing)
            MessageInputBar(messageText: $messageText, onSend: { sendMessage() })
            .padding()
            .background(Color(.systemBackground))
        }
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button(action: {
                    showUserProfile = true
                }) {
                    HStack(spacing: 8) {
                        Text(chat.name)
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                        Image(systemName: "chevron.down")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showUserProfile = true }) {
                    Image(systemName: "person.circle.fill")
                        .font(.title2)
                        .foregroundColor(globalAppearance.accentColor)
                }
            }
        }
        .navigationBarBackButtonHidden(false)
        .sheet(isPresented: $showUserProfile) { UserProfileView(chat: chat) }
        .onAppear {
            chatManager.setActiveChat(chat.id)
            chatManager.markChatAsRead(chatId: chat.id)
        }
        .onDisappear { chatManager.setActiveChat(nil) }
    }
    
    private func recomputeGroupedAsync() {
        let snapshot = messages
        DispatchQueue.global(qos: .userInitiated).async {
            let calendar = Calendar.current
            let groupedDict = Dictionary(grouping: snapshot) { message in
                calendar.startOfDay(for: message.timestamp)
            }
            let grouped = groupedDict.map { (date, msgs) in
                MessageGroup(date: date, messages: msgs.sorted { $0.timestamp < $1.timestamp })
            }.sorted { $0.date < $1.date }
            DispatchQueue.main.async {
                self.groupedCached = grouped
            }
        }
    }
    
    private func scrollToBottom(proxy: ScrollViewProxy) {
        if let last = messages.last {
            withAnimation(.easeOut(duration: 0.2)) {
                proxy.scrollTo(last.id, anchor: .bottom)
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
        messageText = ""
        #if os(iOS)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        #endif
        chatManager.addMessage(to: chat.id, message: newMessage)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            let responses = ["Thanks! 👍","Got it!","Sounds good","I'll get back to you","Perfect!","On it!","Great idea!","Will do!","Got your message","Thanks for letting me know"]
            let response = responses.randomElement() ?? "OK"
            let responseMessage = Message(id: UUID().uuidString, text: response, isFromMe: false, timestamp: Date())
            self.chatManager.addMessage(to: self.chat.id, message: responseMessage)
        }
    }
}

struct MessageInputBar: View {
    @Binding var messageText: String
    var onSend: () -> Void
    @StateObject private var globalAppearance = GlobalAppearance.shared
    var body: some View {
        HStack(spacing: 12) {
            HStack {
                TextField("Message", text: $messageText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .submitLabel(.send)
                    .onSubmit { onSend() }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(20)
            
            Button(action: { onSend() }) {
                Image(systemName: "arrow.up.circle.fill")
                    .foregroundColor(messageText.isEmpty ? .gray : globalAppearance.accentColor)
                    .font(.title2)
            }
            .disabled(messageText.isEmpty)
        }
    }
}

struct MessageBubbleView: View {
    let message: Message
    @Environment(\.colorScheme) private var colorScheme
    @State private var showCopyMenu = false
    @StateObject private var globalAppearance = GlobalAppearance.shared
    
    var body: some View {
        HStack {
            if message.isFromMe {
                Spacer()
            }
            
            VStack(alignment: message.isFromMe ? .trailing : .leading, spacing: 4) {
                Text(message.text)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(message.isFromMe ? globalAppearance.accentColor : (colorScheme == .dark ? Color(.systemGray5) : Color(.systemGray4)))
                    .foregroundColor(message.isFromMe ? .white : .primary)
                    .cornerRadius(18)
                    .contextMenu {
                        Button(action: {
                            UIPasteboard.general.string = message.text
                        }) {
                            Label("Copy", systemImage: "doc.on.doc")
                        }
                        
                        if message.isFromMe && message.status == .failed {
                            Button(action: {
                                // TODO: Implement retry
                            }) {
                                Label("Retry", systemImage: "arrow.clockwise")
                            }
                        }
                    }
                
                HStack(spacing: 4) {
                Text(formatTimestamp(message.timestamp))
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    
                    if message.isFromMe {
                        Image(systemName: message.status.icon)
                            .font(.caption2)
                            .foregroundColor(message.status.color)
                    }
                }
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
    private var isFrozen: Bool = false
    
    // Store all messages for each chat
    private var chatMessages: [String: [Message]] = [:]
    
    // Track which chat is currently active
    private var activeChatId: String?
    
    private var pendingChangeNotify = false
    
    // For failed message retry
    @Published var lastSendFailure: (chatId: String, messageId: String, chatName: String)? = nil
    
    struct DeletedSnapshot: Identifiable { let id: String; let chat: Chat; let messages: [Message] }
    
    init() {
        loadInitialData()
    }
    
    private func loadInitialData() {
        let now = Date()
        
        // Initialize messages first
        loadInitialMessages(now: now)
        
        // Create initial chats with matching last messages
        chats = [
            Chat(id: "1", name: "Sarah Johnson", username: "@sjohnson", lastMessage: "Hey! How's it going?", timestamp: now.addingTimeInterval(-300), unreadCount: 1, isOnline: true),
            Chat(id: "2", name: "Mike Chen", username: "@mchen", lastMessage: "Meeting at 3 PM today", timestamp: now.addingTimeInterval(-1800), unreadCount: 0, isOnline: false),
            Chat(id: "3", name: "Emma Davis", username: "@edavis", lastMessage: "How's your progress?", timestamp: now.addingTimeInterval(-3600), unreadCount: 1, isOnline: true),
            Chat(id: "4", name: "Alex Rodriguez", username: "@arodriguez", lastMessage: "Can you send me the files?", timestamp: now.addingTimeInterval(-7200), unreadCount: 0, isOnline: false),
            Chat(id: "5", name: "Lisa Wang", username: "@lwang", lastMessage: "Great work on the presentation!", timestamp: now.addingTimeInterval(-86400), unreadCount: 1, isOnline: true),
            Chat(id: "6", name: "David Kim", username: "@dkim", lastMessage: "Let's catch up soon", timestamp: now.addingTimeInterval(-172800), unreadCount: 0, isOnline: false),
            Chat(id: "7", name: "Rachel Green", username: "@rgreen", lastMessage: "Happy birthday! 🎉", timestamp: now.addingTimeInterval(-259200), unreadCount: 0, isOnline: true),
            Chat(id: "8", name: "Tom Wilson", username: "@twilson", lastMessage: "Project deadline moved to Friday", timestamp: now.addingTimeInterval(-345600), unreadCount: 1, isOnline: false)
        ]
        
        // Sort chats by most recent activity
        sortChats()
        
        print("Loaded initial data with \(chats.count) chats and \(chatMessages.count) message histories")
    }
    
    private func loadInitialMessages(now: Date) {
        chatMessages["1"] = [
            Message(id: "1", text: "Hey! How's it going?", isFromMe: false, timestamp: now.addingTimeInterval(-300))
        ]
        
        chatMessages["2"] = [
            Message(id: "1", text: "Meeting at 3 PM today", isFromMe: false, timestamp: now.addingTimeInterval(-1800))
        ]
        
        chatMessages["3"] = [
            Message(id: "1", text: "How's your progress?", isFromMe: false, timestamp: now.addingTimeInterval(-3600))
        ]
        
        chatMessages["4"] = [
            Message(id: "1", text: "Can you send me the files?", isFromMe: false, timestamp: now.addingTimeInterval(-7200))
        ]
        
        chatMessages["5"] = [
            Message(id: "1", text: "Great work on the presentation!", isFromMe: false, timestamp: now.addingTimeInterval(-86400))
        ]
        
        chatMessages["6"] = [
            Message(id: "1", text: "Let's catch up soon", isFromMe: false, timestamp: now.addingTimeInterval(-172800))
        ]
        
        chatMessages["7"] = [
            Message(id: "1", text: "Happy birthday! 🎉", isFromMe: false, timestamp: now.addingTimeInterval(-259200))
        ]
        
        chatMessages["8"] = [
            Message(id: "1", text: "Project deadline moved to Friday", isFromMe: false, timestamp: now.addingTimeInterval(-345600))
        ]
    }
    
    func getMessages(for chatId: String) -> [Message] {
        return chatMessages[chatId] ?? []
    }
    
    func setActiveChat(_ chatId: String?) {
        activeChatId = chatId
        print("Set active chat to: \(chatId ?? "none")")
    }
    
    func isChatActive(_ chatId: String) -> Bool {
        return activeChatId == chatId
    }
    
    func markChatAsRead(chatId: String) {
        print("Marking chat \(chatId) as read")
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].unreadCount = 0
            print("Set unread count to 0 for chat \(chatId)")
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    func addNewChat(_ chat: Chat) {
        // Check if chat already exists by name (not just ID)
        if !chats.contains(where: { $0.name == chat.name }) {
            chats.append(chat)
            chatMessages[chat.id] = []
            sortChats()
            print("Added new chat: \(chat.name)")
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        } else {
            print("Chat with name \(chat.name) already exists, not creating duplicate")
        }
    }
    
    func selectChatByName(_ name: String) -> Chat? {
        return chats.first(where: { $0.name == name })
    }
    
    func addMessage(to chatId: String, message: Message) {
        print("Adding message to chat \(chatId): \(message.text)")
        
        var msg = message
        
        // Ensure array exists
        if chatMessages[chatId] == nil {
            chatMessages[chatId] = []
        }
        
        // For outbound messages, start as sending
        if msg.isFromMe {
            msg.status = .sending
        }
        
        // Append message
        chatMessages[chatId]?.append(msg)
        
        // Update chat preview with the new message
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].lastMessage = msg.text
            chats[index].timestamp = msg.timestamp
            
            // Only increment unread count if message is from other person AND chat is not currently active AND chat is not muted
            if !msg.isFromMe {
                if !isChatActive(chatId) {
                    if !chats[index].isMuted {
                        chats[index].unreadCount += 1
                        print("Incremented unread count for chat \(chatId) - chat not active and not muted")
                    } else {
                        print("Muted chat \(chatId) - not incrementing unread")
                    }
                } else {
                    print("Not incrementing unread count for chat \(chatId) - chat is active")
                }
            }
            
            print("Updated chat preview: \(chats[index].lastMessage)")
            
            // Move this specific chat to top (most recent); pinned chats stay on top by sort
            sortChats()
        }
        
        // Drive mock status updates for outbound messages
        if msg.isFromMe {
            let messageId = msg.id
            // 1) mark as sent shortly after
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.updateMessageStatus(chatId: chatId, messageId: messageId, status: .sent)
            }
            // 2) then delivered or failed
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                let delivered = Int.random(in: 0..<100) < 85 // 85% delivered
                let next: MessageStatus = delivered ? .delivered : .failed
                self.updateMessageStatus(chatId: chatId, messageId: messageId, status: next)
                #if os(iOS)
                if delivered {
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                } else {
                    UINotificationFeedbackGenerator().notificationOccurred(.error)
                }
                #endif
            }
        }
        
        // Force UI update
        DispatchQueue.main.async {
            self.objectWillChange.send()
        }
    }
    
    private func updateMessageStatus(chatId: String, messageId: String, status: MessageStatus) {
        guard var array = chatMessages[chatId], let idx = array.firstIndex(where: { $0.id == messageId }) else { return }
        array[idx].status = status
        let isFromMe = array[idx].isFromMe
        chatMessages[chatId] = array
        if status == .failed && isFromMe, let chatName = chats.first(where: { $0.id == chatId })?.name {
            lastSendFailure = (chatId, messageId, chatName)
        }
        scheduleChangeNotify()
    }
    
    private func scheduleChangeNotify() {
        if pendingChangeNotify { return }
        pendingChangeNotify = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.pendingChangeNotify = false
            self.objectWillChange.send()
        }
    }
    
    // Delete chat with snapshot (for undo)
    func deleteChatWithSnapshot(id: String) -> DeletedSnapshot? {
        guard let chat = chats.first(where: { $0.id == id }) else { return nil }
        let messages = chatMessages[id] ?? []
        chats.removeAll { $0.id == id }
        chatMessages[id] = nil
        scheduleChangeNotify()
        return DeletedSnapshot(id: id, chat: chat, messages: messages)
    }
    
    func restoreDeletedChat(_ snapshot: DeletedSnapshot) {
        chats.append(snapshot.chat)
        chatMessages[snapshot.id] = snapshot.messages
        sortChats()
        scheduleChangeNotify()
    }
    
    // Delete without snapshot
    func deleteChat(id: String) {
        chats.removeAll { $0.id == id }
        chatMessages[id] = nil
        scheduleChangeNotify()
    }
    
    func togglePin(chatId: String) {
        guard let idx = chats.firstIndex(where: { $0.id == chatId }) else { return }
        chats[idx].isPinned.toggle()
        sortChats()
        scheduleChangeNotify()
    }
    
    func toggleMute(chatId: String) {
        guard let idx = chats.firstIndex(where: { $0.id == chatId }) else { return }
        chats[idx].isMuted.toggle()
        scheduleChangeNotify()
    }
    
    func markChatAsUnread(chatId: String) {
        if let index = chats.firstIndex(where: { $0.id == chatId }) {
            chats[index].unreadCount = max(1, chats[index].unreadCount)
            scheduleChangeNotify()
        }
    }
    
    private func sortChats() {
        chats.sort {
            if $0.isPinned != $1.isPinned { return $0.isPinned && !$1.isPinned }
            return $0.timestamp > $1.timestamp
        }
    }
    
    func startSimulatingMessages() {
        guard !isFrozen else { return }
        messageSimulationTimer = Timer.scheduledTimer(withTimeInterval: 20.0, repeats: true) { _ in
            self.simulateIncomingMessage()
        }
    }
    
    func stopSimulatingMessages() {
        messageSimulationTimer?.invalidate()
        messageSimulationTimer = nil
    }
    
    func freezeRealtimeUpdates() {
        isFrozen = true
        stopSimulatingMessages()
    }
    
    func unfreezeRealtimeUpdates() {
        isFrozen = false
        startSimulatingMessages()
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
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        objectWillChange.send()
    }
    
    func retryMessage(chatId: String, messageId: String) {
        guard var array = chatMessages[chatId], let idx = array.firstIndex(where: { $0.id == messageId }) else { return }
        array[idx].status = .sending
        chatMessages[chatId] = array
        scheduleChangeNotify()
        // mock send again -> sent -> delivered
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.updateMessageStatus(chatId: chatId, messageId: messageId, status: .sent)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.updateMessageStatus(chatId: chatId, messageId: messageId, status: .delivered)
        }
    }
}

// Safe index access for arrays
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
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
    var isPinned: Bool = false
    var isMuted: Bool = false
    
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
    
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: Chat, rhs: Chat) -> Bool { lhs.id == rhs.id }
}

struct Message: Identifiable {
    let id: String
    let text: String
    let isFromMe: Bool
    let timestamp: Date
    var status: MessageStatus = .sending
}

enum MessageStatus: String {
    case sending = "sending"
    case sent = "sent"
    case delivered = "delivered"
    case failed = "failed"
    
    var icon: String {
        switch self {
        case .sending: return "clock"
        case .sent: return "checkmark"
        case .delivered: return "checkmark.circle"
        case .failed: return "exclamationmark.circle"
        }
    }
    
    var color: Color {
        switch self {
        case .sending: return .gray
        case .sent: return .blue
        case .delivered: return .green
        case .failed: return .red
        }
    }
}

struct MessageGroup {
    let date: Date
    let messages: [Message]
}

struct DateSeparatorView: View {
    let date: Date
    
    var body: some View {
        HStack {
            Spacer()
            Text(formatDate(date))
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(Color(.systemGray6))
                .cornerRadius(12)
            Spacer()
        }
        .padding(.vertical, 8)
    }
    
    private func formatDate(_ date: Date) -> String {
        let calendar = Calendar.current
        
        if calendar.isDateInToday(date) {
            return "Today"
        } else if calendar.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }
}

struct UserProfileView: View {
    let chat: Chat
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Profile Image
                    ZStack {
                        Circle()
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue.opacity(0.8), Color.purple.opacity(0.6)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .frame(width: 120, height: 120)
                        
                        Text(String(chat.name.prefix(1)))
                            .font(.system(size: 48, weight: .semibold))
                            .foregroundColor(.white)
                        
                        if chat.isOnline {
                            Circle()
                                .fill(Color.green)
                                .frame(width: 24, height: 24)
                                .overlay(
                                    Circle()
                                        .stroke(Color(.systemBackground), lineWidth: 3)
                                )
                                .offset(x: 40, y: 40)
                        }
                    }
                    
                    // User Info
                    VStack(spacing: 8) {
                        Text(chat.name)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text(chat.username)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        HStack(spacing: 4) {
                            Circle()
                                .fill(chat.isOnline ? .green : .gray)
                                .frame(width: 8, height: 8)
                            Text(chat.isOnline ? "Online" : "Offline")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    

                    
                    // User Details
                    VStack(spacing: 0) {
                        DetailRow(icon: "wifi", title: "Signal Strength", value: "Excellent", iconColor: .green)
                        Divider()
                        DetailRow(icon: "calendar", title: "Joined Pinglo", value: "March 2024", iconColor: .blue)
                        Divider()
                        DetailRow(icon: "message.circle", title: "Last Active", value: "2 minutes ago", iconColor: .orange)
                        Divider()
                        DetailRow(icon: "globe", title: "Sign up country", value: "United States", iconColor: .purple)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(16)
                    
                    // Additional Actions
                    VStack(spacing: 12) {
                        ActionButton(title: "Block User", icon: "slash.circle", color: .red) {
                            // TODO: Block user
                        }
                        
                        ActionButton(title: "Report User", icon: "exclamationmark.triangle", color: .orange) {
                            // TODO: Report user
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.medium)
                }
            }
        }
    }
}

struct DetailRow: View {
    let icon: String
    let title: String
    let value: String
    let iconColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .frame(width: 20)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            Text(value)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct ActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .foregroundColor(color)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(color.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

#Preview {
    ChatsView(chatManager: ChatManager(), chatToOpen: .constant(nil))
} 
