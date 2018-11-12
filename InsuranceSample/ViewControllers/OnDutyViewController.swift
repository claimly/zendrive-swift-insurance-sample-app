//
//  OnDutyViewController.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class OnDutyViewController: UIViewController {

    @IBOutlet private var acceptARequestButton: UIButton?;
    @IBOutlet private var cancelPickupButton: UIButton?;
    @IBOutlet private var pickAPassengerButton: UIButton?;
    @IBOutlet private var dropPassengerButton: UIButton?;
    @IBOutlet private var goOffDutyButton: UIButton?;

    @IBOutlet private var insurancePeriodLabel: UILabel?;
    @IBOutlet private var passengerInCarLabel: UILabel?;
    @IBOutlet private var passengerWaitingForPickupLabel: UILabel?;

    internal init() {
        super.init(nibName: String(describing:type(of:self)), bundle: Bundle.main)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "On Duty"
        reloadUI()
    }

    @IBAction private func acceptNewRequestButtonTapped(sender: UIButton?) {
        Slim.info("[OnDutyViewController]: acceptNewRequestButtonTapped")
        TripManager.sharedInstance.acceptNewPassengerRequest()
        self.reloadUI()
    }

    @IBAction private func cancelPickupButtonTapped(sender: UIButton?) {
        Slim.info("[OnDutyViewController]: cancelPickupButtonTapped")
        TripManager.sharedInstance.cancelPassengerRequest()
        self.reloadUI()
    }

    @IBAction private func pickupPassengerButtonTapped(sender: UIButton?) {
        Slim.info("[OnDutyViewController]: pickupPassengerButtonTapped")
        TripManager.sharedInstance.pickAPassenger()
        reloadUI()
    }

    @IBAction private func dropPassengerButtonTapped(sender: UIButton?) {
        Slim.info("[OnDutyViewController]: dropPassengerButtonTapped")
        TripManager.sharedInstance.dropAPassenger()
        reloadUI()
    }

    @IBAction private func goOffDutyButtonTapped(sender: UIButton?) {
        Slim.info("[OnDutyViewController]: goOffDutyButtonTapped")
        TripManager.sharedInstance.goOffDuty()
        self.navigationController?.setViewControllers([OffDutyViewController.init()], animated: true)
    }

    private func reloadUI() {
        var insurancePeriod: Int = 1
        let state: TMState = TripManager.sharedInstance.tripManagerState()
        if (state.passengersInCar > 0) {
            insurancePeriod = 3
        }
        else if (state.passengersWaitingForPickup > 0) {
            insurancePeriod = 2
        }

        // Update text
        self.insurancePeriodLabel!.text = "Insurance Period: \(insurancePeriod)"
        self.passengerInCarLabel!.text = "Passengers In Car: \(state.passengersInCar)"
        self.passengerWaitingForPickupLabel!.text = "Passengers awaiting pickup:" +
        " \(state.passengersWaitingForPickup)"

        // Enable/Disable buttons
        self.dropPassengerButton!.isEnabled = (state.passengersInCar > 0)
        self.pickAPassengerButton!.isEnabled = (state.passengersWaitingForPickup > 0)
        self.cancelPickupButton!.isEnabled = (state.passengersWaitingForPickup > 0)
        self.goOffDutyButton!.isEnabled = (state.passengersInCar == 0 &&
            state.passengersWaitingForPickup == 0)
    }

}
