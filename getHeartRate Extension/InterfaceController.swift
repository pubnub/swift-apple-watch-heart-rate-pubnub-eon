


//
//  InterfaceController.swift
//  getHeartRate Extension
//
//  Created by Elisabeth Siegle on 6/7/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import Foundation //timer
import HealthKit
import WatchKit
import WatchConnectivity
import UIKit
import PubNub

class InterfaceController: WKInterfaceController, WKExtensionDelegate, PNObjectEventListener { //, HKWorkoutSessionDelegate {
    
    @IBOutlet var label: WKInterfaceLabel!
    
    @IBOutlet var heart: WKInterfaceImage!
    
    @IBOutlet var startStopBtn: WKInterfaceButton!
    
    var client: PubNub?
    
    var randomName : String = ""
    
    let healthStore = HKHealthStore()
    
    var hrVal : Double = 0 //will change
    var channelSentFromPhone: String = ""
    var channelList = [String]()
    let watchAppDel = WKExtension.sharedExtension().delegate as! ExtensionDelegate
    
    var channel = ""
    
    var wcSesh : WCSession!
    
    var currMoving = false //not working out
    
    // define the activity type and location
    var workoutSesh : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
    
    override init() {
        let watchConfig = PNConfiguration(publishKey: "pub-c-1b5f6f38-34c4-45a8-81c7-7ef4c45fd608", subscribeKey: "sub-c-a3cf770a-2c3d-11e6-8b91-02ee2ddab7fe")
        //client = PubNub.client(with: watchConfig)
        watchAppDel.client? = PubNub.clientWithConfiguration(watchConfig)
        
        super.init()
        //watchAppDel.client?.add(self)
        //watchAppDel.client?.add(self)
        //watchAppDel.client?.joinChannel(channel)
        watchAppDel.client?.addListener(self)
        
        randomName = genRandom()
    }
    
    //    override func awake(withContext context: AnyObject?) {
    //        super.awake(withContext: context)
    //    }
    
    override func willActivate() {
        super.willActivate()
        guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            label.setText("unavailable🙀")
            return
        }
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { //HKQuantityTypeIdentifier.heartRate) else {
            displayUnallowed() //only display if Heart Rate
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes, completion: { (success, error) -> Void in
            //(toShare: nil, read: dataTypes, completion: { (success, error) -> Void in
            //(toShare: nil, read: dataTypes) { (success, error) -> Void in
            guard success == true else {
                //if success == false {
                self.displayUnallowed()
                return
            }
        })
        //reloadData()
    }
    
    func displayUnallowed() {
        label.setText("unallowed😾")
    }
    
    func workoutSession(workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: NSDate) {
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
        NSLog("Workout error: \(error.userInfo)"
        )
    }
    
    func workoutDidStart(date : NSDate) {
        guard let query = makeHRStreamingQuery(date) else {
            label.setText("can't start🤕")
            return
        }
        //healthStore.execute(query)
        healthStore.executeQuery(query)
    }
    
    func workoutDidEnd(date : NSDate) {
        if let query = makeHRStreamingQuery(date) {
            //healthStore.stop(query)
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
                //healthStore.end(workout)
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
        self.workoutSesh = HKWorkoutSession(activityType: .Hiking, locationType: HKWorkoutSessionLocationType.Indoor)
        //self.workoutSesh?.delegate = self
        //healthStore.start(self.workoutSesh!)
        healthStore.startWorkoutSession(self.workoutSesh!)
    }
    
    func makeHRStreamingQuery(workoutStartDate: NSDate) -> HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -> Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)//(sampleObjects) //HKQuantityTypeIdentifierHeartRate.rawValue ???
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -> Void in
            self.anchor = newAnchor!
            //self.updateHeartRate(samples)
            self.updateHeartRate(samples) //userInfo: sampleObjects returns err but idk man
            //}
        }
        return heartRateQuery
    }
    
    func publishHeartRate() {
        //        let hrValToPublish: [String : Double] = [self.uuidSentFromPhone: hrVal]
        let hrValToPublish = [randomName: "\(self.hrVal)"]
        print("hrValToPublish: \(hrValToPublish)")
        watchAppDel.client?.publish(hrValToPublish, toChannel: "yee", withCompletion: { (status) -> Void in
            if !status.error { //isError
                print("\(self.hrVal) has been published")
                print("\(hrValToPublish) has been published")
                
            } //if
                
            else {
                print(status.debugDescription)
                print("\(self.hrVal) returns publish error hmm hmm ponder")
                print("\(hrValToPublish) has not been published err")
            } //else
        })
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
    
    //get channel name from phone
    func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        //DispatchQueue.main.async {
        if let chanFromPhone = message["channel"] as? String {
            self.channelList.append(chanFromPhone)
            self.channelSentFromPhone = chanFromPhone
            //PubNub
            //self.hrValLabel.text = hrVal //val from HR on watch
            //update with PubNub here
        }
        //}
    }
    
    func genRandom() -> String {
        var possNames = ["Tomomi", "Bhavana", "Stephen", "EmmaRose", "Keith", "Sleepy", "Olaf", "R2D2", "Wendy", "PubNub", "PingPong", "chess"]
        let randIndex = Int(arc4random_uniform(UInt32(possNames.count)))
        return possNames[randIndex]
        
    }
    
    
    
    func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return} //subclass of HKSample -> data like height, weight etc
        
        //where do I want code to run?
        //takes 1 param, FIFO data struct
        //Grand Central Dispatch = run complex tasks in background = concurrent code execution
        //DispatchQueue.main.async {
        guard let sample = heartRateSamples.first else{return}
        self.hrVal = sample.quantity.doubleValueForUnit(self.heartRateUnit)//sample.quantity.doubleValue(for: self.heartRateUnit)
        let lblTxt = String(self.hrVal)
        self.label.setText(lblTxt)
        self.publishHeartRate()
        //} //dispatch_async
        
        let appData = ["heart rate value": String(self.hrVal)]
        //if let wcSesh = self.wcSesh where wcSesh. { //wcSesh.isReachable {
        wcSesh.sendMessage(appData, replyHandler: { replyData in
            print(replyData)
            }, errorHandler: { error in
                print(error)
        })
        //} else {
        //when phone !connected via Bluetooth
        //print("phone !connected via Bluetooth")
        //} //else
    }
}



