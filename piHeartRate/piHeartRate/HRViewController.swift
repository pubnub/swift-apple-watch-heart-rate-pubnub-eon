//
//  HRViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/24/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity
//import PubNub
//subscribe from phone app -> see if can subscribe from Watch

class HRViewController: UIViewController, WCSessionDelegate {
    var userName: String = ""
    var dataPassedFromChannelViewController: String = ""
    
    @IBOutlet weak var userNameLabel: UILabel!
    var wcSesh : WCSession!
    var hrVal : Double = 0 //will change
    
    //let chanPickerOptions = ["PubNub", "Hamilton", "Hermione", "Olaf", "PiedPiper"]
    var wrSesh: WCSession!
    @IBOutlet weak var hrValLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        if(WCSession.isSupported()) {
            wrSesh = WCSession.defaultSession()
            wrSesh.delegate = self
            wrSesh.activateSession()
        }
        
        sendChannelData()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendChannelData() {
        //send channel to watch, not even publish -> emojis as label
        let channelData = ["channel": self.hrVal]
        if let wcSesh = self.wcSesh where wcSesh.reachable {
            wcSesh.sendMessage(channelData, replyHandler: { replyData in
                print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        } else {
            //when phone !connected via Bluetooth
            print("phone !connected via Bluetooth")
        } //else
        
        
        
        self.userName = self.dataPassedFromChannelViewController
        print("userName is" + self.userName)
        if self.userName == "PubNub" {
            self.userNameLabel.text = "/pubnub_emoji.jpg"
        }
        else if self.userName == "Hamilton" {
            self.userNameLabel.text = "🎼"
        }
        else if self.userName == "Hermione" {
            self.userNameLabel.text = "📚"
        }
        else if self.userName == "Olaf" {
            self.userNameLabel.text = "⛄️"
        } //else if
        else {
            self.userNameLabel.text = "" //empty
        }
        //update with PubNub here
        
    }
    
    //USE THIS FOR HR, set emojis but don't show #
    func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            if let hrVal = message["heart rate value"] as? Double { //String?
                self.hrValLabel.text = String(hrVal)
                if hrVal < 40 {
                    self.hrValLabel.text = "😤" //val from HR on watch
                    //bad
                }
                else if hrVal > 40 && hrVal < 60 {
                    //not bad
                    self.hrValLabel.text = "😁"
                }
                else if hrVal > 60 && hrVal < 80 {
                    self.hrValLabel.text = "🤗"
                }
                else if hrVal > 80 {
                    self.hrValLabel.text = "🙀"
                }
                else {
                    self.hrValLabel.text = "❤️"
                }
            }
        }
    }
}

