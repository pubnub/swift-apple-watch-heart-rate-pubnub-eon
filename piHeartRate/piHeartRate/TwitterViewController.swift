//
//  TwitterViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/29/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import TwitterKit

class TwitterViewController: UIViewController {
    
    
    @IBOutlet var twitterIDLabel: UILabel!
    @IBOutlet var maxNumToTweet: UIView!
    var twitterUName: String = ""
    var dataPassedFromTwitterViewController: String!
    
    override func viewDidLoad() {
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
                self.twitterIDLabel.text = unwrappedSession.userName
                self.twitterUName = unwrappedSession.userName
                let alert = UIAlertController(title: "Logged In",
                    message: "User \(unwrappedSession.userName) has logged in",
                    preferredStyle: UIAlertControllerStyle.Alert
                )
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            } else {
                NSLog("Login error: %@", error!.localizedDescription);
            }
            
        }
        if let sesh = Twitter.sharedInstance().sessionStore.session() {
            let client = TWTRAPIClient()
            client.loadUserWithID(sesh.userID) { (user, error) -> Void in
                if let user = user {
                    self.twitterIDLabel.text = user.screenName
                    print("@\(user.screenName)")
                    self.twitterUName = user.screenName
                }
            }
        }
        
    
    // TODO: Change where the log in button is positioned in your view
        let xPos:CGFloat? = 48.0 //use your X position here
        let yPos:CGFloat? = 75.0 //use your Y position here
        
    logInButton.frame = CGRectMake(xPos!, yPos!, logInButton.frame.width, logInButton.frame.height)
    //logInButton.center = self.view.center
    self.view.addSubview(logInButton)
    } //viewDidLoad
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "sendTwitterName") {
            var svc = segue.destinationViewController as! HRViewController; //pass to HRViewController
            //var dataPassed = channelLabel.text
            svc.dataPassedFromTwitterViewController = self.twitterUName
        }
    }
    
}
