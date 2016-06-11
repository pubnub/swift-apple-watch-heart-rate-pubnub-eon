//
//  ExtensionDelegate.swift
//  getHeartRate Extension
//
//  Created by Elisabeth Siegle on 6/7/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchKit
import PubNub
import WatchConnectivity //yolo

class ExtensionDelegate: NSObject, WKExtensionDelegate, PNObjectEventListener {
    var client: PubNub?
//    var client : PubNub
//    var config : PNConfiguration
    var channel = "iWorkout"
//    
//    override init() {
//        config = PNConfiguration(publishKey: "pub-c-1b5f6f38-34c4-45a8-81c7-7ef4c45fd608", subscribeKey: "sub-c-a3cf770a-2c3d-11e6-8b91-02ee2ddab7fe")
//        client = PubNub.clientWithConfiguration(config)
//        client.subscribeToChannels([channel], withPresence: false)
//        super.init()
//        client.addListener(self)
//        
//    }
    
    //handle new msg from 1 of channels client is subscribed to
//    func client(client: PubNub!, didReceiveMessage message: PNMessageResult!) {
//        print(message)
        //        if message.data.actualChannel != nil {
        //            //msg received on channel group, stored in message.data.subscribedChannel
        //        } //if
        //        else {
        //            //msg received on channel, stored in same place
        //        }
        
//        guard message.data.actualChannel != nil else {
//            print(message.data)
//            return
//        }
//        print("Received message: \(message.data.message) on channel " +
//            "\((message.data.actualChannel ?? message.data.subscribedChannel)!) at " +
//            "\(message.data.timetoken)")
//    }

    func applicationDidFinishLaunching() {
        // Perform any final initialization of your application.
    }

    func applicationDidBecomeActive() {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillResignActive() {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        client?.unsubscribeFromAll()
        client?.unsubscribeFromChannels([channel], withPresence: true)
        // Use this method to pause ongoing tasks, disable timers, etc.
    }

}
