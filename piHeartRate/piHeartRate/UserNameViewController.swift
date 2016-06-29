//
//  ChannelViewController.swift
//  piHeartRate
//
//  Created by Elisabeth Siegle on 6/25/16.
//  Copyright © 2016 Lizzie Siegle. All rights reserved.
//

import UIKit
import WatchConnectivity

import TwitterKit

class UserNameViewController: UIViewController, UIPickerViewDataSource, WCSessionDelegate, UIPickerViewDelegate {
    
    var wrSesh: WCSession!
    var selPick:String = ""
    
    @IBOutlet weak var uNamePicker: UIPickerView!
    @IBOutlet weak var uNameLabel: UILabel!
    let uNamePickerOptions = ["PubNub", "Hamilton", "Hermione", "Olaf", "PiedPiper"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        uNamePicker.delegate = self
        uNamePicker.dataSource = self
        
        // Do any additional setup after loading the view, typically from a nib.
        if(WCSession.isSupported()) {
            wrSesh = WCSession.defaultSession()
            wrSesh.delegate = self
            wrSesh.activateSession()
        }
    }
    @IBAction func enterButtonClicked(sender: AnyObject) {
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if (segue.identifier == "btnSubmitSegue") {
            var svc = segue.destinationViewController as! HRViewController; //pass to HRViewController
            //var dataPassed = channelLabel.text
            svc.dataPassedFromChannelViewController = selPick
        }
        sendChannel()
    }

    func sendChannel() {
        //send message to phone, not even publish
        let sendingUName = ["UName": selPick]
        print("sending" + selPick)
        if let wrSesh = self.wrSesh where wrSesh.reachable {
            wrSesh.sendMessage(sendingUName, replyHandler: { replyData in
                print(replyData)
                }, errorHandler: { error in
                    print(error)
            })
        } else {
            //when phone !connected via Bluetooth
            print("phone !connected via Bluetooth")
        } //else
    } //sendChannel()
    
    //required PickerViewDataSource functions
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    } //numberOfComponentsInPickerView
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return uNamePickerOptions.count
    } //pickerView
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return uNamePickerOptions[row]
    } //pickerView
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        uNameLabel.text = uNamePickerOptions[row]
        selPick = uNamePickerOptions[row]
    } //pickerView text

    func pickerView(pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return CGFloat(view.frame.width/2)
    }
    
    func pickerView(pickerView: UIPickerView, heightForComponent component: Int) -> CGFloat {
        return CGFloat(300) //height
    }
    
    func pickerView(pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusingView view: UIView?) -> UIView {
        var pickLabel = view as! UILabel!
        if view == nil {  //if no label there yet
            pickLabel = UILabel()
            //color the label's background
            let pickOptionColor = CGFloat(row)/CGFloat(uNamePickerOptions.count)
            pickLabel.backgroundColor = UIColor(hue: pickOptionColor, saturation: 1.0, brightness: 0.7, alpha: 0.5)
        }
        let eachOptionName = uNamePickerOptions[row]
        let pickerOptionName = NSAttributedString(string: eachOptionName, attributes: [NSFontAttributeName:UIFont(name: "Georgia", size: 24.0)!,NSForegroundColorAttributeName:UIColor.redColor()])
        pickLabel!.attributedText = pickerOptionName
        pickLabel!.textAlignment = .Center
        
        uNameLabel.text = uNamePickerOptions[row]
        return pickLabel
        
    }

}
