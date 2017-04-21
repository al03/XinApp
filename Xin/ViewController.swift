//
//  ViewController.swift
//  Xin
//
//  Created by Albert Mao on 12/18/16.
//  Copyright © 2016 Albert Mao. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textField: UITextField!
    
    let connet = Connect("ws://192.168.36.58:8080")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        connet.connet()
        
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func sendMSG(_ sender: Any) {
        connet.send(textField.text!)
    }

}

