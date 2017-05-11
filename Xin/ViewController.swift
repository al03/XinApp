//
//  ViewController.swift
//  Xin
//
//  Created by Albert Mao on 12/18/16.
//  Copyright © 2016 Albert Mao. All rights reserved.
//

import UIKit
import WatchConnectivity

class ViewController: UIViewController, WatchConnectivityManagerPhoneDelegate {
    @IBOutlet weak var textField: UITextField!
    
    var connect:Connect?
    @IBOutlet weak var rateLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.text = "192.168.36.58:8080"
        WatchConnectivityManager.sharedConnectivityManager.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func connectClick(_ sender: Any) {
        
        guard let address = textField.text else {
            
            let action = UIAlertAction(title: "input server address", style: .default, handler: nil)
            let alert = UIAlertController()
            alert.addAction(action)
            
            present(alert, animated: true, completion: nil)
            
            return
        }
        
        let wsAddress = "ws://\(address)"
        
        if (connect != nil) {
            connect?.disconnect()
        }
        
        connect = Connect(wsAddress)
        connect?.connect()
    }
    
    @IBAction func testConnect(_ sender: Any) {
        let random = Int(arc4random_uniform(60)) + 60
       connect?.send("\(random)")
    }
    
    func creatConnectivity() {
        
        let defaultSession = WCSession.default()
        defaultSession.delegate = WatchConnectivityManager.sharedConnectivityManager
        defaultSession.activate()
        
    }
    
    
    func watchConnectivityManager(_ manager: WatchConnectivityManager, msg: String) {
        DispatchQueue.main.async {
           self.rateLabel.text = msg
        }
        connect?.send(msg)
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

