//
//  AppDelegate.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/11/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import Firebase
import CoreLocation


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var authListener: AuthStateDidChangeListenerHandle?
    
    var locationManager: CLLocationManager?
    var coordinates: CLLocationCoordinate2D?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        //auto login
        authListener = Auth.auth().addStateDidChangeListener({ (auth, user) in
           Auth.auth().removeStateDidChangeListener(self.authListener!)
            
            if user != nil {
                if UserDefaults.standard.object(forKey: kCURRENTUSER) != nil {
                    DispatchQueue.main.async {
                        self.goToApp()
                    }
                }
            }
        })
        
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        locationManagerStart()
    }
    
    
    //MARK: helpers
    
    func goToApp(){
        
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: USER_DID_LOGIN_NOTIFICATION), object: nil, userInfo: [kUSERID:FUser.currentId()])
        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApp") as! UITabBarController
        window?.rootViewController = mainView
        }

}


extension AppDelegate: CLLocationManagerDelegate {
    
    func locationManagerStart(){
        
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse || CLLocationManager.authorizationStatus() == .authorizedAlways {
            
            if locationManager != nil {
                locationManager!.delegate = self
                locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            } else {
                locationManager = CLLocationManager()
                locationManager!.delegate = self
                locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            }
            
            locationManager!.startUpdatingLocation()
        
        
        }
        
        else if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .denied {
            
            print("please allow location access in settings")
           
        }
        
        else if CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager = CLLocationManager()
            locationManager!.requestWhenInUseAuthorization()
            locationManagerStart()
        }
        
    }
    
    func locationManagerStop(){
        
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }
    
    func didHaveLocationAccess() -> Bool{
        if locationManager != nil {
            return true
        }
        return false
    }

    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("faild to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted:
            print("restricted")
        case .denied:
            locationManager = nil
            print("denied location access")

        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        print(locations)
        coordinates = locations.last?.coordinate
    }
    
    
}

