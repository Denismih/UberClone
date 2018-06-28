//
//  ViewController.swift
//  Uber
//
//  Created by Admin on 26.06.2018.
//  Copyright © 2018 Admin. All rights reserved.
//

import UIKit
import FirebaseAuth

class ViewController: UIViewController {
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var passwortText: UITextField!
    @IBOutlet weak var riderSwitch: UISwitch!
    @IBOutlet weak var signupBtn: UIButton!
    @IBOutlet weak var switchBtn: UIButton!
    @IBOutlet weak var riderLbl: UILabel!
    @IBOutlet weak var driverLbl: UILabel!
    
    var signUpMode = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func signup(_ sender: Any) {
        guard  email.text != "" && passwortText.text != "" else {return displayAlert(title: "Error", message: "Enter email and password")
        }
        if let email = email.text {
            if let password = passwortText.text {
                if signUpMode {
                    //signUp
                    
                    Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Sign Up Error", message: error!.localizedDescription)
                        } else{
                            if self.riderSwitch.isOn {
                                //Driver
                                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                request?.displayName = "Driver"
                                request?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                //Rider
                                let request = Auth.auth().currentUser?.createProfileChangeRequest()
                                request?.displayName = "Rider"
                                request?.commitChanges(completion: nil)
                                self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                            print("signUp OK")
                            
                        }
                    }
                } else {
                    //LogIn
                    Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
                        if error != nil {
                            self.displayAlert(title: "Sign Up Error", message: error!.localizedDescription)
                        } else{
                            print("login OK")
                            if user?.user.displayName == "Driver" {
                                self.performSegue(withIdentifier: "driverSegue", sender: nil)
                            } else {
                                 self.performSegue(withIdentifier: "riderSegue", sender: nil)
                            }
                            
                        }
                    }
                    
                }
            }
        }
        
    }
    @IBAction func switchSignupLogin(_ sender: Any) {
        if signUpMode {
            signupBtn.setTitle("Login", for: .normal)
            switchBtn.setTitle("Switch to SignUp", for: .normal)
            riderSwitch.isHidden = true
            riderLbl.isHidden = true
            driverLbl.isHidden = true
            signUpMode = !signUpMode
        } else {
            signupBtn.setTitle("Sign Up", for: .normal)
            switchBtn.setTitle("Switch to Login", for: .normal)
            riderSwitch.isHidden = false
            riderLbl.isHidden = false
            driverLbl.isHidden = false
            signUpMode = !signUpMode
        }
    }
    func displayAlert (title:String, message:String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alertController, animated: true)
        
    }
    
}

