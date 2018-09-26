//
//  PostController.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit
import CloudKit

class PostController {
    
    
    static let shared = PostController()
    let publicDB = CKContainer.default().publicCloudDatabase
    
    var posts:[Post] = []{
        didSet{
            
        NotificationCenter.default.post(name: postsUpdatedNotificationName, object: nil)
        }
    }
    let postsUpdatedNotificationName = Notification.Name("PostsWereUpdated")
    
    func createPost(caption: String, image: UIImage, completion: @escaping (Post)->Void){
        let post = Post(caption: caption, image: image)
        posts.append(post)
        let record = CKRecord(post: post)
        save(record)
    }
    //FIXME:
    func addComment(commentText: String, post: Post?, completion: @escaping (Comment?)->Void){
        guard let post = post,
        let ckRecordID = post.ckRecordID else {return}
        let comment = Comment(commentText: commentText, ckRecordID: ckRecordID, post: post)
        post.comments?.append(comment)
        guard let record = CKRecord(comment: comment) else {return}
        save(record)
    
    }
    
    
    func save(_ record: CKRecord){
        publicDB.save(record) { (record, error) in
            if let error = error {
                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
                return
            }
        }
    }
    
    func fetchCommentsFor(post: Post?, completion: @escaping()->Void){
        guard let post = post,
            let recordID = post.ckRecordID else {return}
        let predicate = NSPredicate(format: "recordName == @", recordID)
        let query = CKQuery(recordType: CommentConstants.commentTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
            }
            guard let records = records else {return}
            let comments = records.compactMap{ Comment(ckRecord: $0)}
            post.comments?.append(contentsOf: comments)
        }
        

        
//        publicDB.fetch(withRecordID: recordID) { (record, error) in
//            if let error = error {
//                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
//            }
//        }
    }
    
    func fetchPosts(completion: @escaping()->Void){
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: PostConstants.postTypeKey, predicate: predicate)
        publicDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error{
                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
                return
            }
            let posts = records?.compactMap{Post(ckRecord: $0)}
            guard let postsArray = posts else {return}
            self.posts = postsArray
        }
    }
    
    func checkAccountStatus(completion: @escaping (_ osLoggedIn: Bool) -> Void){
        CKContainer.default().accountStatus { (status, error) in
            if let error = error {
                print ("💩💩 error checking acount status in function \(#function), \(error.localizedDescription)💩💩")
                completion(false); return
            } else {
                let errorTitle = "Sign into iCloud in Settings"
                switch status {
                case .available:
                    completion(true)
                    print("Singed into account")
                case .couldNotDetermine:
                    self.presentiCloudAlert(errorTitle: errorTitle, errorMessage: "Error With iCloud Acount")
                    completion(false)
                case .noAccount:
                    self.presentiCloudAlert(errorTitle: errorTitle, errorMessage: "No acount Found")
                    completion(false)
                case .restricted:
                    self.presentiCloudAlert(errorTitle: errorTitle, errorMessage: "Restricted iCloud Account")
                    completion(false)
                }
            }
        }
    }
    
    func presentiCloudAlert(errorTitle: String, errorMessage: String){
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "Done", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate,
                let appWindow = appDelegate.window!,
                let rootViewController = appWindow.rootViewController {
                rootViewController.present(alertController, animated: true)
            }
        }
        
    }
    
    func subscribeToRecord(completionHandler: @escaping (CKSubscription?, Error?) -> Void){
        
        let predicate = NSPredicate(value: true)
        let subcription = CKQuerySubscription(recordType: CommentConstants.commentTypeKey, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertActionLocalizationKey = "Update in Continuum"
        notificationInfo.alertBody = "Someone just posted, see what you're missing!"
        notificationInfo.soundName = "default"
        notificationInfo.shouldBadge = true
        subcription.notificationInfo = notificationInfo
        
        
        CKContainer.default().publicCloudDatabase.save(subcription) { (subscription, error) in
            if let error = error{
                print ("💩💩 error in function \(#function), \(error.localizedDescription), error subscribing to notification💩💩")
                completionHandler(nil, error); return
            }
            print(subcription.subscriptionID)
            completionHandler(subcription, nil)
        }
        
    }
        
    
    func addSubcriptionTo(commentsFor post: Post, completion: @escaping(_ success: Bool) -> Void){
        guard let recordID = post.ckRecordID else {return}
        let predicate = NSPredicate(format: "recordID == %@", recordID)
        //FIXME:
        let ckSubscription = CKQuerySubscription(recordType: PostConstants.postTypeKey, predicate: predicate, options: [.firesOnRecordCreation, .firesOnRecordUpdate])
        
        let notificationInfo = CKSubscription.NotificationInfo()
        notificationInfo.alertBody = "New Comment"
        notificationInfo.shouldSendContentAvailable = true
        notificationInfo.shouldBadge = true
        ckSubscription.notificationInfo = notificationInfo
        publicDB.save(ckSubscription) { (subscription, error) in
            if let error = error {
                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
            }
        }
            
    }
    
    func removeSubscriptionTo(commentsForPost post: Post, completion: @escaping(Bool)->Void){
        
        publicDB.delete(withSubscriptionID: (post.ckRecordID?.recordName)!) { (string, error) in
            if let error = error {
                print ("💩💩 error in function \(#function), \(error.localizedDescription)💩💩")
            }
        }
    }
    
    func checkSubscription(to post: Post, completion: @escaping(_ subscribed: Bool)->Void){
       
        publicDB.fetch(withSubscriptionID: (post.ckRecordID?.recordName)!) { (subsciption, error) in
            if let error = error{
                print ("💩💩 error in function \(#function), \(error) \(error.localizedDescription)💩💩")
                completion(false)
                return
            }
            if subsciption != nil{
            completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func toggleSubscriptionTo(commentsForPost post: Post, completion: @escaping (_ status: Bool)->Void){
       
        checkSubscription(to: post) { (success) in
            if success {
                self.removeSubscriptionTo(commentsForPost: post, completion: { (success) in
                })
                completion(true)
            } else {
                self.addSubcriptionTo(commentsFor: post, completion: { (success) in
                })
                completion(false)
            }
            
        }
    }
    
        
    
    
    
    
}
