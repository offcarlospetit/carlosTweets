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
import AVKit

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
        tableView.delegate = self
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
    
    private func deletePostAt(indexpath: IndexPath){
        // 1. Indicar Carga al usuario
        SVProgressHUD.show()
        
        // 2. Obtener id del post que vamos a borrar
        let postId = dataSource[indexpath.row].id
        
        // Servicio para borrar el post
        let endPoint = Endpoints.delete + postId
        SN.delete(endpoint: endPoint ) { (response: SNResultWithEntity<GeneralResponse, ErrorResponse>) in
            // Cerramos indicador de carga
            SVProgressHUD.dismiss()
            print(response  )
            switch response {
            case .success:
                //borrar el post del datasource
                self.dataSource.remove(at: indexpath.row)
                
                // borrar la celda de la tabla
                self.tableView.deleteRows(at: [indexpath], with: .fade)
                
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
            cell.needsToShowVideo = { url in
                // Aqui si deberiamos abrir un view controller
                       let avPlayer = AVPlayer(url: url)
                       let avPlayerController = AVPlayerViewController()
                       avPlayerController.player = avPlayer
                       
                self.present(avPlayerController, animated: true) {
                           avPlayerController.player?.play()
                       }
            }
            
        }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate{
    
    //Eliminar row
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: UITableViewRowAction.Style.destructive, title: "Borrar") { (_, _) in
            self.deletePostAt(indexpath: indexPath)
        }
        return [deleteAction]
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let defaults = UserDefaults.standard
        let email = defaults.string(forKey: "usermail")
        return dataSource[indexPath.row].author.email == email
    }
    
}
