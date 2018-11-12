//
//  AppLogger.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit

class AppLogger: NSObject {
    static var logglyDestination: SlimLogglyDestination?
    static func initializeDefaultLoggers() {
        #if DEBUG
            // Duplicate to Console, enable only in debug
            SlimConfig.consoleLogLevel = LogLevel.trace
            Slim.addLogDestination(ConsoleDestination())
        #endif
    }

    static func initializeLogglyLogger(userId: String!) {
        if (logglyDestination != nil) {
            return
        }

        let logglyKey: String? = nil // Replace with your loggly API key
        if (logglyKey == nil) {
            return;
        }
        let appName: String = "SwiftInsuranceSample"

        SlimLogglyConfig.logglyUrlString = "https://logs-01.loggly.com/bulk/" + logglyKey! +
        "/tag/" + appName + "/"

        SlimLogglyConfig.logglyLogLevel = LogLevel.debug
        SlimLogglyConfig.maxEntriesInBuffer = 10
        logglyDestination = SlimLogglyDestination()
        logglyDestination!.userid = userId // UserId can also be passed as tag along with appName
        Slim.addLogDestination(logglyDestination!)
    }
}
