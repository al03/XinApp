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


class InterfaceController: WKInterfaceController {
    @IBOutlet var rateLabel: WKInterfaceLabel!


    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .running
        workoutConfiguration.locationType = .unknown
        
        do {
            let workoutSession = try HKWorkoutSession(configuration: workoutConfiguration)
            
            let healthStore = HKHealthStore()
            healthStore.start(workoutSession)
            
            HeartReateController.reloadRootControllers(withNames: ["HeartReateController"], contexts: [workoutConfiguration])
            
        } catch  {
            
        }
        
        

        
        // Configure interface objects here.
    }
    
    @IBAction func startClick() {
        
        
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
