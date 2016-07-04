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

class TwitterViewController: UIViewController, WCSessionDelegate {
    
    @IBOutlet weak var pbfabricimg: UIImageView!
    @IBOutlet weak var doneButtonThatSegues: UIButton!
    @IBOutlet var maxNumToTweet: UIView!
    var twitterUName: String  = ""
    var twitterUNameToWatch: String = ""
    var dataPassedFromTwitterViewController: String!
    var loggedIn: Bool = false
    let screenSize: CGRect = UIScreen.mainScreen().bounds
    var twitterWCSesh : WCSession!
    override func viewDidLoad() {
      
        //pbfabricimg.frame = CGRectMake(0, 0, screenSize.width, 100)
        self.view.backgroundColor = UIColor(red: 207, green: 207, blue: 196, alpha:150)
        super.viewDidLoad()
        doneButtonThatSegues.frame.origin.y = 400
        doneButtonThatSegues.layer.masksToBounds = false
        doneButtonThatSegues.backgroundColor = UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1)
        doneButtonThatSegues.layer.cornerRadius = 9
        doneButtonThatSegues.titleLabel!.font = UIFont(name: "SanFranciscoRounded-Thin", size: 20)
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                //self.twitterIDLabel.text = "Welcome, " + unwrappedSession.userName
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
        
        //Twitter color
        decorateButton(logInButton, color: UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1))
        
        if(WCSession.isSupported()) {
            twitterWCSesh = WCSession.defaultSession()
            twitterWCSesh.delegate = self
            twitterWCSesh.activateSession()
        }
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
        
    
    // pos of login button
        let xPos:CGFloat? = screenSize.width/7
        let yPos:CGFloat? = screenSize.height/3
        
    logInButton.frame = CGRectMake(xPos!, yPos!, logInButton.frame.width, logInButton.frame.height)
    //logInButton.center = self.view.center
    self.view.addSubview(logInButton)
        //sendTwitterData()
    } //viewDidLoad
    
    func sendTwitterData() {
        let twitterHandleData = ["twitterHandle" : dataPassedFromTwitterViewController]
        if let twitterWCSesh = self.twitterWCSesh where twitterWCSesh.reachable {
            twitterWCSesh.sendMessage(twitterHandleData, replyHandler: { replyData in
                print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        } else {
            //when phone !connected via Bluetooth
            print("phone !connected via Bluetooth")
        } //else

    }
    
    //send to other viewcontroller
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) { //send between vc's
        if (segue.identifier == "sendTwitterName") {
            var svc = segue.destinationViewController as! HRViewController; //pass to HRViewController
            //var dataPassed = channelLabel.text
            svc.dataPassedFromTwitterViewController = self.twitterUName
        }

    }
    private func decorateButton(button: UIButton, color: UIColor) {
        // Draw the border around a button.
        button.layer.masksToBounds = false
        button.layer.borderColor = color.CGColor
        button.layer.borderWidth = 2
        button.layer.cornerRadius = 6
        button.titleLabel!.font = UIFont(name: "SanFranciscoRounded-Thin", size: 20)
    }
}
