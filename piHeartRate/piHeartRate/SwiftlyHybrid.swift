//
//  SwiftlyHybrid.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/29/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

//import Foundation
//import WebKit
//
//class SwiftlyHybrid: NSObject, WKScriptMessageHandler {
//    var appWebView:WKWebView?
//    
//    init(theController:HRViewController){
//        super.init()
//        let theConfiguration = WKWebViewConfiguration()
//        
//        //theConfiguration.userContentController.addScriptMessageHandler(self, name: "native")
//        
//        
//        let indexHTMLPath = NSBundle.mainBundle().pathForResource("eon", ofType: "html")
//        appWebView = WKWebView(frame: theController.view.frame, configuration: theConfiguration)
//        let url = NSURL(fileURLWithPath: indexHTMLPath!)
//        let request = NSURLRequest(URL: url)
//        appWebView!.loadRequest(request)
//        theController.view.addSubview(appWebView!)
//    }
//    //needs to be loaded before webpage is loaded
//    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
//        let sentData = message.body as! NSDictionary
//        
//        let command = sentData["cmd"] as! String
//        var response = Dictionary<String,AnyObject>()
//        if command == "increment"{
//            guard var count = sentData["count"] as? Int else{
//                return
//            }
//            count++
//            response["count"] = count
//        }
//        let callbackString = sentData["callbackFunc"] as? String
//        sendResponse(response, callback: callbackString)
//    }
//    func sendResponse(aResponse:Dictionary<String,AnyObject>, callback:String?){
//        guard let callbackString = callback else{
//            return
//        }
//        guard let generatedJSONData = try? NSJSONSerialization.dataWithJSONObject(aResponse, options: NSJSONWritingOptions(rawValue: 0)) else{
//            print("failed to generate JSON for \(aResponse)")
//            return
//        }
//        appWebView!.evaluateJavaScript("(\(callbackString)('\(NSString(data:generatedJSONData, encoding:NSUTF8StringEncoding)!)'))"){(JSReturnValue:AnyObject?, error:NSError?) in
//            if let errorDescription = error?.description{
//                print("returned value: \(errorDescription)")
//            }
//            else if JSReturnValue != nil{
//                print("returned value: \(JSReturnValue!)")
//            }
//            else{
//                print("no return from JS")
//            }
//        }
//    }
//
//
//}
