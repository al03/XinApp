//
//  InterfaceController.swift
//  Xin WatchKit Extension
//
//  Created by Albert Mao on 12/18/16.
//  Copyright © 2016 Albert Mao. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit
import WatchConnectivity

class InterfaceController: WKInterfaceController, WorkoutManagerDelegate {
    // MARK: Properties
    
    let workoutManager = WorkoutManager()
    var active = false
    var forehandCount = 0
    var backhandCount = 0
    
    // MARK: Interface Properties
    
    @IBOutlet weak var titleLabel: WKInterfaceLabel!
    @IBOutlet weak var backhandCountLabel: WKInterfaceLabel!
    @IBOutlet weak var forehandCountLabel: WKInterfaceLabel!
    @IBOutlet var startBtn: WKInterfaceButton!
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        workoutManager.delegate = self
    }
    
    override func willActivate() {
        super.willActivate()
        active = true
        
        // On re-activation, update with the cached values.
        updateLabels()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        active = false
    }
    
    // MARK: Interface Bindings
    
    @IBAction func startClick() {
    
        if  workoutManager.isstart {
            stop()
            startBtn.setTitle("start")
            return
        }

        titleLabel.setText("Workout started")
        let isSuc = workoutManager.startWorkout()
        
        workoutManager.heartRateUpdate = { rate in
            self.backhandCountLabel.setText(rate)
        }
        
        if isSuc || workoutManager.isstart {
            startBtn.setTitle("stop")
        }
    }

    
    func stop() {
        titleLabel.setText("Workout stopped")
        workoutManager.stopWorkout()
    }
    
    // MARK: WorkoutManagerDelegate
    
    func didUpdateForehandSwingCount(_ manager: WorkoutManager, forehandCount: Int) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.forehandCount = forehandCount
            self.updateLabels()
        }
    }
    
    func didUpdateBackhandSwingCount(_ manager: WorkoutManager, backhandCount: Int) {
        /// Serialize the property access and UI updates on the main queue.
        DispatchQueue.main.async {
            self.backhandCount = backhandCount
            self.updateLabels()
        }
    }
    
    // MARK: Convenience
    
    func updateLabels() {
        if active {
            forehandCountLabel.setText("\(forehandCount)")
//            backhandCountLabel.setText("\(backhandCount)")
        }
    }
    
    
    
    
    
    
    
    
   }
