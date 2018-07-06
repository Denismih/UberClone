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
    var driverLocation = CLLocationCoordinate2D()
    var uberCalled = false
    var driverComming = false
    
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
            if let rideReqDict = snap.value as? [String:Any] {
                if let lat = rideReqDict["driverLat"] as? Double {
                    if let lon = rideReqDict["driverLon"] as? Double {
                        self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        self.driverComming = true
                        self.displayDistanceToDriver()
                        
                        guard let email = Auth.auth().currentUser?.email else {return self.displayAlert(title: "Error", message: "No email")}
                        Database.database().reference().child("rideRequest").queryOrdered(byChild: "email").queryEqual(toValue: email).observe(.childChanged) { (snap) in
                            if let rideReqDict = snap.value as? [String:Any] {
                                if let lat = rideReqDict["driverLat"] as? Double {
                                    if let lon = rideReqDict["driverLon"] as? Double {
                                        self.driverLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                        self.driverComming = true
                                        self.displayDistanceToDriver()
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            let center = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            userLocation = center
            
            if uberCalled {
                displayDistanceToDriver()
            } else {
                let region = MKCoordinateRegion(center: center, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
                map.setRegion(region, animated: true)
                
                map.removeAnnotations(map.annotations)
                let annotation = MKPointAnnotation()
                annotation.coordinate = center
                annotation.title = "You are here"
                map.addAnnotation(annotation)
            }
        }
        
    }
    
    func displayAlert (title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
        
        
        
    }
    
    func displayDistanceToDriver (){
        let driverLoc = CLLocation(latitude: driverLocation.latitude, longitude: driverLocation.longitude)
        let riderLoc = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let dist = (driverLoc.distance(from: riderLoc)/1000).twoDecimal
        callBtn.setTitle("Your driver is \(dist)km away!", for: .normal)
        
        map.removeAnnotations(map.annotations)
        
        let latDelta = abs(driverLocation.latitude - userLocation.latitude)*2 + 0.005
        let lonDelta = abs(driverLocation.longitude - userLocation.longitude)*2 + 0.005
        let region = MKCoordinateRegion(center: driverLocation, span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta))
        map.setRegion(region, animated: true)
        let driverAnnotation = MKPointAnnotation()
        driverAnnotation.title = "Your driver"
        driverAnnotation.coordinate = driverLocation
        map.addAnnotation(driverAnnotation)
        
        let riderAnnotation = MKPointAnnotation()
        riderAnnotation.title = "Your driver"
        riderAnnotation.coordinate = userLocation
        map.addAnnotation(riderAnnotation)
    }
    
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func callUber(_ sender: Any) {
        guard let email = Auth.auth().currentUser?.email else {return displayAlert(title: "Error", message: "No email")}
        if !driverComming {
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
    
}
