//
//  TripManager.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class TMState: NSObject {
    var isUserOnDuty: Bool
    var passengersInCar: Int
    var passengersWaitingForPickup: Int
    var trackingId: String?

    init(isUserOnDuty: Bool, passengersInCar: Int,
         passengersWaitingForPickup: Int, trackingId: String?) {
        self.isUserOnDuty = isUserOnDuty
        self.passengersInCar = passengersInCar
        self.passengersWaitingForPickup = passengersWaitingForPickup
        self.trackingId = trackingId
    }

    override func copy() -> Any {
        return TMState.init(isUserOnDuty: isUserOnDuty,
                            passengersInCar: passengersInCar,
                            passengersWaitingForPickup: passengersWaitingForPickup,
                            trackingId: trackingId)
    }
}

class TripManager: NSObject {
    public static let sharedInstance = TripManager()
    private let _state: TMState

    override init() {
        let userDefaultsManager = UserDefaultsManager.sharedInstance
        _state = TMState.init(isUserOnDuty: userDefaultsManager.isUserOnDuty(),
                              passengersInCar: userDefaultsManager.passengersInCar(),
                              passengersWaitingForPickup: userDefaultsManager.passengersWaitingForPickup(),
                              trackingId: userDefaultsManager.trackingId())
        super.init()
        setupOrTeardownLocationPermissionManager()
    }

    public func goOnDuty() {
        ThreadingUtil.synchronized(self, closure: {
            _state.isUserOnDuty = true
            UserDefaultsManager.sharedInstance.setIsUserOnDuty(isUserOnDuty: _state.isUserOnDuty)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
            setupOrTeardownLocationPermissionManager()
        })
    }

    public func goOffDuty() {
        ThreadingUtil.synchronized(self, closure: {
            _state.isUserOnDuty = false
            UserDefaultsManager.sharedInstance.setIsUserOnDuty(isUserOnDuty: _state.isUserOnDuty)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
            setupOrTeardownLocationPermissionManager()
        })
    }

    public func acceptNewPassengerRequest() {
        ThreadingUtil.synchronized(self, closure: {
            _state.passengersWaitingForPickup += 1
            UserDefaultsManager.sharedInstance.setPassengersWaitingForPickup(passengersWaitingForPickup: _state.passengersWaitingForPickup)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
        })
    }

    public func cancelPassengerRequest() {
        ThreadingUtil.synchronized(self, closure: {
            _state.passengersWaitingForPickup -= 1
            UserDefaultsManager.sharedInstance.setPassengersWaitingForPickup(passengersWaitingForPickup: _state.passengersWaitingForPickup)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
        })
    }

    public func pickAPassenger() {
        ThreadingUtil.synchronized(self, closure: {
            _state.passengersInCar += 1
            UserDefaultsManager.sharedInstance.setPassengersInCar(passengersInCar: _state.passengersInCar)

            _state.passengersWaitingForPickup -= 1
            UserDefaultsManager.sharedInstance.setPassengersWaitingForPickup(passengersWaitingForPickup: _state.passengersWaitingForPickup)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
        })
    }

    public func dropAPassenger() {
        ThreadingUtil.synchronized(self, closure: {
            _state.passengersInCar -= 1
            UserDefaultsManager.sharedInstance.setPassengersInCar(passengersInCar: _state.passengersInCar)
            updateTrackingIdIfNeeded()
            ZendriveManager.sharedInstance.updateInsurancePeriodsBasedOnApplicationState()
        })
    }

    private func updateTrackingIdIfNeeded() {
        ThreadingUtil.synchronized(self, closure: {
            if (_state.passengersInCar > 0 || _state.passengersWaitingForPickup > 0) {
                if (_state.trackingId == nil) {
                    _state.trackingId = String.init(format: "%.0f", arguments: [NSDate.init().timeIntervalSince1970*1000])
                    UserDefaultsManager.sharedInstance.setTrackingId(trackingId: _state.trackingId)
                }
            }
            else if (_state.trackingId != nil) {
                _state.trackingId = nil
                UserDefaultsManager.sharedInstance.setTrackingId(trackingId: _state.trackingId)
            }
        })
    }

    public func tripManagerState() -> TMState {
        var state: TMState? = nil
        ThreadingUtil.synchronized(self) {
            state = _state.copy() as? TMState
        }
        return state!
    }

    private func setupOrTeardownLocationPermissionManager() {
        if (_state.isUserOnDuty) {
            LocationPermissionManager.setup()
        }
        else {
            LocationPermissionManager.teardown()
        }
    }
}
