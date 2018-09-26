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
    let ckRecordID: CKRecord.ID?
    weak var post: Post?
    
    init(commentText: String, timeStamp: Date = Date(), ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), post: Post) {
    self.commentText = commentText
    self.ckRecordID = ckRecordID
    self.post = post
    }
    
    init?(ckRecord: CKRecord){
        guard let commentText = ckRecord[CommentConstants.commentKey] as? String else { return nil }
        self.commentText = commentText
        self.ckRecordID = ckRecord.recordID
        
    }
    
    
    
}



struct CommentConstants {

    
    static let commentTypeKey = "Comment"
    static let commentKey = "CommentText"
    static let postReferenceKey = "PostReference"
    
}

extension CKRecord {
    
    convenience init?(comment: Comment) {
        guard let post = comment.post else {
            fatalError("Comment doesn't have a parrent")
        }
        guard let postCkrecordID = post.ckRecordID else {return nil}
        self.init(recordType: CommentConstants.commentTypeKey, recordID: comment.ckRecordID ?? CKRecord.ID(recordName: UUID().uuidString))
        self.setValue(comment.commentText, forKey: CommentConstants.commentKey)
        self.setValue(CKRecord.Reference(recordID: postCkrecordID, action: .deleteSelf), forKey: CommentConstants.postReferenceKey)
    }
}

extension Comment: SearchableRecord {
    func matchesSearchTerm(searchTerm: String) -> Bool {
        return commentText.lowercased().contains(searchTerm)
    }
    
    
}
