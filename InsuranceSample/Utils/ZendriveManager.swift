//
//  ZendriveManager.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/28/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit
import ZendriveSDK.Insurance

class InsurancePeriod: NSObject {
    let period: Int
    let trackingId: String?
    public init(period: Int, trackingId: String? = nil) {
        self.period = period
        self.trackingId = trackingId
    }
}

class ZendriveManager: NSObject, ZendriveDelegateProtocol {
    // Constants
    private static let kZendriveSDKKeyString: String = "your-zendrive-sdk-key"

    public static let sharedInstance: ZendriveManager = ZendriveManager()

    public func currentlyActiveInsurancePeriod() -> InsurancePeriod? {
        let appState = TripManager.sharedInstance.tripManagerState()
        if (!appState.isUserOnDuty) {
            return nil
        }
        else if (appState.passengersInCar > 0) {
            return InsurancePeriod.init(period: 3, trackingId: appState.trackingId)
        }
        else if (appState.passengersWaitingForPickup > 0) {
            return InsurancePeriod.init(period: 2, trackingId: appState.trackingId)
        }
        else {
            return InsurancePeriod.init(period: 1)
        }
    }

    //-------------------------------------------------------------------------
    // MARK: Error parsing
    //-------------------------------------------------------------------------
    private func getDisplayableError(zendriveError: NSError) -> NSError {
        let zendriveError: NSError = zendriveError as NSError
        var message: String = "Unknown error in setting up for insurance, please restart the " +
        "application. Please contact support if the issue persists"
        if (zendriveError.code == Int(ZendriveError.networkUnreachable.rawValue)) {
            message = "Internet not available to set up for insurance, please enable 3G/LTE " +
            "or connect to wifi and restart the application";
        }
        return NSError.init(domain: "ZendriveManager", code: zendriveError.code,
                            userInfo: [NSLocalizedFailureReasonErrorKey: message])
    }

    //-------------------------------------------------------------------------
    // MARK: Zendrive API Calls
    //-------------------------------------------------------------------------
    public func initializeSDKForDriverId(driverId: String, successHandler: (() -> Void)?,
                                         failureHandler: ((_ error: NSError?) -> Void)?) {
        initializeSDKForDriverId(driverId: driverId, successHandler: successHandler,
                                 failureHandler: failureHandler, trialNumber: 1,
                                 totalRetryCount: 3)
    }

    private func initializeSDKForDriverId(driverId: String, successHandler: (() -> Void)?,
                                          failureHandler: ((_ error: NSError?) -> Void)?,
                                          trialNumber: Int, totalRetryCount: Int) {
        let activeInsurancePeriod: InsurancePeriod? = currentlyActiveInsurancePeriod()
        let configuration: ZendriveConfiguration = ZendriveConfiguration.init();
        configuration.applicationKey = ZendriveManager.kZendriveSDKKeyString;
        configuration.driveDetectionMode = (activeInsurancePeriod != nil) ?
            ZendriveDriveDetectionMode.autoON:ZendriveDriveDetectionMode.autoOFF;
        configuration.driverId = driverId;

        Zendrive.setup(with: configuration, delegate: self) { (success, error) in
            var error: NSError? = error as NSError?
            if(error != nil) {
                if (trialNumber < totalRetryCount) {
                    self.initializeSDKForDriverId(driverId: driverId,
                                                  successHandler: successHandler,
                                                  failureHandler: failureHandler,
                                                  trialNumber: (trialNumber + 1),
                                                  totalRetryCount: totalRetryCount)
                    return
                }
                Slim.error("[ZendriveManager]: setupWithConfiguration:error:" +
                    " \(String(describing: error!.localizedFailureReason))")
                error = self.getDisplayableError(zendriveError: error!)
                if (failureHandler != nil) {
                    failureHandler!(error);
                }
            }
            else {
                Slim.info("[ZendriveManager]: setupWithConfiguration:success")
                let activeInsurancePeriod: InsurancePeriod? = self.currentlyActiveInsurancePeriod()
                if (activeInsurancePeriod != nil) {
                    Zendrive.setDriveDetectionMode(ZendriveDriveDetectionMode.autoON)
                }
                self.updateInsurancePeriodsBasedOnApplicationState()
                if (successHandler != nil) {
                    successHandler!()
                }
            }
        }
    }

    public func updateInsurancePeriodsBasedOnApplicationState() {
        let activeInsurancePeriod: InsurancePeriod? = currentlyActiveInsurancePeriod() // This assumes activePeriod nil as no-tracking period
        var error: NSError? = nil
        if (activeInsurancePeriod == nil) {
            Slim.info("[ZendriveManager]: updateInsurancePeriodsBasedOnApplicationState" +
                " with NO Period.")
            ZendriveInsurance.stopPeriod(&error)
        }
        else {
            switch (activeInsurancePeriod!.period) {
                case 1:
                    Slim.info("[ZendriveManager]: updateInsurancePeriodsBasedOnApplicationState" +
                        " with Period: \(activeInsurancePeriod!.period) and " +
                        "trackingId: \(String(describing: activeInsurancePeriod!.trackingId))")
                    ZendriveInsurance.startPeriod1(&error)
                    break;
                case 2:
                    Slim.info("[ZendriveManager]: updateInsurancePeriodsBasedOnApplicationState" +
                        " with Period: \(activeInsurancePeriod!.period) and " +
                        "trackingId: \(String(describing: activeInsurancePeriod!.trackingId))")
                    ZendriveInsurance.startDrive(withPeriod2: activeInsurancePeriod!.trackingId,
                                                 error: &error)
                    break;
                case 3:
                    Slim.info("[ZendriveManager]: updateInsurancePeriodsBasedOnApplicationState" +
                        " with Period: \(activeInsurancePeriod!.period) and " +
                        "trackingId: \(String(describing: activeInsurancePeriod!.trackingId))")
                    ZendriveInsurance.startDrive(withPeriod3: activeInsurancePeriod!.trackingId,
                                                 error: &error)
                    break;

                default:
                    Slim.error("[ZendriveManager]: updateInsurancePeriodsBasedOnApplicationState" +
                        " with WRONG Period.")
                    ZendriveInsurance.stopPeriod(&error)
                break;
            }
        }
        if (error != nil && error!.code != Int(ZendriveError.insurancePeriodSame.rawValue)) {
            // Something went wrong, log the error
            Slim.error("Error in period switch: \(error!.code)")
        }
    }

    //-------------------------------------------------------------------------
    // MARK: ZendriveDelegateProtocol
    //-------------------------------------------------------------------------
    internal func processStart(ofDrive startInfo: ZendriveDriveStartInfo) {
        Slim.info("[ZendriveManager]: Start of Drive invoked")
    }

    internal func processResume(ofDrive resumeInfo: ZendriveDriveResumeInfo) {
        Slim.info("[ZendriveManager]: Resume of Drive invoked")
    }

    internal func processEnd(ofDrive estimatedDriveInfo: ZendriveEstimatedDriveInfo) {
        Slim.info("[ZendriveManager]: End of Drive invoked")
    }

    internal func processAnalysis(ofDrive analyzedDriveInfo: ZendriveAnalyzedDriveInfo) {
        Slim.info("[ZendriveManager]: Analysis of Drive invoked")
    }

    internal func processLocationDenied() {
        Slim.info("[ZendriveManager]: User denied Location to Zendrive SDK.")
    }

    internal func processLocationApproved() {
        Slim.info("[ZendriveManager]: User approved Location to Zendrive SDK.")
    }

    internal func processAccidentDetected(_ accidentInfo: ZendriveAccidentInfo) {
        Slim.info("[ZendriveManager]: Accident detected by Zendrive SDK.")
    }
}
