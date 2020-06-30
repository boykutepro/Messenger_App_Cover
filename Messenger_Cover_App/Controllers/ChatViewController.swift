//
//  ChatViewController.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/22/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
    public var sender: SenderType
    public var messageId: String
    public var sentDate: Date
    public var kind: MessageKind
}

extension MessageKind {
    var messageKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
    public var photoURL: String
    public var senderId: String
    public var displayName: String
}
class ChatViewController: MessagesViewController {
    
    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    } ()

    public var isNewConversation = false
    private var conversationID: String?
    public var otherUserEmail: String = ""
    
    private var messages = [Message] ()
    
    private var selfSender: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        return Sender(photoURL: "",
                      senderId: email,
                      displayName: "Thien Tung")
    }
    init(with email: String) {
        self.otherUserEmail = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        messages.append(Message(sender: selfSender,
//                                messageId: "1",
//                                sentDate: Date(),
//                                kind: .text("Hello my Friend")))
//        messages.append(Message(sender: selfSender,
//                                       messageId: "1",
//                                       sentDate: Date(),
//                                       kind: .text("Hello my friend Hello my friend Hello my friend Hello my friend Hello my friend")))
        
        view.backgroundColor = .blue
        
        messagesCollectionView.messagesDataSource = self
        //messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate{
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
            let selfSender = self.selfSender,
            let messageID = createMessageID() else {
                return
        }
        
        print("Sending: \(text)")
        
        //Send message
        if isNewConversation {
            //create convo in database
            let message = Message(sender: selfSender,
                                  messageId: messageID,
                                  sentDate: Date(),
                                  kind: .text(text))
            
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.title ?? "User", firstMessage: message) { [weak self] (success) in
                if success {
                    print("Message sent")
                    self?.isNewConversation = false
                    //let newConversationID = "conversation_\(message.messageId)"
                    //self?.conversationID = newConversationID
                } else {
                    print("Failed to send")
                }
            }
            
        } else {
            // append to existing conversation data
          
        }
    }
    
    private func createMessageID() -> String? {
        // Date, Other email, sender Email.
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                return nil
        }
        
        let safeCurrentEmail = DatabaseManager.safeEmail(emailAddress: currentUserEmail)
        
        let dateString = ChatViewController.self.dateFormatter.string(from: Date())
        let newIdentifier = "\(otherUserEmail)_\(safeCurrentEmail)_\(dateString)"
        
        print("Created MesID: \(newIdentifier)")
        return newIdentifier
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self Sender is nil")
        return Sender(photoURL: "", senderId: "12", displayName: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
