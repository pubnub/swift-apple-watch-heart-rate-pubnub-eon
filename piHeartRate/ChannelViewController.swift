//
//  ChannelViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/21/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import PubNub
import WatchConnectivity

class ChannelViewController: UIViewController, WCSessionDelegate {
    
    var wcPhoneSesh : WCSession!
    weak var channelTextField: UITextField!
    var chanName: String = ""
    
    @IBAction func channelButtonClicked(sender: AnyObject) {
        //channelTextField.text = chanName
        
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        //watchConnectivity
        if(WCSession.isSupported()) {
            wcPhoneSesh = WCSession.defaultSession()
            wcPhoneSesh.delegate = self
            wcPhoneSesh.activateSession()
        }
        let chanName = ["channel": String(channelTextField.text)]
        if let wcPhoneSesh = self.wcPhoneSesh where wcPhoneSesh.reachable {
            wcPhoneSesh.sendMessage(chanName, replyHandler: { replyData in
                print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        } else {
            //when phone !connected via Bluetooth
            print("phone !connected via Bluetooth")
        } //else


        // Do view setup here.
    }
    
    
    
    
    
}
