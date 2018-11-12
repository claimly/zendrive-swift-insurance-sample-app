//
//  UserDefaultsManager.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class UserDefaultsManager: NSObject {
    // Constants
    private let kDriverIdKey: String = "driverId"
    private let kIsUserOnDutyKey: String = "isUserOnDuty"
    private let kPassengersInCarKey: String = "passengersInCar"
    private let kPassengersWaitingForPickupKey: String = "passengersWaitingForPickup"
    private let kTrackingIdKey: String = "trackingId"

    public static let sharedInstance = UserDefaultsManager()

    private let _userDefaults:UserDefaults
    override init() {
        _userDefaults = UserDefaults.standard
    }

    // MARK: User Data Management
    public func setDriverId(driverId: String?) {
        _userDefaults.set(driverId, forKey: kDriverIdKey)
        _userDefaults.synchronize()
    }

    public func driverId() -> String? {
        return _userDefaults.object(forKey: kDriverIdKey) as? String
    }

    // MARK: TripManager
    public func setIsUserOnDuty(isUserOnDuty: Bool) {
        _userDefaults.set(isUserOnDuty, forKey: kIsUserOnDutyKey)
    }

    public func isUserOnDuty() -> Bool {
        let isUserOnDuty = _userDefaults.object(forKey: kIsUserOnDutyKey)
        if (isUserOnDuty == nil) {
            return false
        }
        else {
            return isUserOnDuty as! Bool
        }
    }

    public func setPassengersInCar(passengersInCar: Int) {
        _userDefaults.set(passengersInCar, forKey: kPassengersInCarKey)
    }

    public func passengersInCar() -> Int {
        let passengersInCar = _userDefaults.object(forKey: kPassengersInCarKey)
        if (passengersInCar == nil) {
            return 0
        }
        else {
            return passengersInCar as! Int
        }
    }

    public func setPassengersWaitingForPickup(passengersWaitingForPickup: Int) {
        _userDefaults.set(passengersWaitingForPickup, forKey: kPassengersWaitingForPickupKey)
    }

    public func passengersWaitingForPickup() -> Int {
        let passengersWaitingForPickup = _userDefaults.object(forKey: kPassengersWaitingForPickupKey)
        if (passengersWaitingForPickup == nil) {
            return 0
        }
        else {
            return passengersWaitingForPickup as! Int
        }
    }

    func setTrackingId(trackingId: String?) {
        _userDefaults.set(trackingId, forKey: kTrackingIdKey)
        _userDefaults.synchronize()
    }

    public func trackingId() -> String? {
        return _userDefaults.object(forKey: kTrackingIdKey) as? String
    }
}
