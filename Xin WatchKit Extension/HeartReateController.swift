//
//  HeartReateController.swift
//  Xin
//
//  Created by Albert Mao on 12/18/16.
//  Copyright © 2016 Albert Mao. All rights reserved.
//

import WatchKit
import HealthKit

class HeartReateController: WKInterfaceController {
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        guard let workoutConfiguration = context as? HKWorkoutConfiguration else { return }
        
    }
}
