import RPi.GPIO as GPIO
import sys
import time
import random
from pubnub import Pubnub

pubKey = 'pub-c-1b5f6f38-34c4-45a8-81c7-7ef4c45fd608'
subKey = 'sub-c-a3cf770a-2c3d-11e6-8b91-02ee2ddab7fe'

pubnub = Pubnub(publish_key=pubKey, subscribe_key=subKey)

channel = 'Olaf'
GPIO.setmode(GPIO.BCM) #board??
LIGHT = 2
GPIO.setup(LIGHT, GPIO.OUT)

redGpioMain = 9 #gpio9 = red
greenGpioMain = 6
blueGpioMain = 8
plainGpio = 2
GPIO.setup(redGpioMain, GPIO.OUT)
GPIO.setup(greenGpioMain, GPIO.OUT)
GPIO.setup(blueGpioMain, GPIO.OUT)
GPIO.setup(plainGpio, GPIO.OUT)

Freq = 100 #Hz

# Asynchronous usage
def callback(message, channel):
    dictOfTwitterUNames = dict()
    for key in message:
        print(message)
        if key in dictOfTwitterUNames:
            greenGpioMain = dictOfTwitterUNames[key]
        else:
            dictOfTwitterUNames[key] = plainGpio
        #check(message.get("heartRate"), dictOfTwitterUNames[key])
        if key == 'lizziepika' :
            check(message.get("heartRate"), greenGpio)        
elif key == 'bastabayarea' :
            check(message.get("heartRate"), plainGpioMain)
        elif key == '':
            check(message.get("heartRate"), blueGpioMain)
        print('hrVal: ' + str(message.get("heartRate")))
        print('color: ' + str(dictOfTwitterUNames[key]))
def check(hrVal, color):
    if float(hrVal) < 65.0:
        GPIO.output(color, True)
        time.sleep(0.7)
        GPIO.output(color, False)
        time.sleep(0.7)
        GPIO.output(color, True)
        time.sleep(0.7)
        GPIO.output(color, False)
    elif float(hrVal) > 65 and float(hrVal) < 80:
        GPIO.output(color, True)
        time.sleep(0.5)
        GPIO.output(color, False)
        time.sleep(0.5)
        #check(message[key])
    elif float(hrVal) > 80:
        GPIO.output(color, True)
        time.sleep(0.1)
        GPIO.output(color, False)
        time.sleep(0.1)
    else:
        print('err re. checking float(hrVal)')
def error(message):
    print("ERROR : " + str(message))

def connect(message):
    print("CONNECTED")

def reconnect(message):
    print("RECONNECTED")

def disconnect(message):
    print('DISCONNECTED')
    GPIO.output(blueGpioMain, False)
    GPIO.output(redGpioMain, False)
    GPIO.output(plainGpio)
    GPIO.output(GreenGpioMain, False)
pubnub.subscribe(channels=channel, callback=callback, error=callback,
                 connect=connect, reconnect=reconnect, disconnect=disconnect)

try:
    while 1:
        pass
except KeyboardInterrupt:
    GPIO.cleanup()
    sys.exit(1)
