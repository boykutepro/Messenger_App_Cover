//
//  DatabaseManager.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/13/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
}


//MARK: - Account Management
extension DatabaseManager {
    
    
    public func userExists(with email: String,
                           completion: @escaping (Bool) -> Void) {
        //function get data out of the database is a synchronous so need a completion block.
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        // Firebase database cho phép ta nhìn thấy sự thay đổi của giá trị trên bất cứ mục nào
        // trong cơ sở dữ liệu tuần tự của bạn bằng cách chỉ định "child" bạn muốn và chọn loại
        // quan sát nào. <observe: quan sát>.
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
        // this snapshot has a value property opposite that can be optional if it doesn't exist
            //guard let foundEmail = snapshot.value as? String else {
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    
    //Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
            ], withCompletionBlock: { error, _  in
                guard error == nil else {
                    print("Faild to write to database")
                    completion(false)
                    return
                }
              
                // Add users to array of user
                self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                    if var usersCollection = snapshot.value as? [[String: String]] {
                        // Append to users dictionary
                        let newElement = [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                        usersCollection.append(newElement)
                        
                        self.database.child("users").setValue(usersCollection, withCompletionBlock: {
                            error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            completion(true)
                        })
                        
                    } else {
                        // Create that dictionary. With first user sign up
                        let newCollection: [[String: String]] = [
                            [
                                "name": user.firstName + " " + user.lastName,
                                "email": user.safeEmail
                            ]
                        ]
                        
                        self.database.child("users").setValue(newCollection, withCompletionBlock: {
                            error, _ in
                            guard error == nil else {
                                completion(false)
                                return
                            }
                            
                            completion(true)
                        })
                    }
                }
//                completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseErrors.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
    
    public enum DatabaseErrors: Error {
        case failedToFetch
    }
    
    /*
        users = >
                 [
                    [
                        "name":
                        "safe_email":
                    ],
                    [
                        "name":
                        "safe_email":
                    ]
                 ]
    */
}

//  MARK: -Sending messages / conversations
extension DatabaseManager {
    
    /*
        conversationID {
            "messages" : [
                {
                    "id": String,
                    "type": text, photo, video,
                    "content": String,
                    "date": Date(),
                    "sender_email": String,
                    "isRead": Bool,
                }
            ]
        }
     
        conversation =>
            [
                [
                    "conversation_id": "conversationID"
                    "other_user_email":
                    "latest_message": => {
                        "date": Date()
                        "latest_message": "message"
                        "is_read": bool
                    }
                ],
            ]
    */
    
    /// Creates a new conversation with target user email and first message sent.
    public func createNewConversation(with otherUserEmail: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        guard let currentEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        let safeEmail = DatabaseManager.safeEmail(emailAddress: currentEmail)
        
        let referrence = database.child(safeEmail)
        
        referrence.observeSingleEvent(of: .value, with: { (snapshot) in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User not found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
            
            let newConversationData: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false,
                ]
            ]
            
            if var conversations = userNode["conversations"] as? [[String: Any]] {
                /// Tồn tại cuộc trò chuyện của người dùng hiện tại
                
                // Nối thêm vào
                conversations.append(newConversationData)
                userNode["conversations"] = conversations
                referrence.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                     firstMessage: firstMessage,
                                                     completion: completion)
                }
            } else {
                // Tạo mới
                userNode["conversations"] = [
                    newConversationData
                ]
                
                referrence.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(conversationID: conversationID,
                                                    firstMessage: firstMessage,
                                                    completion: completion)
                }
            }
        })
    }
    
    private func finishCreatingConversation(conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
//        "id": String,
//        "type": text, photo, video,
//        "content": String,
//        "date": Date(),
//        "sender_email": String,
//        "isRead": Bool,
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
               
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .custom(_):
            break
        }
        
        guard let myEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            completion(false)
            return
        }
        
        let currentUserEmail = DatabaseManager.safeEmail(emailAddress: myEmail)
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.messageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "isRead": false ,
        ]
        
        let value: [String: Any] = [
            "messages": [
                collectionMessage
            ]
        ]
        
        database.child(conversationID).setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Fetches and returns all conversations for the user with passed in email
    public func getAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Get all messages for a given convesation
    public func getAllMessagesForConversation(with id: String, completion: @escaping (Result<String, Error>) -> Void) {
        
    }
    
    /// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, message: Message) {
        
    }
}

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureFileName: String {
      //  /images/tung-gmail-com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
}


