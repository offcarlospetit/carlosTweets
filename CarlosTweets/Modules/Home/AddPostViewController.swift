//
//  AddPostViewController.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class AddPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    
    
    // MARK: - IBActions functions
    @IBAction func addPostAction(_ sender: Any){
        savePost()
        
    }
    
    @IBAction func dissmissActio(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private functions
    private func savePost(){
        //Indicar carga al usuario
        SVProgressHUD.show()
        
        // crear un request
        guard let textTweet = postTextView.text else{
            return
        }
        let request = PostRequest(text: textTweet, imageUrl: nil, videoUrl: nil, location: nil)
        
        
        // Llamar al servicio del post
        SN.post(endpoint: Endpoints.post, model: request) { (response: SNResultWithEntity<Post, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
            case .success(let posts):
                print(posts)
                self.dismiss(animated: true, completion: nil)
            case .error(let error):
                NotificationBanner(title: "Algo ha salido mal", subtitle: "\(error.localizedDescription)", style: .danger).show()
                return
                
            case .errorResult(let entity):
                NotificationBanner(title: "Error", subtitle: "\(entity.error.description)", style: .warning).show()
                return
                
            }
        }
    }
    
    
}
