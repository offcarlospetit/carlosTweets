//
//  HomeViewController.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import Simple_Networking
import SVProgressHUD
import NotificationBannerSwift

class HomeViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Variables
    private let cellId = "TweetTableViewCell"
    private var dataSource = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        getPost()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getPost()
    }
    
    //MARK: - Functions
    private func setUpUI() {
        tableView.dataSource = self
        tableView.register(UINib(nibName: "TweetTableViewCell", bundle: nil), forCellReuseIdentifier: cellId)
    }
    
    private func getPost(){
        // 1. Indicar Carga al usuario
        SVProgressHUD.show()
        
        // 2. Consumir el servicio
        SN.get(endpoint: Endpoints.getPosts) { (response: SNResultWithEntity<[Post], ErrorResponse>) in
            // Cerramos indicador de carga
            SVProgressHUD.dismiss()
            switch response {
                case .success(let posts):
                    self.dataSource = posts
                    self.tableView.reloadData()
                
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


// MARK: - Extensions
extension HomeViewController: UITableViewDataSource{
    
    //Cantidad de celdas a retornar
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    //configuracion de la celda
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        if let cell = cell as? TweetTableViewCell {
           //Config cell
            cell.setUpCellWith(post: dataSource[indexPath.row])
            
        }
        return cell
    }
}
