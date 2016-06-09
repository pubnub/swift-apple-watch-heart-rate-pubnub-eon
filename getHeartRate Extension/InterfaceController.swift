//
//  InterfaceController.swift
//  getHeartRate Extension
//
//  Created by Elisabeth Siegle on 6/7/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import Foundation
import HealthKit
import WatchKit
import WatchConnectivity


class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate {
    
    @IBOutlet var label: WKInterfaceLabel!
   
    @IBOutlet var heart: WKInterfaceImage!

    @IBOutlet var startStopBtn: WKInterfaceButton!
    let healthStore = HKHealthStore()
    
    var hrVal : Double? = 2.4 //will change
    
    var wcSesh : WCSession!
    
    //bool = workout state
    var currMoving = false //not working out
    
    // define the activity type and location
    var workoutSesh : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
        guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            label.setText("unavailable🙀")
            return
        }
        
//        //could also be
//        if(HKHealthStore.isHealthDataAvailable() == true) {
//            label.setText("available😼")
//            return
//        }
//        else {
//            label.setText("unavailable🙀")
//        }
        
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayUnallowed() //only display if Heart Rate
            return
        }
        
        //could also be
//        if (quantityType == HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate)) {
//            return
//        }
//        else {
//            displayUnallowed()
//        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -> Void in
            guard success == true else {
            //if success == false {
                self.displayUnallowed()
                return
            }
        }
        //watchConnectivity
        if(WCSession.isSupported()) {
            wcSesh = WCSession.defaultSession()
            wcSesh.delegate = self
            wcSesh.activateSession()
            
        }
        //reloadData()
    }
    
    func displayUnallowed() {
        label.setText("unallowed😾")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeToState toState: HKWorkoutSessionState, fromState: HKWorkoutSessionState, date: NSDate) {
        switch toState {
        case .Running:
            workoutDidStart(date)
        case .Ended:
            workoutDidEnd(date)
        default:
            print("Unexpected state \(toState)😤")
        }
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didFailWithError error: NSError) {
        // Do nothing for now
        NSLog("Workout error: \(error.userInfo)")
    }
    
    func workoutDidStart(date : NSDate) {
        guard let query = createHeartRateStreamingQuery(date) else {
            label.setText("can't start🤕")
            return
        }
        healthStore.executeQuery(query)
        
        //with if let?
//        if let query = createHeartRateStreamingQuery(date) {
//            healthStore.executeQuery(query)
//        } else {
//            label.setText("can't start🤕")
//        }
    }
    
    func workoutDidEnd(date : NSDate) {
        if let query = createHeartRateStreamingQuery(date) {
            healthStore.stopQuery(query)
            label.setText("---") //not running
        } else {
            label.setText("can't stop😓")
        }
    }

    @IBAction func startBtnTapped() {
        if (self.currMoving) {
            //finish curr workout
            self.currMoving = false
            self.startStopBtn.setTitle("Start💪🏽")
            if let workout = self.workoutSesh {
                healthStore.endWorkoutSession(workout)
            }
        } else {
            //start a new workout
            self.currMoving = true
            self.startStopBtn.setTitle("Stop✋🏼")
            beginWorkout()
        }

    }
    
    func beginWorkout() {
        self.workoutSesh = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSesh?.delegate = self
        healthStore.startWorkoutSession(self.workoutSesh!)
    }
    
    func createHeartRateStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
        }
        return heartRateQuery
    }
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return} //subclass of HKSample -> data like height, weight etc
        
        //where do I want code to run?
        //takes 1 param, FIFO data struct
        //Grand Central Dispatch = run complex tasks in background = concurrent code execution
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{return}
            self.hrVal = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            let lblTxt = String(self.hrVal!)
            self.label.setText(lblTxt)
            self.animateHeart()
        } //dispatch_async
        
        let appData = ["heart rate value": String(hrVal)]
        if let wcSesh = wcSesh where wcSesh.reachable {
            wcSesh.sendMessage(appData, replyHandler: { replyData in
                print(replyData)
            }, errorHandler: { error in
                print(error)
            })
        } else {
            //when phone !connected via Bluetooth
            print("phone !connected via Bluetooth")
        } //else
    }
    
    func animateHeart() {
        self.animateWithDuration(1.5) {
            self.heart.setWidth(20)
            self.heart.setHeight(50)
        }
        
        let when = dispatch_time(DISPATCH_TIME_NOW, Int64(0.5 * double_t(NSEC_PER_SEC)))
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
        dispatch_after(when, queue) {
            dispatch_async(dispatch_get_main_queue(), {
                self.animateWithDuration(0.5, animations: {
                    self.heart.setWidth(30)
                    self.heart.setHeight(60)
                    self.heart.setTintColor(UIColor(red: 255, green: 4, blue: 100, alpha: 0.3))
                    self.heart.setAlpha(0.3)
                })
            })
        }
    }
}
