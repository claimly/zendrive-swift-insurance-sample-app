//
//  AppDelegate.swift
//  InsuranceSample
//
//  Created by Yogesh on 11/27/17.
//  Copyright © 2017 Zendrive. All rights reserved.
//

import UIKit
import MBProgressHUD

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var rootNavigationController: UINavigationController?

    internal func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()
        initializeApplication(application: application, options: launchOptions)
        Slim.info("[AppDelegate]: didFinishLaunchingWithOptions")
        return true
    }

    internal func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        Slim.info("[AppDelegate]: applicationWillResignActive")
    }

    internal func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Slim.info("[AppDelegate]: applicationDidEnterBackground")
    }

    internal func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        Slim.info("[AppDelegate]: applicationWillEnterForeground")
    }

    internal func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Slim.info("[AppDelegate]: applicationDidBecomeActive")
    }

    internal func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        Slim.info("[AppDelegate]: applicationWillTerminate")
    }

    private func initializeApplication(application: UIApplication?, options: Dictionary<UIApplicationLaunchOptionsKey, Any>?) {
        // Start crucial components like logger, crash reporting etc.
        AppLogger.initializeDefaultLoggers()

        // Load the application
        reloadApplication()
    }

    public func reloadApplication() {
        let driverId = UserDefaultsManager.sharedInstance.driverId()
        Slim.info("[AppDelegate]: reloadApplication with driverId: \(String(describing: driverId))")
        if (driverId != nil) {
            if (window?.rootViewController == nil) {
                // It is generally better to display a loading page while singletons and important
                // libraries are loaded before loading the initial view controller, this will ensure
                // loading complex UI in memory does not affect the core functionality of the
                // application
                let launchScreen: UIViewController = UIStoryboard.init(
                    name: "LaunchScreen", bundle: Bundle.main).instantiateInitialViewController()!
                window?.rootViewController = launchScreen
            }

            MBProgressHUD.showAdded(to: self.window, animated: true)

            // Load any singletons or libraries that need user information, e.g. logger, ZendriveSDK
            AppLogger.initializeLogglyLogger(userId: driverId)
            ZendriveManager.sharedInstance.initializeSDKForDriverId(
                driverId: driverId!,
                successHandler: {
                    MBProgressHUD.hide(for: self.window, animated: true)

                    // All important non-UI components loaded, load application UI
                    self.loadInitialViewController(driverId: driverId)
            }, failureHandler: { (error) in
                MBProgressHUD.hide(for: self.window, animated: true)
                let alert: UIAlertController =
                    UIAlertController.init(title: "Initialization Failed",
                                           message: error!.localizedFailureReason,
                                           preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction.init(
                    title: "Retry", style: UIAlertActionStyle.default,
                    handler: { (action) in
                        self.reloadApplication()
                }))
                self.window?.rootViewController?.present(alert, animated: true, completion: nil)
            })
        }
        else {
            // Disable everything that uses driverId, e.g. ZendriveSDK
            TripManager.sharedInstance.goOffDuty()

            // Load UI
            loadInitialViewController(driverId: driverId)
        }
    }

    private func loadInitialViewController(driverId: String?) {
        Slim.info("[AppDelegate]: loadInitialViewController")
        let initialViewController: UIViewController
        if (driverId != nil) {
            // User info available, open either OffDuty or OnDuty View Controller based on the state
            if (UserDefaultsManager.sharedInstance.isUserOnDuty()) {
                initialViewController = OnDutyViewController.init()
            }
            else {
                initialViewController = OffDutyViewController.init()
            }
        }
        else {
            // No user information available, open LoginViewController
            initialViewController = LoginViewController.init()
        }

        if (rootNavigationController == nil) {
            rootNavigationController = UINavigationController.init(rootViewController: initialViewController)
            rootNavigationController?.navigationBar.barTintColor = UIColor.init(red: 56/256.0, green: 159/256.0, blue:116/256.0, alpha: 1.0)
            rootNavigationController?.navigationBar.titleTextAttributes =
                [NSAttributedStringKey.foregroundColor: UIColor.white]
            window?.rootViewController = rootNavigationController
        }
        else {
            rootNavigationController?.setViewControllers([initialViewController], animated: true)
        }
    }
}
