//
//  User.swift
//  Continuum
//
//  Created by Levi Linchenko on 27/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit
import CloudKit

class User: CKPhotoSavable {
    var tempURL: URL?
    var recordID: CKRecord.ID
    var username: String
    var userEmail: String
    var password: String
    var imageData: Data?
    var profileImage: UIImage?{
        get{
            guard let imageData = imageData else {return nil}
            return UIImage(data: imageData)
        } set {
            imageData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    var followers: [CKRecord.Reference]?
    var following: [CKRecord.Reference]?
    var posts: [CKRecord.Reference]?
    
    init(recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), username: String, userEmail: String, password: String, followers: [CKRecord.Reference] = [], following: [CKRecord.Reference] = [], posts: [CKRecord.Reference] = []){
        self.recordID = recordID
        self.username = username
        self.userEmail = userEmail
        self.password = password
        self.followers = followers
        self.following = following
        self.posts = posts
    
    }
    
    
    
    convenience init?(ckRecord: CKRecord){
        guard let username = ckRecord[UserKeys.UserNameKey] as? String,
            let userEmail = ckRecord[UserKeys.UserEmailKey] as? String,
            let password = ckRecord[UserKeys.PasswordKey] as? String,
            let followers = ckRecord[UserKeys.FollowersKey] as? [CKRecord.Reference],
            let following = ckRecord[UserKeys.FollowingKey] as? [CKRecord.Reference],
            let posts = ckRecord[UserKeys.PostsKey] as? [CKRecord.Reference]
            //let profileImageAsset = ckRecord[UserKeys.ProfileImageKey] as? CKAsset,
            //let data = try? Data(contentsOf: profileImageAsset.fileURL),
            //let profileImage = UIImage(data: data)
            else {print("User initializer failed \(#file)");return nil}
        
        self.init(recordID: ckRecord.recordID, username: username, userEmail: userEmail, password: password, followers: followers, following: following, posts: posts)
        
    }
    

   

    
    
    
    
    
    
}

struct UserKeys {
    static let UserTypeKey = "User"
    static let UserNameKey = "Username"
    static let UserEmailKey = "UserEmail"
    static let PasswordKey = "Password"
    static let FollowersKey = "Followers"
    static let FollowingKey = "Following"
    static let PostsKey = "PostsKey"
    static let ProfileImageKey = "ProfileImage"
}


extension CKRecord {
    convenience init(user: inout User){
        self.init(recordType: UserKeys.UserTypeKey, recordID: user.recordID)
        self.setValue(user.username, forKey: UserKeys.UserNameKey)
        self.setValue(user.userEmail, forKey: UserKeys.UserEmailKey)
        self.setValue(user.password, forKey: UserKeys.PasswordKey)
        self.setValue(user.followers, forKey: UserKeys.FollowersKey)
        self.setValue(user.following, forKey: UserKeys.FollowingKey)
        self.setValue(user.posts, forKey: UserKeys.PostsKey)
        self.setValue(user.imageAsset, forKey: UserKeys.ProfileImageKey)
        
    }
}

extension User: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        if username.lowercased().contains(searchTerm) ||  userEmail.lowercased().contains(searchTerm) {
            return true
        }  else {return false}
    }
    
    
}




