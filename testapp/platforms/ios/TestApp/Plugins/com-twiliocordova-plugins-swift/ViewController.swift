//
//  AudioVideoCallingViewController.swift
//  HelloGenius
//
//  Created by ATLOGYS on 10/07/20.
//  Copyright © 2020 BigGee. All rights reserved.
//

import UIKit
import TwilioVideo
import AudioToolbox
import AVKit

let MESSAGE_FOR_OUTGOING = "CALL_CANCELLED"
let MESSAGE_FOR_INCOMING = "CALL_REJECTED"
let MESSAGE_FOR_ONGOING = ""
let MESSAGE_FOR_BUSY = "CALL_BUSY"

class ViewController : UIViewController {
    //uncomment after pasting it into cordova plugin
    var commandDelegate : CDVCommandDelegate!
    var callBackId : String!
    
    var twilioHandler : TiwilioHandler!
    var audioPlayer : AVAudioPlayer!
    var timer : Timer!
    var onGoingCallView : OnGoingCall!
    var outGoingCallView : OutGoingCall!
    var incomingCallView : IncomingCall!
    var callEnded : CallEnded!
    var callType : String! = "video"
    var userName : String! = "Hello"
    var imgUrl : String!
    var isCallOutgoing : Bool! = true
    var participantToken : String = ""
    var roomId : String = ""
    var callAboutToConnectTimer : Timer!
    var speakerMode : AVAudioSession.Mode = .videoChat
    var message : String = ""
    var normalCallEnd : Bool = true

    var isCallGoingOn = false
    
    @IBOutlet weak var previewViewContainer: UIView!
    
    @IBOutlet var toggleSpeaker: UIButton!
    @IBOutlet weak var previewView: VideoView!
    
    @IBOutlet var toggleVideo: UIButton!
    @IBOutlet var toggleMic: UIButton!
    @IBOutlet weak var switchCameraButton: UIButton!
    @IBOutlet weak var otherViewContainer: UIView!
    
    var statusBarStyle : UIStatusBarStyle = .default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        onGoingCallView = OnGoingCall()
        outGoingCallView = OutGoingCall()
        incomingCallView = IncomingCall()
        callEnded = CallEnded()
        
        twilioHandler = TiwilioHandler()
        twilioHandler.viewController = self
        
        switchCameraButton.addTarget(twilioHandler.self, action: #selector(twilioHandler.flipCamera), for: .touchUpInside)
        
        if ( isCallOutgoing ) {
            self.setBackgroundForCalling()
            
            if ( callType == "audio" ) {
                speakerMode = .voiceChat
            } else {
                speakerMode = .videoChat
            }
        } else {
            self.setBackgroundForIncomingCall()
            speakerMode = .videoChat
        }
        
        if callType == "audio" {
            previewViewContainer.isHidden = true
            toggleVideo.isSelected = false
        } else {
            toggleSpeaker.isHidden = true
            toggleVideo.isSelected = true
        }
        
        setupAudioDevice()
        toggleSpeaker.setImage(UIImage(named:"speaker"), for: .selected)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        statusBarStyle
    }
    
    
    func connect(participantToken:String,roomId:String){
        if ( callAboutToConnectTimer != nil ) {
            callAboutToConnectTimer.invalidate()
        }
        
        if ( callType == "audio" ) {
            speakerMode = .voiceChat
        } else {
            speakerMode = .videoChat
        }
        
        setupAudioDevice()
        let ringTone = URL(fileURLWithPath: Bundle.main.path(forResource: "ringtone_out_going", ofType: "mp3")!)
        playSound(ringTone:ringTone)
        twilioHandler.viewController = self
        twilioHandler.connect(accessToken: participantToken, roomId: roomId)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let statusView = UIView()
        statusView.backgroundColor = UIColor.black
        statusView.frame = UIApplication.shared.statusBarFrame
        self.view.addSubview(statusView)
        statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        toggleVideo.isEnabled = false
        
        if ( callType != "audio" ) {
            twilioHandler.startPreview(view: previewView)
        } else {
            
            toggleVideo.isEnabled = false
        }
    }
    
    func playSound(ringTone : URL,numberOfLoop:Int = -1){
        if audioPlayer != nil {
            audioPlayer.stop()
        }
        audioPlayer = try? AVAudioPlayer(contentsOf: ringTone)
        audioPlayer.numberOfLoops = numberOfLoop
        audioPlayer.play()
    }
    
    
    func callPicked(){
        message = MESSAGE_FOR_ONGOING
        
        if ( callType == "audio" ) {
            speakerMode = .voiceChat
        } else {
            speakerMode = .videoChat
        }
        
        setupAudioDevice()
        
        
        UserDefaults.standard.set(true, forKey: "isCallGoingOn")
        
        self.isCallGoingOn = true
        
        otherViewContainer.viewWithTag(20)?.removeFromSuperview()
        onGoingCallView.frame = self.view.frame
        otherViewContainer.addSubview(onGoingCallView)
        onGoingCallView.callType = callType
        onGoingCallView.profile = imgUrl
        
        toggleVideo.isEnabled = true
        
        onGoingCallView.cancelButton.addTarget(self, action: #selector(showCallEndView), for: .touchUpInside)
        
        onGoingCallView.participantNameLabel.text = userName
        
        outGoingCallView.removeFromSuperview()
        
        if ( audioPlayer != nil ) {
            self.audioPlayer.stop()
        }
        
        if ( timer != nil ) {
            timer.invalidate()
        }
        
        self.view.layoutSubviews()
        
        
    }
    
    @objc func showCallEndView(){
        callEnded.callDuration.text = onGoingCallView.callDurationLabel.text!
        message = "callDuration - \(onGoingCallView.callDurationLabel.text!)"
        normalCallEnd = true
        callEnd()
    }
    
    @objc func callEnd(){
        callEnded.frame = CGRect(x: 0, y: 0, width: otherViewContainer.frame.width, height: otherViewContainer.frame.height)
        
        if ( twilioHandler.room != nil ) {
            twilioHandler.room.disconnect()
        }
        if ( audioPlayer != nil ) {
            audioPlayer.stop()
        }
        if ( timer != nil ) {
            timer.invalidate()
        }
        
        if ( callAboutToConnectTimer != nil ) {
            callAboutToConnectTimer.invalidate()
        }
        
        toggleMic.isHidden = true
        toggleVideo.isHidden =  true
        toggleSpeaker.isHidden = true
        
        otherViewContainer.addSubview(callEnded)
        callEnded.callTypeVar = callType
        
        if !normalCallEnd {
            //callEndedView.callType.text = callEndedView.callType.text!.components(separatedBy: " ").dropLast().joined(separator: " ")
            callEnded.callType.text = callEnded.callDuration.text!
            callEnded.callDuration.isHidden = true
        }
        callEnded.profile = imgUrl
        onGoingCallView.removeFromSuperview()
        callEnded.participantName.text = userName 
        
        callEnded.doneButton.addTarget(self, action: #selector(goToParent), for: .touchUpInside)
        callEnded.closeScreen.addTarget(self, action: #selector(goToParent), for: .touchUpInside)
        previewViewContainer.isHidden = true
    }
    
    @objc func goToParent(){
        statusBarStyle = .default
        self.notifyCordova()
        self.view.removeFromSuperview()
        self.removeFromParent()
    }
    
    //uncomment after pasting into plugin
    func notifyCordova(){
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK,messageAs: message)
        commandDelegate.send(pluginResult, callbackId: callBackId)
    }
    
    func forceEndCall(messageToShow:String){
        callEnded.callDuration.text = messageToShow
        for subView in otherViewContainer.subviews {
            if let view = subView as? OutGoingCall {
                view.removeFromSuperview()
            } else if let view = subView as? IncomingCall {
                view.removeFromSuperview()
            } else if let view = subView as? OnGoingCall {
                view.removeFromSuperview()
            }
        }
        normalCallEnd = false
        callEnd()
    }
    
    
    func setBackgroundForCalling() {
        
        outGoingCallView.profile = imgUrl
        message = MESSAGE_FOR_OUTGOING
        
        
        otherViewContainer.addSubview(outGoingCallView)
        outGoingCallView.frame = self.view.frame
        outGoingCallView.cancelButton.addTarget(self, action: #selector(cancelCall), for: .touchUpInside)
        
        
        
        outGoingCallView.callType = callType
        outGoingCallView.participantName.text = userName
        
        let ringTone = URL(fileURLWithPath: Bundle.main.path(forResource: "Beep tone_BLASTWAVEFX_30241", ofType: "mp3")!)
        
        callAboutToConnectTimer = Timer.scheduledTimer(withTimeInterval: 1 , repeats: true, block: {_ in
            self.playSound(ringTone: ringTone,numberOfLoop: 1)
        })
        
        
        
        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: {_ in
            self.audioPlayer.stop()
            
            if self.callAboutToConnectTimer != nil {
                self.callAboutToConnectTimer.invalidate()
            }
            self.cancelCall()
        })
    }
    
    func setBackgroundForIncomingCall() {
        
        message = MESSAGE_FOR_INCOMING
        
        let ringTone = URL(fileURLWithPath: Bundle.main.path(forResource: "iphoneDefault", ofType: "mp3")!)
        self.playSound(ringTone: ringTone)
        
//        timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: false, block: {_ in
//            self.audioPlayer.stop()
//
//            if self.callAboutToConnectTimer != nil {
//                self.callAboutToConnectTimer.invalidate()
//            }
//            self.dismiss(animated: true, completion: {
//                //self.notifyCordova(message: "CALL_CANCELED")
//            })
//        })
//
        
        incomingCallView.frame = self.view.frame
        incomingCallView.tag = 20
        incomingCallView.participantName.text = userName
        
        otherViewContainer.addSubview(incomingCallView)
        
        incomingCallView.cancelButton.addTarget(self, action: #selector(cancelCall), for: .touchUpInside)
        incomingCallView.recevieButton.addTarget(self, action: #selector(joinCall), for: .touchUpInside)
        
        incomingCallView.profile = imgUrl
        incomingCallView.callType = callType
        
        incomingCallView.cancelButton.addTarget(self, action: #selector(cancelCall), for: .touchUpInside)
        self.view.layoutSubviews()
        
    }
    
    
    
    @objc func cancelCall() {
        if ( twilioHandler.room != nil ) {
            twilioHandler.room.disconnect()
        }
        if ( audioPlayer != nil ) {
            audioPlayer.stop()
        }
        if ( timer != nil ) {
            timer.invalidate()
        }
        if ( callAboutToConnectTimer != nil ) {
            callAboutToConnectTimer.invalidate()
        }
        
        self.goToParent()
    }
    
    @objc func joinCall(){
        twilioHandler.connect(accessToken: participantToken, roomId: roomId)
        callPicked()
    }
    
    @IBAction func toggleVideo(_ sender: Any) {
        toggleVideo.isSelected = !toggleVideo.isSelected
        twilioHandler.toggleCamera()
        
        if toggleVideo.isSelected && isCallGoingOn {
            onGoingCallView.callType = "video"
        } else {
            onGoingCallView.callType = "audio"
        }
    }
    
    @IBAction func toggleMic(_ sender: Any) {
        //toggleMic.isSelected = !toggleMic.isSelected
        twilioHandler.toggleMic()
    }
    @IBAction func toggleSpeaker(_ sender: Any) {
        toggleSpeaker.isSelected = !toggleSpeaker.isSelected
        
        if toggleSpeaker.isSelected {
            speakerMode = .default
        } else {
            speakerMode = .voiceChat
        }
        setupAudioDevice()
    }
    
    func setupAudioDevice(){
        // Change the audio route after connecting to a Room.
        SetTwilioAudio.shared.audioDevice.block = {
            do {
                let audioSession = AVAudioSession.sharedInstance()
                DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
                try audioSession.setMode(self.speakerMode)
                
                
                try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
            } catch let error as NSError {
                print("Fail: \(error.localizedDescription)")
            }
        }
        
        SetTwilioAudio.shared.audioDevice.block()
    }
    
}


