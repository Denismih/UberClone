//
//  DriverAcceptViewController.swift
//  Uber
//
//  Created by Admin on 02.07.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit

class DriverAcceptViewController: UIViewController {

    var riderCoord = CLLocationCoordinate2D()
    var riderEmail = ""
    
    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()

        let region = MKCoordinateRegion(center: riderCoord, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        map.setRegion(region, animated: false)
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = riderCoord
        annotation.title = riderEmail
        map.addAnnotation(annotation)
    }
    @IBAction func accept(_ sender: Any) {
    }
    
   
}
