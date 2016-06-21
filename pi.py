#to run: sudo python pi.py
#!/usr/bin/python
# pip install RPi.GPIO
import RPi.GPIO as GPIO
import time
import sys
from pubnub import Pubnub

def runPi():
	pubnub = Pubnub(publish_key='pub-c-1b5f6f38-34c4-45a8-81c7-7ef4c45fd608', subscribe_key='sub-c-a3cf770a-2c3d-11e6-8b91-02ee2ddab7fe')

	channel = 'iWorkout'

	username = 'Your name'
	heartRate = 'heartRate'

	data = {
    	'username': username,
    	'heartRate': heartRate
	}
	pubnub.subscribe(channels=channel, callback = callback, error = _error) #get data
	if hrVal > 40 and hrVal < 60: #:
	#GPIO.output(LIGHT, True)
		print("first")
		time.sleep(1)
	elif hrVal <= 40:
		#GPIO.output(LIGHT, False)
		print("second")
		time.sleep(1)
	elif hrVal >= 60 and hrVal < 80:
		print("third")
		time.sleep(1)
	else:
		print("fourth")
		time.sleep(1)
#pubnub.publish(channel, data, callback=callback, error=callback) #led
GPIO.setmode (GPIO.BCM)

LIGHT = 4

#GPIO.setup(LIGHT, GPIO.OUT)

def callback(m, channel):
    print(m)

def _error(m):
	print(m)



if __name__ == "__runPi__":
	runPi()
	callback(m, channel)
	_error(m)

