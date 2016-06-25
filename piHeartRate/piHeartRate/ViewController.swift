//
//  ViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/24/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity
//import PubNub
//subscribe from phone app -> see if can subscribe from Watch

class ViewController: UIViewController, WCSessionDelegate {
    var channelName: String = ""
    
    @IBOutlet weak var channelLabel: UILabel!
    
    //let chanPickerOptions = ["PubNub", "Hamilton", "Hermione", "Olaf", "PiedPiper"]
    
    @IBOutlet weak var hrValLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        channelName = dataPassedFromChannelViewController
        if channelName == "PubNub" {
            channelLabel = "/pubnub_emoji.jpg"
        }
        else if channelName == "Hamilton" {
            channelLabel = "🎼"
        }
        else if channelName == "Hermione" {
            channelLabel = "📚"
        }
        else if channelName == "Olaf" {
            channelLabel = "⛄️"
        } //else if
        else {
            channelLabel = "" //empty
        }
        // Do any additional setup after loading the view, typically from a nib.
        
        sendChannelData()
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

    }
    
    //USE THIS FOR HR, set emojis but don't show #
    func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Update the UI instantaneously (otherwise, takes a little while)
        dispatch_async(dispatch_get_main_queue()) {
            if let hrVal = message["heart rate value"] as? Double { //String?
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
                //update with PubNub here
            }
        }
    }
}

