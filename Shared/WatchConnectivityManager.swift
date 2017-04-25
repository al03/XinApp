//
//  WatchConnectivityManager.swift
//  Xin
//
//  Created by Albert on 25/04/2017.
//  Copyright © 2017 Albert Mao. All rights reserved.
//

import Foundation
import WatchConnectivity


protocol WatchConnectivityManagerPhoneDelegate: class {
    func watchConnectivityManager(_ manager: WatchConnectivityManager, msg: String)
}

protocol WatchConnectivityManagerWatchDelegate: class {
    func watchConnectivityManager(_ manager: WatchConnectivityManager, msg: String)
}

class WatchConnectivityManager: NSObject, WCSessionDelegate {

    
    static let sharedConnectivityManager = WatchConnectivityManager()
    
    #if os(iOS)
    weak var delegate: WatchConnectivityManagerPhoneDelegate?
    #else
    weak var delegate: WatchConnectivityManagerWatchDelegate?
    #endif
    
    func configure(_ applicationContext: [String: Any]) {
        guard let rate = applicationContext["rate"] as? String else {
            return
        }
       
        delegate?.watchConnectivityManager(self, msg: rate)
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        
        print("session in state: \(session.activationState.rawValue), received context: \(applicationContext)")
        
        configure(applicationContext)
        
        #if os(iOS)
            print("session watch directory URL: \(String(describing: session.watchDirectoryURL?.absoluteString))")
        #endif
    }
    
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        #if os(watchOS)
            
        #endif
    }
    
    func session(_ session: WCSession, didFinish userInfoTransfer: WCSessionUserInfoTransfer, error: Error?) {
        if let error = error {
            print("\(error.localizedDescription)")
        } else {
            print("completed transfer")
        }
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("session sctivation failed with error: \(error.localizedDescription)")
            return
        }
        
        print("session activated with state: \(activationState.rawValue)")
        
        configure(session.receivedApplicationContext)
        
        #if os(iOS)
            print("session watch directory URL: \(String(describing: session.watchDirectoryURL?.absoluteString))")
        #endif
    }
    
    #if os(iOS)
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("session did become inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("session dic deactivate")
        session.activate()
    }
    
    #endif
}
