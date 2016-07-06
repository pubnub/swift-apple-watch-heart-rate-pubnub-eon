//
//  TwitterViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/29/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import TwitterKit
import WatchConnectivity
import Foundation //animate with duration

class TwitterViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var plainpubnubimg: UIView!
    @IBOutlet weak var heartLabel: UILabel!
    @IBOutlet weak var pbfabricimg: UIImageView!
    
    @IBOutlet weak var doneButtonThatSegues: UIButton!
    @IBOutlet var maxNumToTweet: UIView!
    var twitterUName: String  = ""
    var twitterUNameToWatch: String = ""
    var dataPassedFromTwitterViewController: String!
    var loggedIn: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var twitterWCSesh : WCSession!
    var twitterColor = UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1)
    
    override func viewDidLoad() {
        self.view.backgroundColor = UIColor(red: 207, green: 207, blue: 196, alpha:150)
        super.viewDidLoad()
        animateHeart()
        //when logged in, then segues to next VC and passes Twitter username to Watch
        doneButtonThatSegues.frame.origin.y = 400
        doneButtonThatSegues.layer.masksToBounds = false
        doneButtonThatSegues.backgroundColor = twitterColor
        doneButtonThatSegues.layer.cornerRadius = 9
        doneButtonThatSegues.layer.borderColor = twitterColor.CGColor
        
        //Twitter login button
               let logInButton = TWTRLogInButton { (session, error) in
                    if let unwrappedSession = session {
                self.twitterUName = unwrappedSession.userName
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
                self.loggedIn = true
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
        }
        
        //pbfabricimg size of image
        pbfabricimg.frame = CGRectMake(200, 200, 200, 50)
        
        //Twitter color, etc
        decorateButton(logInButton, color: twitterColor)
        decorateButton(doneButtonThatSegues, color: twitterColor)

        //y position of done button
        let yPos:CGFloat? = screenSize.height/3.5
        doneButtonThatSegues.frame = CGRectMake(0, yPos! - 240, screenSize.width/4, 24)
        logInButton.frame = CGRectMake(0, yPos!, screenSize.width, logInButton.frame.height)
        //add loginbutton to subview
        self.view.addSubview(logInButton)

        
        //watchconnectivity session
        if(WCSession.isSupported()) {
            twitterWCSesh = WCSession.defaultSession()
            twitterWCSesh.delegate = self
            twitterWCSesh.activateSession()
        }
        //get + set username
        if let sesh = Twitter.sharedInstance().sessionStore.session() {
            let client = TWTRAPIClient()
            client.loadUserWithID(sesh.userID) { (user, error) -> Void in
                if let user = user {
                    //self.twitterIDLabel.text = user.screenName
                    print("@\(user.screenName)")
                    self.twitterUName = user.screenName
                    self.twitterUNameToWatch = user.screenName
                    print("twitterUNameToWatch: " + self.twitterUNameToWatch)
                }
            }
        }
        //sendTwitterData()
    } //viewDidLoad
    
    //if you want to send twitter login between VCs -> !needed to post to Twitter from other VC
//    func sendTwitterData() {
//        let twitterHandleData = ["twitterHandle" : dataPassedFromTwitterViewController]
//        if let twitterWCSesh = self.twitterWCSesh where twitterWCSesh.reachable {
//            twitterWCSesh.sendMessage(twitterHandleData, replyHandler: { replyData in
//                print(replyData)
//                }, errorHandler: { error in
//                    print(error)
//            })
//        } else {
//            //when phone !connected via Bluetooth
//            print("phone !connected via Bluetooth")
//        } //else
//
//    }
    func animateHeart() {
        UIView.animateWithDuration(2.0, delay:0, options: [.Repeat, .Autoreverse], animations: {
            
            self.heartLabel.frame = CGRect(x: 120, y: 190, width: 100, height: 100)
            
            }, completion: nil)
    }
    
    //send to other viewcontroller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) { //send between vc's
        if (segue.identifier == "sendTwitterName") {
            let svc = segue.destinationViewController as! HRViewController; //pass to HRViewController
            //var dataPassed = channelLabel.text
            svc.dataPassedFromTwitterViewController = self.twitterUName
        }

    }
    private func decorateButton(button: UIButton, color: UIColor) {
        // Draw the border around a button.
        button.layer.masksToBounds = false
        button.layer.borderWidth = 2
        button.layer.borderColor = color.CGColor
        button.layer.cornerRadius = 6
        button.titleLabel!.font = UIFont(name: "SanFranciscoRounded-Thin", size: 20)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    }
}
