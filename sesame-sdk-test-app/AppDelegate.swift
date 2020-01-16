//
//  AppDelegate.swift
//  sesame-sdk-test-app
//
//  Created by Cerberus on 2019/08/05.
//  Copyright © 2019 Cerberus. All rights reserved.
//

import UserNotifications
import SesameSDK
import AWSCognitoIdentityProvider

let CHAppGroupApp = "group.candyhouse.widget" // the same as widget

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
        launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        CHSetting.shared.setAppGroup(appGrroup: CHAppGroupApp)//if you use widget Today extention

        let isNotFirstRun = UserDefaults.standard.bool(forKey: "CHisFirstRun")
        if(isNotFirstRun == false){
            CHAccountManager.shared.logout()
            AWSCognitoOAuthService.shared.logout()
        }
        UserDefaults.standard.setValue(true, forKey: "CHisFirstRun")
        L.d("🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱🌱")
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: {
            granted,error in
        })
        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        CHAccountManager.shared.updateApnsDeviceToken(deviceToken: deviceToken.toHexString())
        UserDefaults.standard.setValue(deviceToken.toHexString(), forKey: "devicePushToken")
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        L.d("didFailToRegisterForRemoteNotificationsWithError error",error)
    }

    func applicationWillResignActive(_ application: UIApplication) {//退出
        CHBleManager.shared.disableScan()
        CHBleManager.shared.disConnectAll()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {//進入
        CHBleManager.shared.enableScan()
    }

}

extension AppDelegate:UNUserNotificationCenterDelegate{

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        if let sessions = userInfo["aps"] as? [String: Any]{
            if  let action:String =  sessions["action"] as? String {
                if (action == "KEYCHAIN_FLUSH"){
                    let viewController = self.window?.rootViewController as! GeneralTabViewController
                    viewController.delegateHome?.refleshKeyChain()
                }
            }
        }
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert,.sound,.badge])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            L.d("Dismiss Action")
        case UNNotificationDefaultActionIdentifier:
            L.d("Default",response.notification.request)
        case "Snooze":
            L.d("Snooze")
        case "Delete":
            L.d("Delete")
        default:
            L.d("Unknown action")
        }
        completionHandler()
    }
}
