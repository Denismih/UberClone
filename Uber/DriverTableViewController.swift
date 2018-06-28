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

class DriverTableViewController: UITableViewController {
    
    var rideRequests: [DataSnapshot] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Database.database().reference().child("rideRequest").observe(.childAdded) { (snapshot) in
            self.rideRequests.append(snapshot)
            self.tableView.reloadData()
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
            if let email = rideReqDict["email"] as? String {
                cell.textLabel?.text = email
            }
        }
        return cell
    }
    
    
    
}
