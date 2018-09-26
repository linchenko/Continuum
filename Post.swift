//
//  Post.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit
import CloudKit

class Post{
    
    var caption: String
    var imageData: Data?
    var likeCount: Int
    var comments: [Comment]?
    let timeStamp: Date
    let ckRecordID: CKRecord.ID?
    var image: UIImage?{
        get{
            guard let imageData = imageData else {return nil}
            return UIImage(data: imageData)
        } set {
            imageData = newValue?.jpegData(compressionQuality: 0.6)
        }
    }
    
    init(caption: String, image: UIImage, likeCount: Int = 0, comments: [Comment] = [], timeStamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.caption = caption
        self.likeCount = likeCount
        self.comments = comments
        self.timeStamp = timeStamp
        self.ckRecordID = ckRecordID
        self.image = image
    }
    
    init?(ckRecord: CKRecord){
        guard let caption = ckRecord[PostConstants.captionKey] as? String,
            let timeStamp = ckRecord[PostConstants.timeStampKey] as? Date,
            let likeCount = ckRecord[PostConstants.likeCountKey] as? Int,
            let imageAsset = ckRecord[PostConstants.imageKey] as? CKAsset else {print("💩💩💩💩💩💩💩");return nil}
        
        self.timeStamp = timeStamp
        self.likeCount = likeCount
        self.caption = caption
        self.ckRecordID = ckRecord.recordID
        guard let data = try? Data(contentsOf: imageAsset.fileURL) else {return}

        self.image = UIImage(data: data)
    }
    
//    convenience init?(ckRecord: CKRecord){
//        guard let caption = ckRecord[PostConstants.captionKey],
//        let image = UIImage(data: <#T##Data#>)
//    }
    
    
    var tempURL: URL?
    var imageAsset: CKAsset? {
        get {
            let tempDirectory = NSTemporaryDirectory()
            let tempDirecotryURL = URL(fileURLWithPath: tempDirectory)
            let fileURL = tempDirecotryURL.appendingPathComponent(UUID().uuidString).appendingPathExtension("jpg")
            self.tempURL = fileURL
            do {
                try imageData?.write(to: fileURL)
            } catch let error {
                print("Error writing to temp url \(error) \(error.localizedDescription)")
            }
            return CKAsset(fileURL: fileURL)
        }
    }
    
    
    
}






struct PostConstants {
    static let postTypeKey = "Post"
    static let captionKey = "Caption"
    static let imageKey = "Image"
    static let likeCountKey = "LikeCount"
    static let timeStampKey = "TimeStamp"
    

}

extension CKRecord {
    convenience init(post: Post) {
        self.init(recordType: PostConstants.postTypeKey, recordID: post.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString))
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
