//
//  PostListTableViewController.swift
//  Continuum
//
//  Created by Levi Linchenko on 25/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import UIKit

class PostListTableViewController: UITableViewController, UISearchBarDelegate {

    @IBOutlet weak var searchBarOutlet: UISearchBar!
    
    var resultsArray: [Post]?
    
    
    func searchPosts(searchText: String){
        
        let postsToFilter = PostController.shared.posts
        let filteredPosts = postsToFilter.filter{$0 .matchesSearchTerm(searchTerm: searchText)}
        let results = filteredPosts.map{$0 as Post}
        resultsArray = results
        
    }
    
    func searchComments(){
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let searchText = searchBarOutlet.text else {return}
        searchPosts(searchText: searchText)
        if searchText == "" {
            resultsArray = PostController.shared.posts
        }
        tableView.reloadData()
        
        
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        resultsArray = PostController.shared.posts
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(updateView), name: PostController.shared.postsUpdatedNotificationName, object: nil)
        searchBarOutlet.delegate = self
        PostController.shared.fetchPosts {
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        

    }
    
    @objc func updateView(){
        DispatchQueue.main.async {
            self.resultsArray = PostController.shared.posts
            self.tableView.reloadData()
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resultsArray = PostController.shared.posts
        tableView.reloadData()
    }



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let post = resultsArray else {return 0}
        return post.count

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "postCell", for: indexPath) as? PostTableViewCell else {return UITableViewCell()}
        
        guard let post = resultsArray?[indexPath.row] else {return UITableViewCell()}
        cell.post = post


        return cell
    }
    

   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailVC" {
            let destVC = segue.destination as? PostDetailViewController
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let post = PostController.shared.posts[indexPath.row]
            destVC?.post = post
        }
    }
 

}
