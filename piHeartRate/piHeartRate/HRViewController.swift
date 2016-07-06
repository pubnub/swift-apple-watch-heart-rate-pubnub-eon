//
//  HRViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/24/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity
import TwitterKit
import PubNub
import WebKit
//subscribe from phone app -> see if can subscribe from Watch

class HRViewController: UIViewController, WCSessionDelegate, UITextViewDelegate, WKNavigationDelegate { //,TWTRComposerViewController {
    var webView: WKWebView
    
    var timeToTweet : Bool = false
    var maxFromArr: Double = 0 //will change
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progressView: UIProgressView!
    let composer = TWTRComposer()
    var dataPassedFromTwitterViewController: String!
    
    var hrVal : Double = 0 //will change
    var wcSesh: WCSession!
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
        
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(red: 207, green: 207, blue: 196, alpha:150)
        self.navigationController?.toolbarHidden = false
       
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
       
        self.navigationController?.navigationBarHidden = false
        //UIToolbar.appearance().barTintColor = UIColor.grayColor();
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        //programmatically set button omg
        let tweetButton = UIButton(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width/2.8, height: self.view.frame.size.height/13))
        tweetButton.center.x = self.view.center.x
        tweetButton.center.y = self.view.center.y + 125
        tweetButton.backgroundColor = UIColor(red: 0.333, green: 0.675, blue: 0.933, alpha: 1)
        tweetButton.setTitle("Tweet!", forState: .Normal)
        tweetButton.addTarget(self, action: #selector(sendTweet), forControlEvents: .TouchUpInside)
        //font
        tweetButton.titleLabel!.font = UIFont(name: "SanFranciscoRounded-Thin", size: 20)
        
        //rounded, not square
        tweetButton.layer.cornerRadius = 5;
        tweetButton.layer.masksToBounds = true

        self.view.addSubview(tweetButton)
        
        //webview
        view.insertSubview(webView, belowSubview: progressView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        webView.addSubview(tweetButton)
        
        let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
        let request = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(request)
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        //watchConnectivitySession
        if(WCSession.isSupported()) {
            wcSesh = WCSession.defaultSession()
            wcSesh.delegate = self
            wcSesh.activateSession()
         }
        //send Twitter handle from phone to Watch to publish to PubNub
        let twitterHandleData = ["twitterHandle" : dataPassedFromTwitterViewController]
        if let twitterWCSesh = self.wcSesh where twitterWCSesh.reachable {
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
    
    //publish Tweet on button tap. Button only works once, then have to go back to 1st viewController, then forward
    @IBAction func sendTweetTapped(sender: AnyObject) {
        self.composer.setText("working out and tracking my heart rate. #pubnub #fabric")
        
        self.composer.showFromViewController(self) { result in
            if result == TWTRComposerResult.Cancelled {
                print("Tweet composition cancelled")
            }
            else if result == TWTRComposerResult.Done {
                print("Tweet result done")
            }
            else {
                print("Sending tweet!")
            }
        }

    }
   func sendTweet(sender: UIButton) {
    //TWTRTweetView.appearance().theme = .Dark
        self.composer.setText("working out and tracking my heart rate. #pubnub #fabric")
    
                    self.composer.showFromViewController(self) { result in
                        if result == TWTRComposerResult.Cancelled {
                            print("Tweet composition cancelled")
                        }
                        else if result == TWTRComposerResult.Done {
                            print("Tweet result done")
                        }
                        else {
                            print("Sending tweet!")
                        }
                    }
    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func tweetButtonStoryboardAction(sender: AnyObject) {
        self.composer.setText("working out and tracking my heart rate. #pubnub #fabric")
        
        self.composer.showFromViewController(self) { result in
            if result == TWTRComposerResult.Cancelled {
                print("Tweet composition cancelled")
            }
            else if result == TWTRComposerResult.Done {
                print("Tweet result done")
            }
            else {
                print("Sending tweet!")
            }
        }

    }
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
        barView.backgroundColor = UIColor.redColor()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        webView.loadRequest(NSURLRequest(URL:NSURL(string: urlField.text!)!))
        
        return false
    }
    
    
    @IBAction func back(sender: UIBarButtonItem) {
        webView.goBack()
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        webView.goForward()
    }
    
    @IBAction func reload(sender: UIBarButtonItem) {
        let request = NSURLRequest(URL:webView.URL!)
        webView.loadRequest(request)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if (keyPath == "loading") {
            backButton.enabled = webView.canGoBack
            forwardButton.enabled = webView.canGoForward
        }
        if (keyPath == "estimatedProgress") {
            progressView.hidden = webView.estimatedProgress == 1
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func webView(webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }


    //don't show HR
    func session(wcSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        if let boolFromWatch = message["buttonTap"] as? Bool { //String?
            timeToTweet = boolFromWatch
        }
    }
}





