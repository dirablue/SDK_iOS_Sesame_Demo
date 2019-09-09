//
//  AppDelegate.swift
//  Sesame2SDKDemo
//
//  Created by tse on 2019/9/5.
//  Copyright © 2019 co.candyhouse. All rights reserved.
//

import UIKit
import SesameSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // AWS Mobile Client
        AWSCognitoOAuthService.shared.applicationDidLaunch(application: application, launchOptions: launchOptions)
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
