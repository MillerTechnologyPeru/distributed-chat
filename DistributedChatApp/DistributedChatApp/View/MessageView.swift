//
//  MessageView.swift
//  DistributedChatApp
//
//  Created by Fredrik on 2/1/21.
//

import DistributedChat
import SwiftUI

struct MessageView: View {
    let message: ChatMessage
    let controller: ChatController
    @Binding var replyingToMessageId: UUID?
    var onJumpToMessage: ((UUID) -> Void)? = nil
    
    @EnvironmentObject private var messages: Messages
    @EnvironmentObject private var settings: Settings
    
    var body: some View {
        let menuItems = Group {
            Button(action: {
                messages.deleteMessage(id: message.id)
            }) {
                Text("Delete Locally")
                Image(systemName: "trash")
            }
            Button(action: {
                replyingToMessageId = message.id
            }) {
                Text("Reply")
                Image(systemName: "arrowshape.turn.up.left.fill")
            }
            if messages.unread.contains(message.id) {
                Button(action: {
                    messages.unread.remove(message.id)
                }) {
                    Text("Mark as Read")
                    Image(systemName: "circlebadge")
                }
            } else {
                Button(action: {
                    messages.unread.insert(message.id)
                }) {
                    Text("Mark as Unread")
                    Image(systemName: "circlebadge.fill")
                }
            }
            Button(action: {
                UIPasteboard.general.string = message.content
            }) {
                Text("Copy")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                UIPasteboard.general.string = message.id.uuidString
            }) {
                Text("Copy Message ID")
                Image(systemName: "doc.on.doc")
            }
            Button(action: {
                UIPasteboard.general.url = URL(string: "distributedchat:///message/\(message.id)")
            }) {
                Text("Copy Message URL")
                Image(systemName: "doc.on.doc.fill")
            }
        }
        
        switch settings.presentation.messageHistoryStyle {
        case .compact:
            CompactMessageView(message: message)
                .contextMenu { menuItems }
        case .bubbles:
            let isMe = controller.me.id == message.author.id
            HStack {
                if isMe { Spacer() }
                BubbleMessageView(message: message, isMe: isMe) { repliedToId in
                    onJumpToMessage?(repliedToId)
                }
                .contextMenu { menuItems }
                if !isMe { Spacer() }
            }
        }
    }
}

struct MessageView_Previews: PreviewProvider {
    static let controller = ChatController(transport: MockTransport())
    static let alice = controller.me
    static let bob = ChatUser(name: "Bob")
    @StateObject static var messages = Messages(messages: [
        ChatMessage(author: alice, content: "Hello!"),
        ChatMessage(author: bob, content: "Hi!"),
        ChatMessage(author: bob, content: "This is fancy!"),
    ])
    @StateObject static var settings = Settings()
    @State static var replyingToMessageId: UUID? = nil
    static var previews: some View {
        MessageView(message: messages.messages.values.first { $0.content == "Hello!" }!, controller: controller, replyingToMessageId: $replyingToMessageId)
            .environmentObject(messages)
            .environmentObject(settings)
    }
}