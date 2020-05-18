//
//  RegisterViewController.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Simple_Networking
import SVProgressHUD

class RegisterViewController: UIViewController {
    // MARK: -- Outlets
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var nameTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        // Do any additional setup after loading the view.
    }
    
    // MARK: -- IBActions
    @IBAction func registerAction(_ sender: Any) {
        view.endEditing(true)
        performRegister()
    }
    
    
    // MARK: -- Functions
    private func setupUI(){
        registerButton.layer.cornerRadius = 25
        
    }
    
    private func performRegister(){
           guard let email = emailTextField.text, !email.isEmpty else {
               NotificationBanner(title: "Error", subtitle: "Debes especificar un correo", style: .warning).show()
               return
           }
        
        guard let names = emailTextField.text, !names.isEmpty else {
            NotificationBanner(title: "Error", subtitle: "Debes especificar un nombre", style: .warning).show()
            return
        }
           
           guard let password = passwordTextField.text, !password.isEmpty else {
               NotificationBanner(title: "Error", subtitle: "Debes Debes ingrear una contraseña", style: .warning).show()
               return
           }
        
        let request = RegisterRequest(email: email, password: password, names: names)
        
        // iniciamos la carga
        SVProgressHUD.show()
        
        // llamar a libreria de red
        SN.post(endpoint: Endpoints.register, model: request) { (response: SNResultWithEntity<LoginResponse, ErrorResponse>) in
            // cerramos la carga
            SVProgressHUD.dismiss()
            switch response {
                case .success(let user):
                    SimpleNetworking.setAuthenticationHeader(prefix: "", token: user.token)
                    self.performSegue(withIdentifier: "showHome", sender: nil)

                case .error(let error):
                    NotificationBanner(title: "Algo ha salido mal", subtitle: "\(error.localizedDescription)", style: .danger).show()
                    return

                case .errorResult(let entity):
                    NotificationBanner(title: "Error", subtitle: "\(entity.error.description)", style: .warning).show()
                    return

            }
        }
        
//            performSegue(withIdentifier: "showHome", sender: nil)
       }

}
