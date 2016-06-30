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
    
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    @IBOutlet weak var progressView: UIProgressView!
    
        let composer = TWTRComposer()
        var dataPassedFromTwitterViewController: String = ""
    
        var hrVal : Double = 0 //will change
        var wrSesh: WCSession!
    required init(coder aDecoder: NSCoder) {
        self.webView = WKWebView(frame: CGRectZero)
        super.init(coder: aDecoder)!
        
        self.webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        barView.frame = CGRect(x:0, y: 0, width: view.frame.width, height: 30)
        
        view.insertSubview(webView, belowSubview: progressView)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        let height = NSLayoutConstraint(item: webView, attribute: .Height, relatedBy: .Equal, toItem: view, attribute: .Height, multiplier: 1, constant: -44)
        let width = NSLayoutConstraint(item: webView, attribute: .Width, relatedBy: .Equal, toItem: view, attribute: .Width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])
        
        webView.addObserver(self, forKeyPath: "loading", options: .New, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .New, context: nil)
        
        //let url = NSURL(string:"http://www.appcoda.com")
        //let request = NSURLRequest(URL:url!)
        let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
        let request = NSURLRequest(URL: localfilePath!);
        webView.loadRequest(request)
        
        backButton.enabled = false
        forwardButton.enabled = false
        
        if(WCSession.isSupported()) {
            wrSesh = WCSession.defaultSession()
            wrSesh.delegate = self
            wrSesh.activateSession()
         }
            
         composer.showFromViewController(self) { result in
            if (result == TWTRComposerResult.Cancelled) {
                print("Tweet composition cancelled")
            }
            else {
                print("Sending tweet!")
            }
          }
                    
            print("userName is" + dataPassedFromTwitterViewController)
        
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
    
    func webView(webView: WKWebView!, didFailProvisionalNavigation navigation: WKNavigation!, withError error: NSError!) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView!, didFinishNavigation navigation: WKNavigation!) {
        progressView.setProgress(0.0, animated: false)
    }

}
//class HRViewController: UIViewController, WCSessionDelegate, WKNavigationDelegate {
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
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        let noLayoutFormatOptions = NSLayoutFormatOptions(rawValue: 0)
//        
//        let webView = WKWebView(frame: CGRectZero, configuration: WKWebViewConfiguration())
//        webView.translatesAutoresizingMaskIntoConstraints = false //(false)
//        webView.navigationDelegate = self
//        view.addSubview(webView)
//        
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[webView]|", options: noLayoutFormatOptions, metrics: nil, views: ["webView": webView]))
//        
//        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: noLayoutFormatOptions, metrics: nil, views: ["webView": webView]))
//        
//        let localfilePath = NSBundle.mainBundle().URLForResource("eon", withExtension: "html");
//        let request = NSURLRequest(URL: localfilePath!);
//        self.webView!.loadRequest(request);
//        webView.loadRequest(request)
//    }
//    
//    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
//        print("Finished navigating to url \(webView)")
//    }
//    
//}

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
//    
//    
//    func webView(webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
//        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
//    }
//    
//    func webView(webView: WKWebView, decidePolicyForNavigationResponse navigationResponse: WKNavigationResponse, decisionHandler: (WKNavigationResponsePolicy) -> Void) {
//        print(navigationResponse.response.MIMEType)
//        decisionHandler(.Allow)
//    }
//    var theHandler: SwiftlyHybrid?
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        theHandler = SwiftlyHybrid(theController: self)
//        webView = WKWebView (frame: self.view.frame, configuration: webConfig)
//        print("here")
//        let preferences = WKPreferences()
//        preferences.javaScriptEnabled = false
//        
//        let config = WKWebViewConfiguration()
//        config.preferences = preferences
//        
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
//        
//        //Delegate to handle navigation of web content
//        webView!.navigationDelegate = self
//        
//        view.addSubview(webView!)
//        
//       
//        webView.allowsBackForwardNavigationGestures = true
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
//             Do any additional setup after loading the view, typically from a nib.
//        
//
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }

//    func sendChannelData() {
//        send channel to watch, not even publish -> emojis as label
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
//        
//    
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
//        
//    }
    
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


