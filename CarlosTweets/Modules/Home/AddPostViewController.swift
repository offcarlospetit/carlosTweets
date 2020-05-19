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
import FirebaseStorage
import AVFoundation
import AVKit
import MobileCoreServices

class AddPostViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var previewImageView: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    
    // MARK: - Properties
    private var imagePicker: UIImagePickerController?
    private var currentVideoURL: URL?
    
    // MARK: - IBActions functions
    @IBAction func addPostAction(_ sender: Any){
                uploadVideoToFirebase()
        //        openVideoCamera()
        
    }
    
    @IBAction func openCameraAction(_ sender: Any) {
        let alert = UIAlertController(title: "Camara", message: "Seleccione una opcion", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Photo", style: .default, handler: { (_) in
            self.openCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Video", style: .default, handler: { (_) in
            self.openVideoCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancelar", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func dissmissActio(_ sender: Any){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func previewAction(_ sender: Any) {
        guard let currentVideoURL = currentVideoURL else {
            return
        }
        let avPlayer = AVPlayer(url: currentVideoURL)
        let avPlayerController = AVPlayerViewController()
        avPlayerController.player = avPlayer
        
        present(avPlayerController, animated: true) {
            avPlayerController.player?.play()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        videoButton.isHidden = true
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Private functions
    private func savePost(imageUrl: String?, videoURL: String?){
        //Indicar carga al usuario
        SVProgressHUD.show()
        
        // crear un request
        guard let textTweet = postTextView.text else{
            return
        }
        let request = PostRequest(text: textTweet, imageUrl: imageUrl, videoUrl: videoURL, location: nil)
        
        
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
    
    private func uploadPhotoToFirebase(){
        // 1. asegurarnos que la foto exista y la comprimimos y se convierte en data
        guard let imageSaved = previewImageView.image, let imageSavedData: Data = imageSaved.jpegData(compressionQuality: 0.1) else {
            return
        }
        SVProgressHUD.show()
        // 2 Configuramos guardar la foto en Storage
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "image/jpg"
        
        //4 referencia al storage de firebase
        let storage = Storage.storage()
        
        //Crear nombre de la imagen a subir
        let imageName = Int.random(in: 100...2000)
        
        //Crea referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "carlostweetsImages/\(imageName).jpg")
        
        //Sbir la foto a Firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(imageSavedData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error:Error?) in
                DispatchQueue.main.async {
                    //detener la carga
                    SVProgressHUD.dismiss()
                    if let error = error {
                        NotificationBanner(title: "Algo ha salido mal", subtitle: "\(error.localizedDescription)", style: .danger).show()
                        return
                    }
                    
                    //Obtener la url de descarga
                    folderReference.downloadURL { (url:URL?, error:Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: downloadUrl, videoURL:nil)
                    }
                }
            }
        }
    }
    
    private func uploadVideoToFirebase(){
        // 1. asegurarnos que la foto exista y la comprimimos y se convierte en data
        guard let currentVideoSavedURL = currentVideoURL, let videoData: Data = try? Data(contentsOf: currentVideoSavedURL) else {
            return
        }
        SVProgressHUD.show()
        // 2 Configuramos guardar la foto en Storage
        let metaDataConfig = StorageMetadata()
        metaDataConfig.contentType = "video/mp4"
        
        //4 referencia al storage de firebase
        let storage = Storage.storage()
        
        //Crear nombre de la imagen a subir
        let videoName = Int.random(in: 100...2000)
        
        //Crea referencia a la carpeta donde se va a guardar la foto
        let folderReference = storage.reference(withPath: "carlostweetsVideos/\(videoName).mp4")
        
        //Sbir el video a Firebase
        DispatchQueue.global(qos: .background).async {
            folderReference.putData(videoData, metadata: metaDataConfig) { (metaData: StorageMetadata?, error:Error?) in
                DispatchQueue.main.async {
                    //detener la carga
                    SVProgressHUD.dismiss()
                    if let error = error {
                        NotificationBanner(title: "Algo ha salido mal", subtitle: "\(error.localizedDescription)", style: .danger).show()
                        return
                    }
                    
                    //Obtener la url de descarga
                    folderReference.downloadURL { (url:URL?, error:Error?) in
                        let downloadUrl = url?.absoluteString ?? ""
                        self.savePost(imageUrl: nil, videoURL: downloadUrl)
                    }
                }
            }
        }
    }
    
    private func openCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .photo
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    private func openVideoCamera(){
        imagePicker = UIImagePickerController()
        imagePicker?.sourceType = .camera
        imagePicker?.mediaTypes = [kUTTypeMovie as String]
        imagePicker?.cameraFlashMode = .off
        imagePicker?.cameraCaptureMode = .video
        imagePicker?.videoQuality = .typeMedium
        imagePicker?.videoMaximumDuration = TimeInterval(5)
        imagePicker?.allowsEditing = true
        imagePicker?.delegate = self
        
        guard let imagePicker = imagePicker else {
            return
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
}


// MARK: - Extensions
extension AddPostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        //Captura imagen
        imagePicker?.dismiss(animated: true, completion: nil)
        if info.keys.contains(.originalImage){
            previewImageView.isHidden = false
            previewImageView.image = info[.originalImage] as? UIImage
            
        }
        
        if info.keys.contains(.mediaURL), let recordedVideoUrl = (info[.mediaURL] as? URL)?.absoluteURL {
            currentVideoURL = recordedVideoUrl
            videoButton.isHidden = false
        }
        
    }
}
