//
//  AppDelegate.swift
//  Yogie
//
//  Created by Erica Y Stevens on 4/22/17.
//  Copyright © 2017 C4Q. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    fileprivate var _authHandle: AuthStateDidChangeListenerHandle!
    var user: User?
    var shouldPresentAppCount = 0
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
//        UIApplication.shared.statusBarStyle = .lightContent
//        UIApplication.shared.isStatusBarHidden = false
        UINavigationBar.appearance().backgroundColor = UIColor.YogieTheme.primaryColor
        
        _authHandle = Auth.auth().addStateDidChangeListener({ (auth: Auth, user: User?) in
            if user != nil {
                //show main app
                
                if self.shouldPresentAppCount < 1 {
                self.shouldPresentAppCount += 1
                print("APP WAS PRESENTED \(self.shouldPresentAppCount) TIMES")
                self.presentMainApp()
                }
    
            } else {
                //Present only if user is not authenticated
                let loginController = SignInRegisterViewController()
                self.window = UIWindow(frame: UIScreen.main.bounds)
                self.window?.rootViewController = loginController
                self.window?.makeKeyAndVisible()
            }
        })
        
        
        return true
    }
    
    func presentMainApp() {
//        shouldPresentApp = false
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let feedTVC = storyboard.instantiateViewController(withIdentifier: "NewsfeedVC") as! NewsfeedTableViewController
        let profileVC = storyboard.instantiateViewController(withIdentifier: "UserProfileTVC") as! ProfileTableViewController
        let takeFreeYogieVC = storyboard.instantiateViewController(withIdentifier: "CameraVC") as! YogieCaptureCameraViewController
        
        let feedNavTVC = UINavigationController(rootViewController: feedTVC)
        
        
        let tabBarController = UITabBarController()
        
        let controllers = [feedNavTVC, takeFreeYogieVC, profileVC ] //should be feed, yogie, challenges
        tabBarController.viewControllers = controllers
        tabBarController.tabBar.barTintColor = UIColor.YogieTheme.darkPrimaryColor
        tabBarController.tabBar.tintColor = .white
       
        tabBarController.tabBar.isTranslucent = true
        
        var profileIcon = UIImage(named: "userProfileIcon44x44")
        profileIcon = profileIcon?.withRenderingMode(.alwaysTemplate)
        
        profileVC.tabBarItem = UITabBarItem(title: nil, image: profileIcon, tag: 2)
        profileVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        var takeYogieIcon = UIImage(named: "takeYogieIcon_40x40")
        takeYogieIcon = takeYogieIcon?.withRenderingMode(.alwaysTemplate)
        
        takeFreeYogieVC.tabBarItem = UITabBarItem(title: nil, image: takeYogieIcon, tag: 1)
        takeFreeYogieVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        
        var haumIcon = UIImage(named: "haumIcon_75x75")
        haumIcon = haumIcon?.withRenderingMode(.alwaysTemplate)
        
     
        feedNavTVC.tabBarItem = UITabBarItem(title: nil, image: haumIcon, tag: 0)
        feedNavTVC.tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = tabBarController
        self.window?.makeKeyAndVisible()
    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}

