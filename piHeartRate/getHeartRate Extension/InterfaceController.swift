//
//  InterfaceController.swift
//  getHeartRate Extension
//
//  Created by Elisabeth Siegle on 6/24/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import Foundation //timer
import HealthKit
import WatchKit
import WatchConnectivity
import UIKit
import PubNub


// guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) could do StepCount
//step count matters at end of day. heart rate is more real-time, quick, short-period-of-time

class InterfaceController: WKInterfaceController, HKWorkoutSessionDelegate, WCSessionDelegate, WKExtensionDelegate, PNObjectEventListener {
    
    @IBOutlet var bpmLabel: WKInterfaceLabel!
    @IBOutlet var label: WKInterfaceLabel!
    
    @IBOutlet var heart: WKInterfaceLabel!
    
    @IBOutlet var startStopBtn: WKInterfaceButton!
    
    var arrayOfHR = [Double]()
    
    var client: PubNub?
    
    let healthStore = HKHealthStore()
    
    var publishTimer = NSTimer()
    
    var hrVal : Double = 0 //will change
    var channelSentFromPhone: String = ""
    var channelList = [String]()
    let watchAppDel = WKExtension.sharedExtension().delegate! as! ExtensionDelegate
    
    var wcSesh : WCSession!
    
    //bool = workout state
    var currMoving:Bool = false //not working out, starting at false
    
    // define the activity type and location
    var workoutSesh : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    override init() {
        let watchConfig = PNConfiguration(publishKey: "pub-c-1b5f6f38-34c4-45a8-81c7-7ef4c45fd608", subscribeKey: "sub-c-a3cf770a-2c3d-11e6-8b91-02ee2ddab7fe")
        
        watchAppDel.client = PubNub.clientWithConfiguration(watchConfig)
        
        super.init()
        watchAppDel.client?.addListener(self)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
    }
    
    override func willActivate() {
        super.willActivate()
        guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            label.setText("unavailable🙀")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayUnallowed() //only display if Heart Rate
            return
        }
        
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
        guard let query = makeHRStreamingQuery(date) else {
            label.setText("can't start🤕")
            return
        }
        healthStore.executeQuery(query)
    }
    
    func workoutDidEnd(date : NSDate) {
        if let query = makeHRStreamingQuery(date) {
            healthStore.stopQuery(query)
            label.setText("---") //not running
            self.currMoving = false
        } else {
            label.setText("can't stop😓")
        }
    }
    
    @IBAction func startBtnTapped() { //start at false
        if (self.currMoving) {
            //finish curr workout
            self.currMoving = false
            self.startStopBtn.setTitle("Start💪🏽")
            if let workout = self.workoutSesh {
                healthStore.endWorkoutSession(workout)
            }
            //send message to phone, not even publish
            let btnTapData = ["buttonTap": true]
            if let wcSesh = self.wcSesh where wcSesh.reachable {
                wcSesh.sendMessage(btnTapData, replyHandler: { replyData in
                    print(replyData)
                    }, errorHandler: { error in
                        print(error)
                })
            } else {
                //when phone !connected via Bluetooth
                print("phone !connected via Bluetooth")
            } //else
            //publishTimerFunc()
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
    
    func makeHRStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            if self.currMoving == true {
                self.updateHeartRate(sampleObjects)
            }
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            if self.currMoving == true {
                self.updateHeartRate(samples)
            }
        }
        self.arrayOfHR.append(self.hrVal)
        return heartRateQuery
    }
    
    func publishHeartRate() {
        //let hrValToPublish: [String : Double] = [self.uuidSentFromPhone: hrVal]
        let hrValToPublish = [ self.channelSentFromPhone: "\(self.hrVal)"] //self.channelSentFromPhone
        //let hrValToPublish = self.hrVal
        
        print("hrValToPublish: \(hrValToPublish)")
        watchAppDel.client?.publish(hrValToPublish, toChannel: "Olaf", withCompletion: { (status) -> Void in
            if !status.error {
                print("\(hrValToPublish) has been published")
                
            } //if
                
            else {
                print(status.debugDescription)
                print("\(self.hrVal) returns publish error hmm hmm ponder")
                print("\(hrValToPublish) has not been published err")
            } //else
        })
    }
    
    func publishTimerFunc() {
        publishTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(InterfaceController.publishHeartRate), userInfo: nil, repeats: true)
    }
    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!, didReceiveStatus status: PNStatus) {
        print(message)
        
        guard message.data.actualChannel != nil else {
            print(message.data)
            return
        }
        print("Received message: \(message.data.message) on channel " +
            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
            "\(message.data.timetoken)")
    }
    
    //get username from phone
    func session(wcSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        //let chanPickerOptions = ["PubNub", "Hamilton", "Hermione", "Olaf", "PiedPiper"
        if let checkingNameFromPhone = message["twitterHandle"] as? String {
            self.channelList.append(checkingNameFromPhone)
            self.channelSentFromPhone = checkingNameFromPhone
            
        } //let checking
    } //session WatchConnectivity
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return} //subclass of HKSample -> data like height, weight etc
        
        //where do I want code to run?
        //takes 1 param, FIFO data struct
        //Grand Central Dispatch = run complex tasks in background = concurrent code execution
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{return}
            self.hrVal = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            let lblTxt = String(self.hrVal)
            self.label.setText(lblTxt)
//            self.arrayOfHR.append(self.hrVal)
            repeat {
                self.publishTimerFunc()
            } while(self.currMoving == false)
            
            
            //send message to phone, not even publish
            let hrData = ["heart rate value array": self.arrayOfHR]
            if let wcSesh = self.wcSesh where wcSesh.reachable {
                wcSesh.sendMessage(hrData, replyHandler: { replyData in
                    print(replyData)
                    }, errorHandler: { error in
                        print(error)
                })
            } else {
                //when phone !connected via Bluetooth
                print("phone !connected via Bluetooth")
            } //else
        } //dispatch_async
    }
    
}