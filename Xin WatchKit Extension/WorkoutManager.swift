//
//  WorkoutManager.swift
//  Xin
//
//  Created by Albert on 01/04/2017.
//  Copyright © 2017 Albert Mao. All rights reserved.
//

import Foundation
import HealthKit

protocol WorkoutManagerDelegate: class {
    func didUpdateForehandSwingCount(_ manager: WorkoutManager, forehandCount: Int)
    func didUpdateBackhandSwingCount(_ manager: WorkoutManager, backhandCount: Int)
}

class WorkoutManager: MotionManagerDelegate {
    // MARK: Properties
    let motionManager = MotionManager()
    let healthStore = HKHealthStore()
    
    
    var isstart = false
    
    
    var heartRateUpdate:((String) -> Void)? = nil
    
    
    weak var delegate: WorkoutManagerDelegate?
    var session: HKWorkoutSession?
    
    // MARK: Initialization
    
    init() {
        motionManager.delegate = self
        
    }
    
    // MARK: WorkoutManager
    @discardableResult
    func startWorkout() -> Bool {
        // If we have already started the workout, then do nothing.
        if (session != nil) {
            return true
        }
        
        
        // Configure the workout session.
        let workoutConfiguration = HKWorkoutConfiguration()
        workoutConfiguration.activityType = .other
        workoutConfiguration.locationType = .indoor
        
        do {
            session = try HKWorkoutSession(configuration: workoutConfiguration)
        } catch {
            fatalError("Unable to create the workout session!")
        }
        
        // Start the workout session and device motion updates.
        

        let energyBurned = HKQuantity(unit: HKUnit.kilocalorie(),
                                      doubleValue: 425.0)
        
        let distance = HKQuantity(unit: HKUnit.mile(),
                                  doubleValue: 3.2)
        
        let run = HKWorkout(activityType: .running,
                            start: Date(),
                            end: Date.distantFuture,
                            duration: 60,
                            totalEnergyBurned: energyBurned,
                            totalDistance: distance,
                            metadata: nil)
        
        
        var healthKitTypesToRead = Set<HKObjectType>()
        let readHeartType = HKObjectType.quantityType(forIdentifier: .heartRate)
        healthKitTypesToRead.insert(readHeartType!)
        
        
        var healthKitTypesToWrite = Set<HKSampleType>()
        let writeType = HKSampleType.quantityType(forIdentifier: .heartRate)
        healthKitTypesToWrite.insert(writeType!)
        
        let workoutType = HKObjectType.workoutType()
        healthKitTypesToWrite.insert(workoutType)
        
        if healthStore.authorizationStatus(for: workoutType) == HKAuthorizationStatus.notDetermined  {
            
            healthStore.requestAuthorization(toShare: healthKitTypesToWrite,
                                             read: healthKitTypesToRead) { (success, error) -> Void in
                if success {
                    self.startWorkout()
                }
            }
            
            return false
        }
        
        
        // Save the workout before adding detailed samples.
        healthStore.save(run) { (success, error) -> Void in
            guard success else {
                // Perform proper error handling here...
                fatalError("*** An error occurred while saving the " +
                    "workout: \(String(describing: error?.localizedDescription))")
            }
            let intervals = [Date(), Date.distantFuture];
            
            // Add optional, detailed information for each time interval
            var samples: [HKQuantitySample] = []
            
            
            guard let energyBurnedType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.activeEnergyBurned) else {
                fatalError("*** Unable to create an energy burned type ***")
            }
            
            let energyBurnedPerInterval = HKQuantity(unit: HKUnit.kilocalorie(),
                                                     doubleValue: 15.5)
            
            let energyBurnedPerIntervalSample =
                HKQuantitySample(type: energyBurnedType, quantity: energyBurnedPerInterval,
                                 start: intervals[0], end: intervals[1])
            
            samples.append(energyBurnedPerIntervalSample)
            
            guard let heartRateType = HKObjectType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate) else {
                fatalError("*** Unable to create a heart rate type ***")
            }
            
            let heartRateForInterval = HKQuantity(unit: HKUnit(from:"count/min"), doubleValue: 95.0)
            
            let heartRateForIntervalSample = HKQuantitySample(type: heartRateType, quantity: heartRateForInterval,
                                                              start: intervals[0], end: intervals[1])
            
            if self.healthStore.authorizationStatus(for: energyBurnedPerIntervalSample.sampleType) == HKAuthorizationStatus.notDetermined  {
                
                self.healthStore.requestAuthorization(toShare: healthKitTypesToWrite, read: healthKitTypesToRead) { (success, error) -> Void in
                    if success {
                        self.startWorkout()
                    }
                }
                
                return
            }
            
            samples.append(heartRateForIntervalSample)
            
            // Continue adding detailed samples...
            
            // Add all the samples to the workout.
            self.healthStore.add(samples, to: run) { (success, error) -> Void in
                guard success else {
                    // Perform proper error handling here...
                    fatalError("*** An error occurred while adding a " +
                        "sample to the workout: \(String(describing: error?.localizedDescription))")
                }
            }
        }
        
        healthStore.start(session!)
        motionManager.startUpdates()
        
        isstart = true
        
        getTodaysHeartRates()
        
        
        let heartRateQuery = self.createStreamingQuery()
        healthStore.execute(heartRateQuery)
        
        return true
    }
    
    
    func stopWorkout() {
        // If we have already stopped the workout, then do nothing.
        if (session == nil) {
            return
        }
        
        isstart = false
        
        // Stop the device motion updates and workout session.
        motionManager.stopUpdates()
        healthStore.end(session!)
        
        // Clear the workout session.
        session = nil
    }
    
    // MARK: MotionManagerDelegate
    
    func didUpdateForehandSwingCount(_ manager: MotionManager, forehandCount: Int) {
        delegate?.didUpdateForehandSwingCount(self, forehandCount: forehandCount)
    }
    
    func didUpdateBackhandSwingCount(_ manager: MotionManager, backhandCount: Int) {
        delegate?.didUpdateBackhandSwingCount(self, backhandCount: backhandCount)
    }
    
    
    /// query heart rates history
    func getTodaysHeartRates()
    {
        //predicate
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.year, .month, .day], from: now)
        guard let startDate:Date = calendar.date(from: components) else { return }
        let endDate:Date? = calendar.date(byAdding: .day, value: 1, to: startDate, wrappingComponents: false)
        
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        //descriptor
        let sortDescriptors = [
            NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        ]
        
        let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        
        
        let heartRateQuery = HKSampleQuery(sampleType: heartRateType,
                                           predicate: predicate,
                                           limit: 25,
                                           sortDescriptors: sortDescriptors)
        { (query:HKSampleQuery, results:[HKSample]?, error:Error?) -> Void in
            
            guard error == nil else { print("error"); return }
            
            self.printHeartRateInfo(results: results)
            
        }
        healthStore.execute(heartRateQuery)
        
    }
    
    
    private func printHeartRateInfo(results:[HKSample]?)
    {
        for iter in 1..<results!.count
        {
            guard let currData:HKQuantitySample = results![iter] as? HKQuantitySample else { return }
            
            print("[\(iter)]")
            print("Heart Rate: \(currData.quantity.doubleValue(for: HKUnit(from:"count/min")))")
            print("quantityType: \(currData.quantityType)")
            print("Start Date: \(currData.startDate)")
            print("End Date: \(currData.endDate)")
            print("Metadata: \(String(describing: currData.metadata))")
            print("UUID: \(currData.uuid)")
            print("Source: \(currData.sourceRevision)")
            print("Device: \(String(describing: currData.device))")
            print("---------------------------------\n")
        }
    }
    
    
    
    
    private func createStreamingQuery() -> HKQuery
    {
        let queryPredicate  = HKQuery.predicateForSamples(withStart: Date(), end: nil)
        let heartRateType:HKQuantityType   = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.heartRate)!
        let query:HKAnchoredObjectQuery = HKAnchoredObjectQuery(type: heartRateType, predicate: queryPredicate, anchor: nil, limit: HKObjectQueryNoLimit) { (query, samples, deletedObjects, anchor, error) in
            if let errorFound:Error = error
            {
                print("query error: \(errorFound.localizedDescription)")
            }
            else
            {
                //printing heart rate
                if let samples = samples as? [HKQuantitySample]
                {
                    if let quantity = samples.last?.quantity
                    {
                        print("\(quantity.doubleValue(for: HKUnit(from:"count/min")))")
                    }
                }
            }
            
        }
        
        
        query.updateHandler = { (query:HKAnchoredObjectQuery, samples: [HKSample]?, deletedObjects:[HKDeletedObject]?, anchor:HKQueryAnchor?, error:Error?) -> Swift.Void in
            
            
            if let errorFound:Error = error
            {
                print("query-handler error : \(errorFound.localizedDescription)")
            }
            else
            {
                //printing heart rate
                if let samples = samples as? [HKQuantitySample]
                {
                    if let quantity = samples.last?.quantity
                    {
                        print("\(quantity.doubleValue(for: HKUnit(from:"count/min")))")
                        
                       self.heartRateUpdate?("\(quantity.doubleValue(for: HKUnit(from:"count/min")))")
                    }
                }
            }
            
        }
        
        
        return query
    }
    
    

    
}
