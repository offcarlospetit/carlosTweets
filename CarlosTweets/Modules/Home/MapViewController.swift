//
//  MapViewController.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 19-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    //MARK: - Outlets
    @IBOutlet weak var mapViewContainer: UIView!
    
    
    //MARK: - Properties
    var posts = [Post]()
    private var map: MKMapView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpMap()
        setUpMarkers()
        // Do any additional setup after loading the view.
    }
    
    
    //MARK: - Private Functions
    private func setUpMap(){
        map = MKMapView(frame: mapViewContainer.bounds)
        mapViewContainer.addSubview(map ?? UIView())
    }
    
    private func setUpMarkers(){
        posts.forEach{item in
            let marker = MKPointAnnotation()
            marker.coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.latitude)
            marker.title = item.text
            marker.subtitle = item.author.nickname
            map?.addAnnotation(marker)
        }
        // Buscamos el ultimo post del arreglo
        guard let lastPost = posts.last else {
            return
        }
        
        let lastPostLocation = CLLocationCoordinate2D(latitude: lastPost.location.latitude, longitude: lastPost.location.longitude)
        
        guard let heading = CLLocationDirection(exactly: 12) else {
            return
        }
        
        map?.camera = MKMapCamera(lookingAtCenter: lastPostLocation, fromDistance: 30, pitch: .zero, heading: heading)
    }
}
