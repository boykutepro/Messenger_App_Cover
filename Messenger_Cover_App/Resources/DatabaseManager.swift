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
    
    
}


//MARK: - Account Management
extension DatabaseManager {
    
    
    public func userExists(with email: String,
                           completion: @escaping (Bool) -> Void) {
        //function get data out of the database is a synchronous so need a completion block.
        
        database.child(email).observeSingleEvent(of: .value) { (snapshot) in
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
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue([
            "first_name" : user.firstName,
            "last_name" : user.lastName
        ])
    }
}


struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
 //   let profilePictureUrl: String
}
