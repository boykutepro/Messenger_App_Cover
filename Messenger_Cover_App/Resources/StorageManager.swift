//
//  StorageManager.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/22/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    
    /*
        /images/tung-gmail-com_profile_picture.png
     */
    
    public typealias UploadPictureCompletion = (Result<String, Error>)
    
    /// Uploads picture to firebase storage and returns completion with url string to dowload.
    public func uploadProfilePicture(with data: Data,
                                     fileName: String,
                                     completion: @escaping (UploadPictureCompletion) -> Void) {
        
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (metadata, error) in
            guard error == nil else {
                //failed
                print("Tải hình ảnh lên firebase thất bại")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL { (url, error) in
                guard let url = url else {
                    print("Tải về URL thất bại")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download URL returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadURL
    }
}
