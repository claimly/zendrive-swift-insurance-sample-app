//
//  OffDutyViewController.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class OffDutyViewController: UIViewController {

    internal init() {
        super.init(nibName: String(describing:type(of:self)), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Off Duty"
    }

    @IBAction func ondutyButtonTapped() {
        Slim.info("[OffDutyViewController]: ondutyButtonTapped")
        TripManager.sharedInstance.goOnDuty()
        self.navigationController?.setViewControllers([OnDutyViewController.init()], animated: true)
    }

}
