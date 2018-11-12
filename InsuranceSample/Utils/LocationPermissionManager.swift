//
//  LocationPermissionManager.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/28/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit
import CoreLocation

class LocationPermissionManager: NSObject, CLLocationManagerDelegate {
    static var _sharedInstance: LocationPermissionManager?
    public static func setup() {
        ThreadingUtil.synchronized(self) {
            self._sharedInstance = LocationPermissionManager.init()
        }
    }

    public static func teardown() {
        ThreadingUtil.synchronized(self) {
            self._sharedInstance = nil
        }
    }

    private var _locationManager: CLLocationManager?
    private var _locationPermissionAlert: UIAlertController?
    private var _alertWindow: UIWindow?
    private override init() {
        super.init()
        _locationManager = CLLocationManager.init()
        _locationManager?.delegate = self
    }

    //------------------------------------------------------------------------------
    // MARK: CLLocationManagerDelegate
    //------------------------------------------------------------------------------
    internal func locationManager(_ manager: CLLocationManager,
                                  didChangeAuthorization status: CLAuthorizationStatus) {
        switch (status) {
        case CLAuthorizationStatus.restricted: fallthrough
        case CLAuthorizationStatus.denied: fallthrough
        case CLAuthorizationStatus.authorizedWhenInUse:
            // Display location permisison view controller
            displayLocationPermissionErrorViewNotVisible()
        // Follow through to ask for permission
        case CLAuthorizationStatus.notDetermined:
            // Request for location, specifically for iOS8
            if (_locationManager != nil &&
                _locationManager!.responds(
                    to: #selector(CLLocationManager.requestAlwaysAuthorization))) {
                _locationManager!.requestAlwaysAuthorization()
            }
            break
        case CLAuthorizationStatus.authorizedAlways:
            // Remove location permission view controller
            hideLocationPermissionErrorViewIfVisible()
            break
        }
    }

    func displayLocationPermissionErrorViewNotVisible() {
        if (_locationPermissionAlert == nil) {
            let errorMessage: String = "Please provide \"Always Allow\" location" +
            " permission to get insurance benefits"
            _locationPermissionAlert = UIAlertController.init(
                title: "Location Permission Denied", message: errorMessage,
                preferredStyle: UIAlertControllerStyle.alert)
            _locationPermissionAlert?.addAction(UIAlertAction.init(title: "Open Settings", style: UIAlertActionStyle.default, handler: { [weak self](action) in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL.init(string: UIApplicationOpenSettingsURLString)!,
                                              options: [:], completionHandler: nil)
                } else {
                    // Fallback on earlier versions
                    let applicationSettingsURL : URL? =
                        URL.init(string: UIApplicationOpenSettingsURLString)
                    if (applicationSettingsURL != nil) {
                        UIApplication.shared.openURL(applicationSettingsURL!)
                    }
                }
                if (self != nil && self?._locationPermissionAlert != nil) {
                    self?.showAlert(alert: (self?._locationPermissionAlert)!)
                }
            }))
            self.showAlert(alert: _locationPermissionAlert!)
        }
    }

    func showAlert(alert: UIAlertController) {
        if (_alertWindow == nil) {
            _alertWindow = UIWindow.init(frame: UIScreen.main.bounds)
            _alertWindow!.rootViewController = UIViewController()
            _alertWindow!.windowLevel = UIWindowLevelAlert + 1;
            _alertWindow!.makeKeyAndVisible();
        }
        _alertWindow?.rootViewController?.present(alert, animated: true, completion: nil)
        _locationPermissionAlert = alert;
    }

    func hideLocationPermissionErrorViewIfVisible() {
        if (_locationPermissionAlert == nil) {
            return
        }
        _locationPermissionAlert?.dismiss(animated: true, completion: {
            [weak self] in
            self?._alertWindow = nil
        })
        _locationPermissionAlert = nil;
    }
}
