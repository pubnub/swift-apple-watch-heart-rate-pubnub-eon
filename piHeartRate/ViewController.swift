//
//  ViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/7/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity // idkimportant
//subscribe from phone app -> see if can subscribe from Watch

class ViewController: UIViewController, WCSessionDelegate {
    
    var someData = [String]()
    var wrSesh: WCSession!

    @IBOutlet weak var hrValLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        if(WCSession.isSupported()) {
            wrSesh = WCSession.defaultSession()
            wrSesh.delegate = self
            wrSesh.activateSession()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Use this to update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            if let hrVal = message["heart rate value"] as? String {
                self.someData.append(hrVal)
                //PubNub
                self.hrValLabel.text = hrVal //val from HR on watch
                //update with PubNub here
            }
        }
    }

}

