//
//  DriverTableViewController.swift
//  Uber
//
//  Created by Admin on 28.06.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import  MapKit

extension Double {
    var twoDecimal:String {
        return String(format: "%.2f", self)
    }
}

class DriverTableViewController: UITableViewController,  CLLocationManagerDelegate{
    
    var rideRequests: [DataSnapshot] = []
    let locationManager = CLLocationManager()
    var driverCoord = CLLocationCoordinate2D()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        Database.database().reference().child("rideRequest").observe(.childAdded) { (snapshot) in
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
        }
        
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { (timer) in
            self.tableView.reloadData()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let coord = manager.location?.coordinate {
            driverCoord = coord
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return rideRequests.count
    }
    
    @IBAction func logout(_ sender: Any) {
        try? Auth.auth().signOut()
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let snapshot = rideRequests[indexPath.row]
        if let rideReqDict = snapshot.value as? [String:Any] {
            //print (rideReqDict)
            if let email = rideReqDict["email"] as? String {
                if let lat = rideReqDict["lat"] as? Double {
                    if let lon = rideReqDict["lon"] as? Double {
                        let riderLocation = CLLocation(latitude: lat, longitude: lon)
                        let driverLocation = CLLocation(latitude: driverCoord.latitude, longitude: driverCoord.longitude)
                        let dist = (driverLocation.distance(from: riderLocation)/1000).twoDecimal
                        
                        cell.textLabel?.text = "\(email) - \(dist)km"
                    }
                }
                
                
            }
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let snapshot = rideRequests[indexPath.row]
        performSegue(withIdentifier: "acceptSegue", sender: snapshot)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let acceptVC = segue.destination as? DriverAcceptViewController {
            if let snapshot = sender as? DataSnapshot {
                if let rideReqDict = snapshot.value as? [String:Any] {
                    //print (rideReqDict)
                    if let email = rideReqDict["email"] as? String {
                        if let lat = rideReqDict["lat"] as? Double {
                            if let lon = rideReqDict["lon"] as? Double {
                              
                                acceptVC.riderEmail = email
                                acceptVC.riderCoord = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                                
                            }
                        }
                    }
                }
            }
        }
    }
}
