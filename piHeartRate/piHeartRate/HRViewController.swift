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

class HRViewController: UIViewController, WCSessionDelegate, UITextViewDelegate, WKNavigationDelegate {
    var webView: WKWebView
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    var maxHeartRate: Double = 0 //will change
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    var timeToTweet : Bool = false
    
    @IBOutlet weak var progressView: UIProgressView!
    let composer = TWTRComposer()
    var dataPassedFromTwitterViewController: String = ""
    
    var hrVal : Double = 0 //will change
    var wcSesh: WCSession!
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
        
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//            composer.setText("working out, and my heart rate got to be: " + String(maxHeartRate))
//            
//            composer.showFromViewController(self) { result in
//                if (result == TWTRComposerResult.Cancelled) {
//                    print("Tweet composition cancelled")
//                }
//                else {
//                    print("Sending tweet!")
//                }
//            }
        
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
        let request = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(request)
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        if(WCSession.isSupported()) {
            wcSesh = WCSession.defaultSession()
            wcSesh.delegate = self
            wcSesh.activateSession()
         }
//            print("userName is" + dataPassedFromTwitterViewController)
//        let userNameData = ["twitterName": self.dataPassedFromTwitterViewController]
//        if let wcSesh = self.wcSesh where wcSesh.reachable {
//            wcSesh.sendMessage(userNameData, replyHandler: { replyData in
//                print(replyData)
//                }, errorHandler: { error in
//                    print(error)
//            })
//        } else {
//            //when phone !connected via Bluetooth
//            print("phone !connected via Bluetooth")
//        } //else
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        barView.frame = CGRect(x:0, y: 0, width: size.width, height: 30)
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

}

    
    //USE THIS FOR HR, set emojis but don't show #
func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
    //var arrayOfHRVal = [Double]() // willChange
//    var maxHeartRate: Double
//    var timeToTweet: Bool
//    if let hrArrayFromWatch = message["heart rate value array"] as? [String] { //String?
////        arrayOfHRVal = hrArrayFromWatch
//        let doubleArrVal = hrArrayFromWatch.map { Double($0)! }
//        maxHeartRate = doubleArrVal.maxElement()!
//    }
//    if let boolFromWatch = message["buttonTap"] as? Bool { //String?
//        //        arrayOfHRVal = hrArrayFromWatch
//        timeToTweet = boolFromWatch
//    }
//
//    
}



