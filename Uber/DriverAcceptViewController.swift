//
//  DriverAcceptViewController.swift
//  Uber
//
//  Created by Admin on 02.07.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import MapKit
import FirebaseDatabase

class DriverAcceptViewController: UIViewController {

    var riderCoord = CLLocationCoordinate2D()
    var driverCoord = CLLocationCoordinate2D()
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
        Database.database().reference().child("rideRequest").queryOrdered(byChild: "email").queryEqual(toValue: riderEmail).observe(.childAdded) { (snap) in
            snap.ref.updateChildValues(["driverLat": self.driverCoord.latitude, "driverLon": self.driverCoord.longitude])
            Database.database().reference().child("rideRequest").removeAllObservers()
        }
        let requestLocation = CLLocation(latitude: riderCoord.latitude, longitude: riderCoord.longitude)
        CLGeocoder().reverseGeocodeLocation(requestLocation) { (placemarks, error) in
            if let placemarks = placemarks {
                if placemarks.count > 0 {
                    let plMark = MKPlacemark(placemark: placemarks[0])
                    let mapItem = MKMapItem(placemark: plMark)
                    mapItem.name = self.riderEmail
                    let options = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
                    mapItem.openInMaps(launchOptions: options)
                }
            }
        }
    }
    
   
}
