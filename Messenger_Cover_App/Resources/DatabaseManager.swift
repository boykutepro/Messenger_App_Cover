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
                completion(true)
        })
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
