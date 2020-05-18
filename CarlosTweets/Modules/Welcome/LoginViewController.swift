//
//  LoginViewController.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class LoginViewController: UIViewController {
    // MARK: -- Outlets
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

        // Do any additional setup after loading the view.
    }
    
    // MARK: -IBActions
    
    @IBAction func loginAction(_ sender: Any) {
        view.endEditing(true)
        performLogin()
    }
    
    
    // MARK: -Private Methods
    
    private func setupUI(){
        signInButton.layer.cornerRadius = 25
    }
    
    private func performLogin(){
        guard let email = emailTextField.text, !email.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: .warning).show()
            return
        }
        
        guard let password = passwordTextField.text, !password.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes Debes ingrear una contraseña", style: .warning).show()
            return
        }
        
        //Crear request
        let request = LoginRequest(email: email, password: password)
        
        // iniciamos la carga
        SVProgressHUD.show()
        
        // llamar a libreria de red
        SN.post(endpoint: Endpoints.login, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            SVProgressHUD.dismiss()
            switch response {
                case .success(let user):
                    NotificationBanner(subtitle: "Bienvenido \(user.user.names)", style: .success).show()
                    self.performSegue(withIdentifier: "showHome", sender: nil)
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                
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
