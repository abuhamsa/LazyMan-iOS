//
//  AppDelegate.swift
//  LazyMan-iOS
//
//  Created by Nick Thompson on 2/18/18.
//  Copyright © 2018 Nick Thompson. All rights reserved.
//

import UIKit
import LazyManCore
import Firebase
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GCKLoggerDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Configures navigation bar
        UINavigationBar.appearance().barStyle = .black
        UINavigationBar.appearance().isTranslucent = false

        // Configures table view selection to be darker
        let selectedView = UIView()
        selectedView.backgroundColor = UIColor.darkGray
        UITableViewCell.appearance().selectedBackgroundView = selectedView
        UITableViewCell.appearance().backgroundColor = .black

        // Configures split view controller
        if let splitViewController = self.window?.rootViewController as? UISplitViewController {
            splitViewController.preferredDisplayMode = .allVisible
            splitViewController.view.backgroundColor = .black

            splitViewController.delegate = (splitViewController.viewControllers.first as? UINavigationController)?
                .viewControllers.first as? GameListViewController

            if let navigationController = splitViewController.viewControllers.last as? UINavigationController {
                navigationController.topViewController?.navigationItem.leftBarButtonItem =
                    splitViewController.displayModeButtonItem
            }
        }

        // Configure Firebase/Crashlytics
        FirebaseApp.configure()

        // Configure ChromeCast
        let criteria = GCKDiscoveryCriteria(applicationID: chromecastAppID)
        let options = GCKCastOptions(discoveryCriteria: criteria)
        options.physicalVolumeButtonsWillControlDeviceVolume = true
        GCKCastContext.setSharedInstanceWith(options)

        GCKCastContext.sharedInstance().useDefaultExpandedMediaControls = true

        let filter = GCKLoggerFilter()
        filter.minimumLevel = .error
        GCKLogger.sharedInstance().filter = filter

        // Enable logger.
        GCKLogger.sharedInstance().delegate = self

        // Wrap main view in the GCKUICastContainerViewController and display the mini controller.
        let appStoryboard = UIStoryboard(name: "GameList", bundle: nil)
        let navigationController = appStoryboard.instantiateInitialViewController()!
        let castContainerVC = GCKCastContext.sharedInstance().createCastContainerController(for: navigationController)
        castContainerVC.miniMediaControlsItemEnabled = true
        // Color the background to match the embedded content
        castContainerVC.view.backgroundColor = .white

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = castContainerVC
        window?.makeKeyAndVisible()

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of
        // temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the
        // application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks.
        // Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store
        // enough application state information to restore your application to its current state in
        // case it is terminated later.
        // If your application supports background execution, this method is called instead of
        // applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo
        // many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive.
        // If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate.
        // See also applicationDidEnterBackground:.
    }

    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if #available(iOS 11.0, *) {
            return UIInterfaceOrientationMask.portrait
        } else if let presentedViewController = window?.rootViewController?.presentedViewController,
            String(describing: type(of: presentedViewController)) == "AVFullScreenViewController" {
            return UIInterfaceOrientationMask.allButUpsideDown
        } else {
            UIDevice.current.setValue(UIDeviceOrientation.portrait.rawValue, forKey: "orientation")
            return UIInterfaceOrientationMask.portrait
        }
    }

    // MARK - ChromeCast debug

    func logMessage(_ message: String,
                    at level: GCKLoggerLevel,
                    fromFunction function: String,
                    location: String) {
        #if DEBUG
        print(function + " - " + message)
        #endif
    }
}
