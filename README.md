This demo uses the Watch’s HealthKit to access the user’s heart rate data, publish it to <a href="https://www.pubnub.com/" target="_blank">PubNub</a>, and then uses a <a href="https://www.raspberrypi.org/" target="_blank">Raspberry Pi</a> as a medium through which LEDs light up based on heart rate. The iPhone app displays a realtime <a href="/developers/eon/">EON</a> chart, and uses Twitter’s <a href="https://docs.fabric.io/apple/fabric/overview.html" trget="_blank">fabric</a> to use their <a href="https://dev.twitter.com/overview/documentation" target="_blank">API </a>as a way to login, use that Twitter handle as a unique ID, and let the user tweet at the end of a workout session (which must be instantiated in order to access heart rate data.)

![apple-watch-heart-rate-monitor-raspberry-pi-eon](https://cloud.githubusercontent.com/assets/8932430/16638808/14ce8ce8-439f-11e6-9bd4-999ae4afb0d6.JPG)


<h3>Installing PubNub with CocoaPods</h3>
If you have never installed a Pod before, a really good tutorial on how to get started can be found on the CocoaPods official <a href="https://guides.cocoapods.org/using/using-cocoapods.html" target="_blank">website</a>. Once a podfile is setup, it should contain something like this:
<pre class="EnlighterJSRAW" data-enlighter-language="raw">source 'https://github.com/CocoaPods/Specs.git'
use_frameworks!

target 'yourProject' do
    platform :ios, '8.0'
    pod 'PubNub', '~&gt;4.0'
    pod 'Crashlytics'
end

target 'yourWatchProject' do
    platform :watchos, '2.2'
    pod 'PubNub', '~&gt; 4.0'
end

target 'yourWatchProject Extension' do
    platform :watchos, '2.2'
    pod 'PubNub', '~&gt;4.0'
end
</pre>

<h3>Setting up Fabric</h3>
To set up Fabric for your app, follow the directions <a href="https://docs.fabric.io/apple/fabric/overview.html" target="_blank">here</a>. You can use Pods or download the Fabric OS X app.

![compose-tweet-fabric-swift-ios](https://cloud.githubusercontent.com/assets/8932430/16638787/097d982a-439f-11e6-8806-00512ce99894.gif)

<h2>Phone App</h2>

<h3>AppDelegate</h3>
In your AppDelegate file, besides importing the Fabric, PubNub, and TwitterKit libraries, import:

<em>HealthKit, </em>to give you access to methods you need to access and work with the heart rate data; <em>WatchConnectivity</em>, so your phone app can receive data from the watch.

The <em>AppDelegate</em> class should inherit from <em>UIResponder, UIApplicationDelegate, PNObjectEventListener, </em>and <em>WCSessionDelegate.</em>

WCSession contains a property observer that, when triggered, tries to unwrap the session. If successful in unwrapping it, it sets the session’s delegate, before activating it.
<pre class="EnlighterJSRAW" data-enlighter-language="raw"> var session: WCSession? {
    didSet {
        if let session = session {
            session.delegate = self
            session.activateSession()
        }
    }
}
</pre>

<h3> Main.storyboard and TwitterViewController</h3>

![animatedheart](https://cloud.githubusercontent.com/assets/8932430/16638795/0e8d5990-439f-11e6-9099-c28aa0b7d5ca.gif)

To display a Twitter login button, paste this code into <em>viewDidLoad():</em>
<pre class="EnlighterJSRAW" data-enlighter-language="raw">let logInButton = TWTRLogInButton { (session, error) in
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
self.view.addSubview(logInButton)
</pre>
<h3>HRViewController</h3>
Create a second <em>ViewController.</em> This <em>ViewController</em> is where the <a href="/developers/eon/">EON</a> graph will be displayed, so you will need to set up a <em>WKWebView. </em>There is so much code for this, just visit the GitHub <a href="https://github.com/pubnub/swift-apple-watch-heart-rate/blob/master/piHeartRate/piHeartRate/TwitterViewController.swift" target="_blank">repo</a>, but to fully understand the code, checkout this <a href="http://nshipster.com/wkwebkit/" target="_blank">NSHipster documentation</a> or this <a href="http://www.appcoda.com/webkit-framework-intro/" target="_blank">AppCoda tutorial</a>. After you have you WKWebView set up here, don’t forget to go into your phone app’s <em>plist</em>, go down to <em>App Transport Security Settings,</em> and set <em>Allow Arbitrary Loads</em> to YES. You could also do this programmatically by opening up the <em>PList</em> in a text editor, finding <em>NSAppTransportSecurity,</em> and using the following code to set the boolean <em>NSAllowsArbitraryLoads</em> to true.
<pre class="EnlighterJSRAW" data-enlighter-language="raw">&lt;key&gt;NSAppTransportSecurity&lt;/key&gt;
  &lt;dict&gt;
    &lt;key&gt;NSAllowsArbitraryLoads&lt;/key&gt;
    &lt;true/&gt;
  &lt;/dict&gt;</pre>
		
<p>	To go more in depth with App Transport Security, check out this <a href="https://developer.apple.com/library/ios/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html" target="_blank">Apple documentation</a>. </p>
	
	<h3><em>HTML Page for EON</em></h3>
Create a new empty HTML file. This demo calls it <em>eon.html</em>, and has the following code in the head:

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="js">
&lt;script type="text/javascript" src="http://pubnub.github.io/eon/v/eon/0.0.11/eon.js"&gt;&lt;/script&gt;
&lt;link type="text/css" rel="stylesheet" href="http://pubnub.github.io/eon/v/eon/0.0.11/eon.css" /&gt;
</pre>
&nbsp;

Next, you’ll create the graph that will subscribe to the PubNub channel, and display data it was subscribed to in realtime. It’ll attach to an HTML div.

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="js">var pbIOSWeb = PUBNUB({
subscribe_key: 'your-sub-key'
});
var chan = "your-channel";
eon.chart({
    pubnub: pbIOSWeb,
    channel: chan,
    history: false,
    flow: true,
    generate: {
      bindto: '#chart',
      data: {
        type: 'spline'
      },
      axis : {
        x : {
          type : 'timeseries',
          tick : {
            format :'%M'
          } //tick
        }, //x
        y : {
         max: 200,
         min: 10
        } //y
      } //axis
    }, //gen
    transform: function(dataVal) {
      return {
        eon: {
          dataVal: dataVal.heartRate
        }
      }
    }
  });
</pre>
&nbsp;

In this case, the data is formatted in the transform function, which takes in data <i>dataVal</i>. <em>dataVal</em> is the key, and the value being displayed on the chart in realtime is the heart rate, attached to dataVal by the <em>dot.</em> There is no need to publish the data as it’s already being published from the Watch, so only a subscription_key is needed. If no data is showing, it is (from my experience) either an error with <em>App Transport Security</em> or the transform function, so check the <em>PList </em>again or visit one of the links mentioned above.
<h3>Connecting the Phone and the Watch </h3>
The <em>TwitterViewController</em> gets a username, and sends it to the Watch. The Watch gets the user’s heart rate, publishes it to a PubNub channel, and sends it to the Phone, which shows <em>an EON </em>graph of the heart rate. The Raspberry Pi subscribes to that channel, and flashes different colors and at different speeds depending on the beats per minute of the heart rate.

This is perhaps the hardest part of this project. Much data gets transferred between devices, and sometimes, it does not send and it has nothing to do with you. The iPhone is not necessarily “reachable” during every <i>WCSession</i>, and, looking into this error from the console, it seems that quite a few other developers also have this problem.

<h3>InterfaceController</h3>

Mentally prepare yourself, because a lot happens in this file: publishing to PubNub, creating an instance of a Workout, asking permission to access HealthKit data (which includes data like heart rate), sending that data from the Watch to the Phone in a <i>WatchConnectivity</i> session, and more.

Just below your outlet labels, declare the following global variables:

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">var client: PubNub?
    
    let healthStore = HKHealthStore()
    
    let watchAppDel = WKExtension.sharedExtension().delegate! as! ExtensionDelegate
    var publishTimer = NSTimer()
    var wcSesh : WCSession!
    
    var currMoving:Bool = false //not working out
    
    var workoutSesh : HKWorkoutSession?
    let heartRateUnit = HKUnit(fromString: "count/min")
    var anchor = HKQueryAnchor(fromValue: Int(HKAnchoredObjectQueryNoAnchor))
</pre>
&nbsp;

Whenever you need to use <em>HealthKit</em> data, you’ll need an instance of <em>HKHealthStore()</em> to request permission, to start, stop, and manage queries, and more. Before we really dig deep into HealthKit, make sure your project’s HealthKit capabilities are enabled (this is done under <em>Capabilities </em>for your phone app, Watch app, and Watch app Extension <em>targets.)</em> It gives you access to <em>HKQueryAnchor,</em> which returns the last sample from a previous anchored query, or ones that were added or deleted since the last query.

Right after the global variables, initialize your PubNub Configuration:

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">
override init() {
        let watchConfig = PNConfiguration(publishKey: "your-pub-key", subscribeKey: "your-sub-key")
        
        watchAppDel.client = PubNub.clientWithConfiguration(watchConfig)
        
        super.init()
        watchAppDel.client?.addListener(self)
    }
    </pre>
    
  <p>  Create an override func <em>willActivate(), </em>which is also where you would check if a WatchConnectivity Session is supported (you used this code earlier, too, in the phone app). Based on what permissions your app has, different text will be displayed. That code would follow: </p>
&nbsp;



&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">guard HKHealthStore.isHealthDataAvailable() == true else { //err checking/handling
            label.setText("unavailable🙀")
            return
        }
        
        guard let quantityType = HKQuantityType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else {
            displayUnallowed() //only display if Heart Rate
            return
        }
        
        let dataTypes = Set(arrayLiteral: quantityType)
        healthStore.requestAuthorizationToShareTypes(nil, readTypes: dataTypes) { (success, error) -&gt; Void in
            guard success == true else {
                //if success == false {
                self.displayUnallowed()
                return
            }
        }
</pre>
&nbsp;

It checks that we have permission to get heart rate data, requests permission, and creates a WatchConnectivity Session that you will use later to send an array of heart rate data to the phone. This is extra to decide when to tweet -- if you want a less specific tweet, no <i>WatchConnectivity Session</i> is necessary because the EON chart receives its data from PubNub.

![eon-data-visualization-ios-heart-rate-monitor-iphone-screen](https://cloud.githubusercontent.com/assets/8932430/16638804/11001eb0-439f-11e6-93fa-3f98aed42520.jpeg)

&nbsp;

It checks that we have permission to get heart rate data, requests permission, and creates a WatchConnectivity Session that you will use later to send an array of heart rate data to the phone. This is extra to decide when to tweet -- if you want a less specific tweet, no <em>WatchConnectivity Session</em> is necessary because the EON chart receives its data from PubNub.

&nbsp;

How do you get the heart rate? By creating a workout session and then a streaming query!

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">func beginWorkout() {
        self.workoutSesh = HKWorkoutSession(activityType: HKWorkoutActivityType.CrossTraining, locationType: HKWorkoutSessionLocationType.Indoor)
        self.workoutSesh?.delegate = self
        healthStore.startWorkoutSession(self.workoutSesh!)
    }
    
    func makeHRStreamingQuery(workoutStartDate: NSDate) -&gt; HKQuery? {
        
        guard let quantityType = HKObjectType.quantityTypeForIdentifier(HKQuantityTypeIdentifierHeartRate) else { return nil }
        
        let heartRateQuery = HKAnchoredObjectQuery(type: quantityType, predicate: nil, anchor: anchor, limit: Int(HKObjectQueryNoLimit)) { (query, sampleObjects, deletedObjects, newAnchor, error) -&gt; Void in
            guard let newAnchor = newAnchor else {return}
            self.anchor = newAnchor
            self.updateHeartRate(sampleObjects)
        }
        
        heartRateQuery.updateHandler = {(query, samples, deleteObjects, newAnchor, error) -&gt; Void in
            self.anchor = newAnchor!
            self.updateHeartRate(samples)
         }
        return heartRateQuery
    }
</pre>
&nbsp;

It is with quantity type that you could get access to other health data like steps, but in this tutorial, we just want <em>HKQuantityTypeIdentifierHeartRate.</em> We need a <em>WKWorkoutSession</em> to request the heart rate data because that is all developers have access to at the moment. We don’t access the actual heart rate sensors, so the heart rate data is not received in real-time, even with PubNub.

The heartRateQuery is the HealthKit heart rate data received, being constantly streamed until, in the case of this tutorial, the start/stop button is pressed.

The code to publish this data should look something like this:

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">watchAppDel.client?.publish(hrValToPublish, toChannel: "Olaf", withCompletion: { (status) -&gt; Void in
           if !status.error {
               print("\(self.hrVal) has been published")
               
           } //if
               
           else {
               print(status.debugDescription)
           } //else
       })
</pre>
&nbsp;

![apple-watch-heart-rate-monitor-watch-face](https://cloud.githubusercontent.com/assets/8932430/16638809/16a8d532-439f-11e6-8358-7607f49a8f82.png)

This is called from another function, the <em>publishTimerFunc() </em>function, because you do not need to publish heart rate data constantly; does it really matter if the value goes up by one or stays the same for a few seconds? That function contains just one line:
<blockquote>
<pre class="EnlighterJSRAW" data-enlighter-language="raw">publishTimer = NSTimer.scheduledTimerWithTimeInterval(10.0, target: self, selector: #selector(InterfaceController.publishHeartRate), userInfo: nil, repeats: true)
</pre>
&nbsp;</blockquote>
The first parameter of <em>scheduledTimerWithTimeInterval</em> takes the number of seconds between each execution of the function you want to run in intervals. That function is called in <em>selector.</em>

To continuously update the heart rate label, you should use Grand Central Dispatch, which is Swift’s version of background threading. This is what happens in the <em>updateHeartRate()</em> function.

&nbsp;

&nbsp;
<pre class="EnlighterJSRAW" data-enlighter-language="raw">func updateHeartRate(samples: [HKSample]?) {
        guard let heartRateSamples = samples as? [HKQuantitySample] else {return} 
        
        dispatch_async(dispatch_get_main_queue()) {
            guard let sample = heartRateSamples.first else{return}
            self.hrVal = sample.quantity.doubleValueForUnit(self.heartRateUnit)
            let lblTxt = String(self.hrVal)
            self.label.setText(lblTxt)
            self.maxHRLabel.setText("max: " + String(self.maxArr))
            self.deprecatedHRVal = Double(round(1000*self.hrVal)/1000)
            self.arrayOfHR.append(self.deprecatedHRVal)
            self.maxArr = self.arrayOfHR.maxElement()!
            print("maxArr: " + String(self.maxArr))
            repeat {
                self.publishTimerFunc()
            } while(self.currMoving == false)
        } //dispatch_async
    } //func
</pre>
&nbsp;

Here, the heart rate label on the Watch is updated, and an array is created of heart rate values. The maximum is found, and also updated on the Watchface.
<h2>Monitoring the Heart Rate with Raspberry Pi</h2>
The final part of this project is the hardware. To get started, check out this <a href="/blog/2015-07-22-getting-started-with-raspberry-pi-2-and-pubnub-in-python-programming-language/">tutorial</a>. You need <em>4 M-F jumper wires</em>, a Common-cathode RGB-LED, 3 resistors, a breadboard, and a Raspberry Pi. First, hook up the Raspberry Pi to the breadboard with cables as shown below.

![raspberry-pi-diagram](https://cloud.githubusercontent.com/assets/8932430/16638807/12f7324e-439f-11e6-8b23-9f5f53f947a8.png)
&nbsp;

Based on heart rate, the LED will flash on and off at different speeds.
<h2>Conclusion</h2>
There are many components to this app, and hopefully you learned something about developing for the Watch, using EON on platforms other than web, building mobile apps with Fabric, and got some inspiration for future projects.

How can this be taken further?

-Do more with Fabric. I was surprised at how easy it was to integrate Twitter API features into this app, and there is so much to do with other features like Crashlytics, Answers, and more.

-Work more with hardware and displaying or doing something based on heart rate. I looked at music APIs, and getting BPM in songs, which could also be fun to work with.
