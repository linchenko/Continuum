//
//  Post.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit
import CloudKit

class Post: CKPhotoSavable{
    var tempURL: URL?
    var imageData: Data?
    deinit {
        self.deinitURL()
    }
    
    
    var caption: String
    var likeCount: [CKRecord.Reference] = []
    var comments: [Comment]?
    let timeStamp: Date
    var user: CKRecord.Reference
    let ckRecordID: CKRecord.ID
    var image: UIImage?{
        get{
            guard let imageData = imageData else {return nil}
            return UIImage(data: imageData)
        } set {
            imageData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    init(caption: String, image: UIImage, likeCount: [CKRecord.Reference] = [], comments: [Comment] = [], timeStamp: Date = Date(), user: CKRecord.Reference, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.likeCount = likeCount
        self.comments = comments
        self.timeStamp = timeStamp
        self.user = user
        self.ckRecordID = ckRecordID
        self.image = image
    }
    
    init?(ckRecord: CKRecord){
        guard let caption = ckRecord[PostConstants.captionKey] as? String,
            let timeStamp = ckRecord[PostConstants.timeStampKey] as? Date,
            let user = ckRecord[PostConstants.userReferenceKey] as? CKRecord.Reference,
            let imageAsset = ckRecord[PostConstants.imageKey] as? CKAsset else {print("💩💩💩💩💩💩💩");return nil}
        
        self.likeCount = ckRecord[PostConstants.likeCountKey] as? [CKRecord.Reference] ?? []
        self.timeStamp = timeStamp
        self.user = user
        
        self.caption = caption
        self.ckRecordID = ckRecord.recordID
        guard let data = try? Data(contentsOf: imageAsset.fileURL) else {return}

        self.image = UIImage(data: data)
    }
    

    

    
 
}






struct PostConstants {
    static let postTypeKey = "Post"
    static let captionKey = "Caption"
    static let imageKey = "Image"
    static let likeCountKey = "LikeCount"
    static let timeStampKey = "TimeStamp"
    static let userReferenceKey = "UserReference"
    

}

extension CKRecord {
    convenience init(post: inout Post) {
        self.init(recordType: PostConstants.postTypeKey, recordID: post.ckRecordID)
        self.setValue(post.caption, forKey: PostConstants.captionKey)
        self.setValue(post.likeCount, forKey: PostConstants.likeCountKey)
        self.setValue(post.timeStamp, forKey: PostConstants.timeStampKey)
        self.setValue(post.imageAsset, forKey: PostConstants.imageKey)
        
    }
    
}

extension Post: SearchableRecord{
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return caption.lowercased().contains(searchTerm.lowercased())
    }
    
    
}
