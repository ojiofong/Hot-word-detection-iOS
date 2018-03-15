//
//  ViewController.swift
//  SnowBoySample
//
//  Created by Oji Ofong on 3/14/18.
//  Copyright © 2018 Oji Ofong. All rights reserved.
//

import UIKit
import Toaster
import EZAudio

class ViewController: UIViewController, EZMicrophoneDelegate {
    
    @IBOutlet weak var mLabel: UILabel!
    @IBOutlet weak var mButton: UIButton!
    
    let RESOURCE = Bundle.main.path(forResource: "common", ofType: "res")
    let MODEL = Bundle.main.path(forResource: "alexa_02092017", ofType: "umdl")
    var microphone: EZMicrophone!
    var wrapper: SnowboyWrapper!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPermissions()
        initSnowboy()
    }

    @IBAction func onTapButton(_ sender: UIButton) {
        doStuff()
    }
    
    func doStuff() {
        Toast.init(text: "Doing stuff!!").show()
        if microphone == nil {
            initMic()
        }else{
            microphone.stopFetchingAudio()
            self.mLabel?.text = "Stopped"
        }
    }
    
    func initPermissions() {
        AVCaptureDevice.requestAccess(for: .audio) { success in
            Toast.init(text: "Request Audio success \(success)").show()
        }
    }
    
    //  Converted to Swift 4 by Swiftify v4.1.6640 - https://objectivec2swift.com/
    func initSnowboy() {
        wrapper = SnowboyWrapper(resources: RESOURCE, modelStr: MODEL)
        wrapper.setSensitivity("0.5")
        wrapper.setAudioGain(1.0)
        print("Sample rate: \(wrapper?.sampleRate()); channels: \(wrapper?.numChannels()); bits: \(wrapper?.bitsPerSample())")
    }
    
    func initMic() {
        var audioStreamBasicDescription: AudioStreamBasicDescription = EZAudioUtilities.monoFloatFormat(withSampleRate: 16000)
        audioStreamBasicDescription.mFormatID = kAudioFormatLinearPCM
        audioStreamBasicDescription.mSampleRate = Float64(16000)
        audioStreamBasicDescription.mFramesPerPacket = 1
        audioStreamBasicDescription.mBytesPerPacket = 2
        audioStreamBasicDescription.mBytesPerFrame = 2
        audioStreamBasicDescription.mChannelsPerFrame = 1
        audioStreamBasicDescription.mBitsPerChannel = 16
        audioStreamBasicDescription.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked
        audioStreamBasicDescription.mReserved = 0
        if let currentInput = EZAudioDevice.currentInput(){
            microphone = EZMicrophone(delegate: self, with: audioStreamBasicDescription)
            microphone.device = currentInput
            microphone.startFetchingAudio()
        }
    }
    
    func microphone(_ microphone: EZMicrophone!, hasAudioReceived buffer: UnsafeMutablePointer<UnsafeMutablePointer<Float>?>!, withBufferSize bufferSize: UInt32, withNumberOfChannels numberOfChannels: UInt32) {
        DispatchQueue.main.async(execute: {() -> Void in
            print("received bufferSize", bufferSize)
            self.mLabel.text = "received bufferSize \(bufferSize)"
            
            let pointer = buffer.pointee
            let arr = Array(UnsafeBufferPointer(start: pointer, count: Int(bufferSize)))
            let result: Int = Int(self.wrapper.runDetection(arr, length: Int32(bufferSize)))
            if result == 1 {
                print("Hotword Detected")
                Toast.init(text: "Hotword Detected").show()
            }else{
                print("result", result)
            }
            
        })
    }
}

extension Data {
    func castToCPointer<T>() -> T {
        return self.withUnsafeBytes { $0.pointee }
    }
}

