//
//  Comment.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import Foundation
import CloudKit

class Comment {
    let commentText: String
    var ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)
    weak var post: Post?
    let postReference: CKRecord.Reference
    var timeStamp: Date = Date()
    
    init(commentText: String, timeStamp: Date, post: Post, postReference: CKRecord.Reference) {
    self.commentText = commentText
    self.post = post
    self.postReference = postReference
    
    }
    
    init?(ckRecord: CKRecord){
        guard let commentText = ckRecord[CommentConstants.commentKey] as? String,
            let postReference = ckRecord[CommentConstants.postReferenceKey] as? CKRecord.Reference,
        let timeStamp = ckRecord[CommentConstants.timeStampKey] as? Date else { return nil }
        self.commentText = commentText
        self.ckRecordID = ckRecord.recordID
        self.postReference = postReference
        self.timeStamp = timeStamp
    
        
    }
    
    
    
}



struct CommentConstants {

    
    static let commentTypeKey = "Comment"
    static let commentKey = "CommentText"
    static let postReferenceKey = "PostReference"
    static let timeStampKey = "TimeStamp"
    
}

extension CKRecord {
    
    convenience init?(comment: Comment) {
        guard let post = comment.post else {
            fatalError("Comment doesn't have a parrent")
        }
        let postCkrecordID = post.ckRecordID
        self.init(recordType: CommentConstants.commentTypeKey, recordID: comment.ckRecordID)
        self.setValue(comment.commentText, forKey: CommentConstants.commentKey)
        self.setValue(comment.timeStamp, forKey: CommentConstants.timeStampKey)
        self.setValue(CKRecord.Reference(recordID: postCkrecordID, action: .deleteSelf), forKey: CommentConstants.postReferenceKey)
    }
}

extension Comment: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return commentText.lowercased().contains(searchTerm)
    }
    
    
}
