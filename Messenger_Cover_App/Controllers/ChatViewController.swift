//
//  ChatViewController.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/22/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}
class ChatViewController: MessagesViewController {

    private var messages = [Message] ()
    
    private let selfSender = Sender(photoURL: "",
                                    senderId: "1",
                                    displayName: "Thien Tung")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        messages.append(Message(sender: selfSender,
                                messageId: "1",
                                sentDate: Date(),
                                kind: .text("Hello my Friend")))
        messages.append(Message(sender: selfSender,
                                       messageId: "1",
                                       sentDate: Date(),
                                       kind: .text("Hello my friend Hello my friend Hello my friend Hello my friend Hello my friend")))
        
        view.backgroundColor = .blue
        
        messagesCollectionView.messagesDataSource = self
        //messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return selfSender
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    
}
