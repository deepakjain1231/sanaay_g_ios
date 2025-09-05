//
//  AppDelegate.swift
//  Sanaay
//
//  Created by Deepak Jain on 02/08/22.
//

import UIKit
import Firebase
import FirebaseAuth
import SVProgressHUD
import AuthenticationServices

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UIGestureRecognizerDelegate {

    var window: UIWindow?
    var sparshanAssessmentDone = false
    var dic_patient_response: PatientListDataResponse?
    private let viewModel: RegisterViewModel = RegisterViewModel()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        sleep(2)
        
        self.setProgressHuD()
        
        if kUserDefaults.value(forKey: AppMessage.USER_LOGIN) != nil {
            self.app_setHomeScreen()
        }
        
        //Firebase Setup
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        //Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        //*****************************//                                                                                                                                                                                                                                                              

        registerForPushNotifications()
        
        return true
    }
    
    
    //MARK: - Custom Setup
    func setProgressHuD() {
        SVProgressHUD.setFont(UIFont.AppFontRegular(14))
        SVProgressHUD.setDefaultMaskType(SVProgressHUDMaskType.gradient)
        SVProgressHUD.setForegroundColor(AppColor.app_GreenColor)
    }
    
    func app_setHomeScreen() {
        //SET HOME VIEWCONTROLLER
        let obj = Story_Dashboard.instantiateViewController(withIdentifier: "HomeVC") as! HomeVC
        let navController = UINavigationController(rootViewController: obj)
        navController.interactivePopGestureRecognizer?.isEnabled = true
        navController.interactivePopGestureRecognizer?.delegate = self
        navController.isNavigationBarHidden = true
        self.animatedAddtoRoot(toView: navController)
    }
    
    func app_setLogin() {
        //SET LOGIN VIEWCONTROLLER TO ROOT
        let login = Story_Main.instantiateViewController(withIdentifier: "navMain")
        self.animatedAddtoRoot(toView: login)
    }
    
    func animatedAddtoRoot(toView:UIViewController) {
        UIView.transition(with: window!, duration: 0.3, options: .transitionCrossDissolve, animations: {
            self.window?.rootViewController = toView
        }, completion: { completed in
            // maybe do something here
            self.window?.makeKeyAndVisible()
        })
    }
    
    
    func AlertLogOut() {
        let alert = UIAlertController.init(title: nil, message: "", preferredStyle: UIAlertController.Style.alert)
        
        let attributedMessage = NSMutableAttributedString(string: "Are you sure you want to logout?", attributes: [NSAttributedString.Key.font: UIFont.AppFontMedium(16)])
        alert.setValue(attributedMessage, forKey: "attributedMessage")
        
        let actionCancel = UIAlertAction.init(title: "Cancel", style: UIAlertAction.Style.cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        
        let actionOK = UIAlertAction.init(title: "Logout", style: UIAlertAction.Style.destructive, handler: { (action) in
            clearDataOnLogout()
            appDelegate.app_setLogin()
        })
        
        alert.addAction(actionOK)
        alert.addAction(actionCancel)
        self.window?.rootViewController?.present(alert, animated: true, completion: nil)
        for textfield: UIView in (alert.textFields ?? [])! {
            let container: UIView = textfield.superview!
            let effectView: UIView = container.superview!.subviews[0]
            container.backgroundColor = UIColor.clear
            effectView.removeFromSuperview()
        }
    }
}

extension AppDelegate: MessagingDelegate, UNUserNotificationCenterDelegate {
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, forRemoteNotification userInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        debugPrint("handleActionWithIdentifier=======>>\(userInfo)")
    }
    
    func registerForPushNotifications() {
        //Push Notification Register
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            if let error = error {
                debugPrint("[AppDelegate] requestAuthorization error: \(error.localizedDescription)")
                return
            }
            UNUserNotificationCenter.current().getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus != .authorized {
                    return
                }
                DispatchQueue.main.async(execute: {
                    UIApplication.shared.registerForRemoteNotifications()
                })
            })
        }
        //Parse errors and track state
        UIApplication.shared.registerForRemoteNotifications()
    }

    
    
    func configNotifications() {
        let actin = UNNotificationAction.init(identifier: "id", title: "Show Notification", options: [.foreground, .destructive])
        let cat = UNNotificationCategory.init(identifier: "id.cat", actions: [actin], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([cat])
    }
    //******************************************************************************************//
    //******************************************************************************************//
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")

        var device_token = deviceToken.hexString()
        if device_token.isEmpty {
            device_token = ""
        }
        
        Messaging.messaging().apnsToken = deviceToken
    }
    //=============================================================================================//
    //=============================================================================================//
    //=============================================================================================//
    
    
    //**********************************************************************************************//
    //**********************************************************************************************//
    //**********************************************************************************************//
    

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    //MARK:-  Firebase Message Delegates
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        var fcm_token = "IOS1234567890IOS"
        if let str_FCM_Token = fcmToken {
            if str_FCM_Token != "" {
                fcm_token = str_FCM_Token
            }
        }
        print("Firebase registration token: \(fcm_token)")
        UserDefaults.standard.set(fcm_token, forKey: AppMessage.firebase_token)
        UserDefaults.standard.synchronize()
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print(userInfo)
        
        var isActive = false
        if application.applicationState != .active {
            isActive = true
        }

        DispatchQueue.main.async {
            self.openNotificationViewController(userInfo, isActive, identifier: "", isBackground: false)
        }
        application.applicationIconBadgeNumber = 0
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    /** For iOS 10 and above - Foreground**/

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: (UNNotificationPresentationOptions) -> Void) {
        print("APPDELEGATE: willPresentResponseWithCompletionHandler \(notification.request.content.userInfo)")

        completionHandler([.badge, .sound, .alert])
    }
        
    /** For iOS 10 and above - Background **/
    // Handle user interaction to notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        defer { completionHandler() }
        guard response.actionIdentifier ==
            UNNotificationDefaultActionIdentifier else {
                return
        }
        
        // Perform actions here
        self.openNotificationViewController(response.notification.request.content.userInfo, false, identifier: "", isBackground: true)
    }
    

    func openNotificationViewController(_ dict: [AnyHashable: Any], _ is_Active: Bool, identifier: String, isBackground: Bool) {
        print("Push Notification Tapped with Custom Extras: \(dict)")
        
    }
         
}
//*********************************************************************************************//
//*********************************************************************************************//


extension Data {
    func hexString() -> String {
        return self.reduce("") { string, byte in
            string + String(format: "%02X", byte)
        }
    }
}
