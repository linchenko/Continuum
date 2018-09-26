//
//  PostDetailViewController.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit
import CloudKit


class PostDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
    @IBOutlet weak var userOutlet: UILabel!
    @IBOutlet weak var captionOutlet: UITextField!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var commentsLabel: UILabel!
    @IBOutlet weak var likeCountOutlet: UIBarButtonItem!
    @IBOutlet weak var imageOutlet: UIImageView!
    @IBOutlet weak var addCommentOutlet: UITextField!
    @IBOutlet weak var commentButtonOutlet: UIButton!
    @IBOutlet weak var toolBarOutlet: UIToolbar!
    @IBOutlet weak var addImageOutlet: UIButton!
    @IBOutlet weak var followOutlet: UIBarButtonItem!
    
    
    var picker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        PostController.shared.fetchCommentsFor(post: post) { (comments) in
            guard let comments = comments else {return}
            DispatchQueue.main.async {
                let comments = comments.compactMap{$0.commentText}
                
                self.commentsLabel.text = "Comments\(comments)"
            }

        }
        
        
        picker.delegate = self
        
        
        userOutlet.isHidden = true
        if post == nil {
            captionLabel.isHidden = true
            commentsLabel.isHidden = true
            addCommentOutlet.isHidden = true
            commentButtonOutlet.isHidden = true
            toolBarOutlet.isHidden = true
        } else {
            guard let post = post else {return}
            addImageOutlet.isHidden = true
            captionOutlet.isHidden = true
            imageOutlet.image = post.image
            captionLabel.text = post.caption
            
        }

        // Do any additional setup after loading the view.
    }
    
    var post: Post?
    

 
    func presentPickerView(){
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        
        let photoAction = UIAlertAction(title: "Library", style: .default) { (completion) in
            self.picker.sourceType = .photoLibrary
            self.present(self.picker, animated: true)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (completion) in
            if !UIImagePickerController.isSourceTypeAvailable(.camera) {print("Error with camera"); return}
            self.picker.sourceType = .camera
            self.present(self.picker, animated: true)
        }
        alertController.addAction(photoAction)
        alertController.addAction(cameraAction)
        present(alertController, animated: true)
       
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage{
            imageOutlet.image = image
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    

    @IBAction func cancelTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func savePostTapped(_ sender: Any) {
        guard let image = imageOutlet.image,
            let text = captionOutlet.text else {return}
        guard text != "" else {return}
        PostController.shared.createPost(caption: text, image: image) { (Post) in
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func followTapped(_ sender: Any) {
        guard let post = post else {return}
        PostController.shared.toggleSubscriptionTo(commentsForPost: post) { (subscribed) in
            DispatchQueue.main.async {
                if subscribed {
                    self.followOutlet.title = "Unfollow"
                } else {
                    self.followOutlet.title = "Follow"
                    
                }
                
            }
        }
    }
    @IBAction func likeTapped(_ sender: Any) {
    }
    @IBAction func shareTapped(_ sender: Any) {
        guard let post = post else {return}
        let activityViewController = UIActivityViewController(activityItems: [post.image as Any, post.caption], applicationActivities: nil)
        present(activityViewController, animated: true)
        
    }
    
    
    @IBAction func commentTapped(_ sender: Any) {
        guard let comment = addCommentOutlet.text else {return}
        guard let post = post else {return}
        let postRecordID = post.ckRecordID
        let recordID = CKRecord.Reference(recordID: postRecordID, action: .deleteSelf)
        PostController.shared.addComment(commentText: comment, post: post, postReference: recordID) { (comment) in
        }
        commentsLabel.text = "Comments\(post.comments?.map{$0.commentText})"
        addCommentOutlet.text = ""
        addCommentOutlet.resignFirstResponder()
        
        
    }
    @IBAction func addImageTapped(_ sender: Any) {
        addImageOutlet.setTitle("", for: .normal)
        
        presentPickerView()
        
    }
    
    

    
}
