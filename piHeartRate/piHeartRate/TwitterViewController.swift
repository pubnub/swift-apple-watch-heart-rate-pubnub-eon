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
    
    @IBOutlet weak var twitterTextField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet var maxNumToTweet: UIView!
    override func viewDidLoad() {
        let logInButton = TWTRLogInButton { (session, error) in
            if let unwrappedSession = session {
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
    
    // TODO: Change where the log in button is positioned in your view
        let xPos:CGFloat? = 48.0 //use your X position here
        let yPos:CGFloat? = 75.0 //use your Y position here
        
    logInButton.frame = CGRectMake(xPos!, yPos!, logInButton.frame.width, logInButton.frame.height)
    //logInButton.center = self.view.center
    self.view.addSubview(logInButton)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(TwitterViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool
        
    {
        let numberOnly = NSCharacterSet.init(charactersInString: "0123456789")
        
        let stringFromTextField = NSCharacterSet.init(charactersInString: string)
        
        let strValid = numberOnly.isSupersetOfSet(stringFromTextField)
        
        return strValid
    }
    
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }

    @IBAction func enterButtonClicked(sender: AnyObject) {
    }
}
