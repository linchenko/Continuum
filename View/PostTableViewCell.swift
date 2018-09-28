//
//  PostTableViewCell.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit

class PostTableViewCell: UITableViewCell {

    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var captionOutlet: UILabel!
    
    var post: Post?{
        didSet{
            updateView()
        }
    }
    
    func updateView(){
        guard let post = post else {print(#file); return}
        postImage.image = post.image
        captionOutlet.text = post.caption
        
        PostController.shared.fetchCommentsFor(post: post) { (comments) in
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
