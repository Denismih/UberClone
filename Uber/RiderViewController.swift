//
//  RiderViewController.swift
//  Uber
//
//  Created by Admin on 28.06.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase
import FirebaseAuth

class RiderViewController: UIViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var map: MKMapView!
    @IBOutlet weak var callBtn: UIButton!
    
    var locationManager = CLLocationManager()
    var userLocation = CLLocationCoordinate2D()
    var uberCalled = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        guard let email = Auth.auth().currentUser?.email else {return displayAlert(title: "Error", message: "No email")}
        Database.database().reference().child("rideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snap) in
            self.uberCalled = true
            self.callBtn.setTitle("Cancel Uber", for: .normal)
            Database.database().reference().child("rideRequest").removeAllObservers()
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
            map.setRegion(region, animated: true)
            
            map.removeAnnotations(map.annotations)
            let annotation = MKPointAnnotation()
            annotation.coordinate = center
            annotation.title = "You are here"
            map.addAnnotation(annotation)
        }
        
    }
    
    func displayAlert (title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
        
    }
    
    
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUber(_ sender: Any) {
        guard let email = Auth.auth().currentUser?.email else {return displayAlert(title: "Error", message: "No email")}
        if uberCalled  {
            uberCalled = false
            callBtn.setTitle("Call an Uber", for: .normal)
            Database.database().reference().child("rideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childAdded) { (snap) in
                snap.ref.removeValue()
                Database.database().reference().child("rideRequest").removeAllObservers()
            }
        } else {
            
                let rideRequestDic : [String:Any] = ["email":email, "lat":userLocation.latitude, "lon":userLocation.longitude]
                Database.database().reference().child("rideRequest").childByAutoId().setValue(rideRequestDic)
                uberCalled = true
                callBtn.setTitle("Cancel Uber", for: .normal)
            
        }
    }
    
}
