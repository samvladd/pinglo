//
//  PersistenceController.swift
//  Pinglo
//
//  Created by Pinglo Team on 8/4/25.
//

import CoreData

class PersistenceController {
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Pinglo")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed to load store: \(error)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    // MARK: - Save Context
    func save() {
        let context = container.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                print("Failed to save context: \(error)")
            }
        }
    }
    
    // MARK: - Chat Operations
    func fetchChats() -> [CDChat] {
        let request: NSFetchRequest<CDChat> = CDChat.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDChat.timestamp, ascending: false)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch chats: \(error)")
            return []
        }
    }
    
    func createOrUpdateChat(id: String, name: String, username: String, lastMessage: String, timestamp: Date, unreadCount: Int16, isOnline: Bool) -> CDChat {
        let request: NSFetchRequest<CDChat> = CDChat.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id)
        
        let chat: CDChat
        if let existingChat = try? container.viewContext.fetch(request).first {
            chat = existingChat
        } else {
            chat = CDChat(context: container.viewContext)
            chat.id = id
        }
        
        chat.name = name
        chat.username = username
        chat.lastMessage = lastMessage
        chat.timestamp = timestamp
        chat.unreadCount = unreadCount
        chat.isOnline = isOnline
        
        save()
        return chat
    }
    
    // MARK: - Message Operations
    func addMessage(to chatId: String, id: String, text: String, isFromMe: Bool, timestamp: Date, status: String = "sent") -> CDMessage? {
        let chatRequest: NSFetchRequest<CDChat> = CDChat.fetchRequest()
        chatRequest.predicate = NSPredicate(format: "id == %@", chatId)
        
        guard let chat = try? container.viewContext.fetch(chatRequest).first else {
            print("Chat not found for ID: \(chatId)")
            return nil
        }
        
        let message = CDMessage(context: container.viewContext)
        message.id = id
        message.text = text
        message.isFromMe = isFromMe
        message.timestamp = timestamp
        message.status = status
        message.chat = chat
        
        // Update chat's last message
        chat.lastMessage = text
        chat.timestamp = timestamp
        
        save()
        return message
    }
    
    func updateMessageStatus(messageId: String, status: String) {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", messageId)
        
        if let message = try? container.viewContext.fetch(request).first {
            message.status = status
            save()
        }
    }
    
    func fetchMessages(for chatId: String) -> [CDMessage] {
        let request: NSFetchRequest<CDMessage> = CDMessage.fetchRequest()
        request.predicate = NSPredicate(format: "chat.id == %@", chatId)
        request.sortDescriptors = [NSSortDescriptor(keyPath: \CDMessage.timestamp, ascending: true)]
        
        do {
            return try container.viewContext.fetch(request)
        } catch {
            print("Failed to fetch messages: \(error)")
            return []
        }
    }
}
