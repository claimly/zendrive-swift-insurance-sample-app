//
//  LoginViewController.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    @IBOutlet weak var driverIdField: UITextField!

    internal init() {
        super.init(nibName: String(describing:type(of:self)), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        self.title = "Login"
    }

    @IBAction func signUpButtonTapped(_ sender: Any) {
        let driverId = driverIdField.text
        if(driverId != ""){
            UserDefaultsManager.sharedInstance.setDriverId(driverId: driverId)
            (UIApplication.shared.delegate as! AppDelegate).reloadApplication()
        }
    }

}
