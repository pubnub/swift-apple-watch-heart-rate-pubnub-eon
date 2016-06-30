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


class HRViewController: UIViewController, WCSessionDelegate {
    var theHandler:SwiftlyHybrid?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theHandler = SwiftlyHybrid(theController: self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}








//class HRViewController: UIViewController, WCSessionDelegate, WKScriptMessageHandler {
//    let composer = TWTRComposer()
//    var dataPassedFromTwitterViewController: String = ""
//    @IBOutlet var containerView: UIView! = nil
//    
//    var hrVal : Double = 0 //will change
//    
//    var webView: WKWebView?
//    
//    var wrSesh: WCSession!
//    
//    override func loadView() {
//        super.loadView()
//        
//        let contentController = WKUserContentController();
//        let userScript = WKUserScript(
//            source: "pubStuff()",
//            injectionTime: WKUserScriptInjectionTime.AtDocumentEnd,
//            forMainFrameOnly: true
//        )
//        contentController.addUserScript(userScript)
//        contentController.addScriptMessageHandler(
//            self,
//            name: "callbackHandler"
//        )
//        
//        let config = WKWebViewConfiguration()
//        config.userContentController = contentController
//        
//        self.webView = WKWebView(
//            frame: self.containerView.bounds,
//            configuration: config
//        )
//        self.view = self.webView!
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
//        let myRequest = NSURLRequest(URL: localfilePath!);
//        self.webView!.loadRequest(myRequest);
//        //            view.addSubview(theWebView)
//
//        
//        if(WCSession.isSupported()) {
//            wrSesh = WCSession.defaultSession()
//            wrSesh.delegate = self
//            wrSesh.activateSession()
//        }
//        
//        composer.showFromViewController(self) { result in
//            if (result == TWTRComposerResult.Cancelled) {
//                print("Tweet composition cancelled")
//            }
//            else {
//                print("Sending tweet!")
//            }
//        }
//        
//        print("userName is" + dataPassedFromTwitterViewController)
//
//    }
//    
//    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
//        if(message.name == "callbackHandler") {
//            print("JavaScript is sending a message \(message.body)")
//        }
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//    }

    
    
    
    
    
    
    
    
    
//    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
//        print(navigationResponse.response.MIMEType)
//        decisionHandler(.Allow)
//    }
    //var theHandler: SwiftlyHybrid?
    
    //override func viewDidLoad() {
        //super.viewDidLoad()
        
        //theHandler = SwiftlyHybrid(theController: self)
        //webView = WKWebView (frame: self.view.frame, configuration: webConfig)
        //print("here")
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = false
        
//        let config = WKWebViewConfiguration()
//        config.preferences = preferences
        
//        webView = WKWebView(frame: view.bounds, configuration: config)
//        
//        if let theWebView = webView {
//            let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
//            let myRequest = NSURLRequest(URL: localfilePath!);
//            theWebView.loadRequest(myRequest);
//            theWebView.navigationDelegate = self
//            view.addSubview(theWebView)
//            print("here")
//        }
        
        // Delegate to handle navigation of web content
        //webView!.navigationDelegate = self
        
        //view.addSubview(webView!)
        
       
        //webView.allowsBackForwardNavigationGestures = true
//        if(WCSession.isSupported()) {
//            wrSesh = WCSession.defaultSession()
//            wrSesh.delegate = self
//            wrSesh.activateSession()
//        }
//        webView.evaluateJavaScript("document.getElementById('publishPls').innerText") { (result, error) in
//            if error != nil {
//                print(result)
//            }
//        }
        
//        composer.showFromViewController(self) { result in
//            if (result == TWTRComposerResult.Cancelled) {
//                print("Tweet composition cancelled")
//            }
//            else {
//                print("Sending tweet!")
//            }
//        }
//
//        print("userName is" + dataPassedFromTwitterViewController)
            // Do any additional setup after loading the view, typically from a nib.
        
    }
    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

    //func sendChannelData() {
        //send channel to watch, not even publish -> emojis as label
//        let channelData = ["channel": self.hrVal]
//        if let wcSesh = self.wcSesh where wcSesh.reachable {
//            wcSesh.sendMessage(channelData, replyHandler: { replyData in
//                print(replyData)
//                }, errorHandler: { error in
//                    print(error)
//            })
//        } else {
//            //when phone !connected via Bluetooth
//            print("phone !connected via Bluetooth")
//        } //else
        
    
//        if self.userName == "PubNub" {
//            self.userNameLabel.text = "/pubnub_emoji.jpg"
//        }
//        else if self.userName == "Hamilton" {
//            self.userNameLabel.text = "🎼"
//        }
//        else if self.userName == "Hermione" {
//            self.userNameLabel.text = "📚"
//        }
//        else if self.userName == "Olaf" {
//            self.userNameLabel.text = "⛄️"
//        } //else if
//        else {
//            self.userNameLabel.text = "" //empty
//        }
//        //update with PubNub here
        
    //}
    
    //USE THIS FOR HR, set emojis but don't show #
    func session(wrSesh: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        
        //Update the UI instantaneously (otherwise, takes a little while)
//        dispatch_async(dispatch_get_main_queue()) {
//            if let hrVal = message["heart rate value"] as? Double { //String?
//                self.hrValLabel.text = String(hrVal)
//                if hrVal < 40 {
//                    self.hrValLabel.text = "😤" //val from HR on watch
//                    //bad
//                }
//                else if hrVal > 40 && hrVal < 60 {
//                    //not bad
//                    self.hrValLabel.text = "😁"
//                }
//                else if hrVal > 60 && hrVal < 80 {
//                    self.hrValLabel.text = "🤗"
//                }
//                else if hrVal > 80 {
//                    self.hrValLabel.text = "🙀"
//                    self.composer.setText("My heart rate is " + String(self.hrVal))
//                }
//                else {
//                    self.hrValLabel.text = "❤️"
//                   
//                }
//            }
//        }
    }


