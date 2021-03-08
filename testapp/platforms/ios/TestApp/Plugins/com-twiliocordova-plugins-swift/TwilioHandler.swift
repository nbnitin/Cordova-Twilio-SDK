//
//  TwilioHandler.swift
//  HelloGenius
//
//  Created by ATLOGYS on 13/07/20.
//  Copyright © 2020 BigGee. All rights reserved.
//

import UIKit
import TwilioVideo

class TiwilioHandler:NSObject,LocalParticipantDelegate,RoomDelegate,CameraSourceDelegate,RemoteParticipantDelegate,VideoViewDelegate {
    var room : Room!
    // Create an audio track
    var localAudioTrack = LocalAudioTrack()
    
    // Create a data track
    var localDataTrack = LocalDataTrack()
    
    // Create a CameraSource to provide content for the video track
    var localVideoTrack : LocalVideoTrack?
    
    //remote view
    var remoteView: VideoView?
    
    var camera: CameraSource?
    var remoteParticipant: RemoteParticipant?
    
    var viewController : ViewController!
    
    var onGoingCallView : OnGoingCall!
    
    var isVideoRendering : Bool = true
    
    func connect(accessToken:String,roomId:String){
        
        if ( accessToken == "" || roomId == "" ) {
            return
        }
        
        if (( self.room ) != nil) {
            self.room.disconnect()
            //connectButton.setTitle("Connect", for: .normal)
            self.room = nil
            //startPreview(view: viewController.onGoingCallView.previewView)
            return
        }
        
        self.prepareLocalMedia()
        
        
        let accessToken = accessToken
        
        
        let connectOptions = ConnectOptions(token: accessToken) { (builder) in
            builder.roomName = roomId
            // Use the local media that we prepared earlier.
            builder.audioTracks = self.localAudioTrack != nil ? [self.localAudioTrack!] : [LocalAudioTrack]()
            builder.videoTracks = self.localVideoTrack != nil ? [self.localVideoTrack!] : [LocalVideoTrack]()
            
            
            
            if let dataTrack = self.localDataTrack {
                builder.dataTracks = [ dataTrack ]
            }
            
        }
        
        room = TwilioVideoSDK.connect(options: connectOptions, delegate: self)
        
        if viewController.callType == "audio" {
            viewController.speakerMode = .voiceChat
        } else {
            viewController.speakerMode = .videoChat
        }
        viewController.setupAudioDevice()
        
        // Create a video track with the capturer.
        if let camera = CameraSource(delegate: self) {
            localVideoTrack = LocalVideoTrack(source: camera)
        }
        //
    }
    
    func prepareLocalMedia() {
        
        // We will share local audio and video when we connect to the Room.
        // Create an audio track.
        if (localAudioTrack == nil) {
            localAudioTrack = LocalAudioTrack(options: nil, enabled: true, name: "Microphone")
            
            if (localAudioTrack == nil) {
                //                 logMessage(messageText: "Failed to create audio track")
            }
        }
        
        // Create a video track which captures from the camera.
        if ( viewController.callType == "video" ) {
            self.isVideoRendering = true
            //self.startPreview(view: viewController.onGoingCallView.previewView)
        } else {
            self.isVideoRendering = false
            camera = nil
            localVideoTrack = nil
        }
    }
    
    @objc func toggleMic(){
        if ( self.localAudioTrack != nil ) {
            self.localAudioTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!
            
            // Update the button title
            if (self.localAudioTrack?.isEnabled == true) {
                //self.micButton.setTitle("Mute", for: .normal)
                viewController.toggleMic.setImage(UIImage(named:"UN_MUTE"), for: .normal)
            } else {
                //self.micButton.setTitle("Unmute", for: .normal)
                viewController.toggleMic.setImage(UIImage(named:"MUTE"), for: .normal)
            }
        }
    }
    @objc func toggleCamera(){
        if ( isVideoRendering ) {
            
            if ( self.room != nil ) {
                //self.room.localParticipant?.publishVideoTrack(self.localVideoTrack!)
                self.localVideoTrack?.isEnabled = !(self.localAudioTrack?.isEnabled)!

            }
            
            self.camera?.stopCapture(completion: {_ in
                self.isVideoRendering = false
                
                if ( self.room != nil ) {
                    self.room.localParticipant?.unpublishVideoTrack(self.localVideoTrack!)
                }
                
                
                self.viewController.previewViewContainer.isHidden = true
                
                if ( (UserDefaults.standard.value(forKey: "isCallGoingOn") != nil ) && UserDefaults.standard.value(forKey: "isCallGoingOn") as! Bool ) {
                    
                    self.viewController.toggleVideo.setImage(UIImage(named:"NO_VIDEO"), for: .normal)
                } else {
                    //self.viewController.incomingCallView.shouldHidePreview = true
                    self.viewController.toggleVideo.setImage(UIImage(named:"NO_VIDEO"), for: .normal)
                    
                }
                
                
                
            })
            viewController.speakerMode = .voiceChat
            viewController.setupAudioDevice()
            viewController.toggleSpeaker.isHidden = false
        } else {
            // Preview our local camera track in the local video preview view.
            if ( camera == nil ) {
                camera = CameraSource(delegate: self)
                localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
                // Add renderer to video track for local preview
                localVideoTrack!.addRenderer(viewController.previewView)
                // logMessage(messageText: "Video track created")`
            }
            
            let frontCamera = CameraSource.captureDevice(position: .front)
            let backCamera = CameraSource.captureDevice(position: .back)
            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    // self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                } else {
                    self.viewController.previewView.shouldMirror = (captureDevice.position == .front)
                    
                }
                
            }
            
            if ( self.room != nil ) {
                self.room.localParticipant?.publishVideoTrack(self.localVideoTrack!)
                self.localVideoTrack?.isEnabled = true
            }
            isVideoRendering = true
            self.viewController.previewViewContainer.isHidden = false
            
            if ( (UserDefaults.standard.value(forKey: "isCallGoingOn") != nil ) && UserDefaults.standard.value(forKey: "isCallGoingOn") as! Bool ) {
                
                self.viewController.toggleVideo.setImage(UIImage(named:"VIDEO_ON"), for: .normal)
                
            } else {
                self.viewController.toggleVideo.setImage(UIImage(named:"VIDEO_ON"), for: .normal)
               
                
            }
            viewController.speakerMode = .videoChat
            viewController.setupAudioDevice()
            viewController.toggleSpeaker.isHidden = true

            //            localVideoTrack!.addRenderer(viewController.previewView)
            
        }
    }
    
    
    
    func setupRemoteVideoView() {
        
        self.remoteView = viewController.onGoingCallView.recevierVideoRenderView
        self.remoteView!.contentMode = .scaleAspectFit;
    }
    
    
    // MARK:- Private
    func startPreview(view:VideoRenderer) {
        //        if PlatformUtils.isSimulator {
        //            return
        //        }
        
        let frontCamera = CameraSource.captureDevice(position: .front)
        let backCamera = CameraSource.captureDevice(position: .back)
        self.viewController.toggleVideo.setImage(UIImage(named:"VIDEO_ON"), for: .normal)
        
        if (frontCamera != nil || backCamera != nil) {
            
            let options = CameraSourceOptions { (builder) in
                // To support building with Xcode 10.x.
                #if XCODE_1100
                if #available(iOS 13.0, *) {
                    // Track UIWindowScene events for the key window's scene.
                    // The example app disables multi-window support in the .plist (see UIApplicationSceneManifestKey).
                    builder.orientationTracker = UserInterfaceTracker(scene: UIApplication.shared.keyWindow!.windowScene!)
                }
                #endif
            }
            // Preview our local camera track in the local video preview view.
            camera = CameraSource(options: options, delegate: self)
            localVideoTrack = LocalVideoTrack(source: camera!, enabled: true, name: "Camera")
            
            // Add renderer to video track for local preview
            localVideoTrack!.addRenderer(view)
            
            
            // logMessage(messageText: "Video track created")
            
            if (frontCamera != nil && backCamera != nil) {
                // We will flip camera on tap.
                //let tap = UITapGestureRecognizer(target: self, action: #selector(self.flipCamera))
                //viewController.onGoingCallView.previewView.addGestureRecognizer(tap)
            }
            
            camera!.startCapture(device: frontCamera != nil ? frontCamera! : backCamera!) { (captureDevice, videoFormat, error) in
                if let error = error {
                    // self.logMessage(messageText: "Capture failed with error.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                } else {
                    self.viewController.previewView.shouldMirror = (captureDevice.position == .front)
                    self.isVideoRendering = true
                }
                
                if ( self.room != nil ) {
                    self.room.localParticipant?.publishVideoTrack(self.localVideoTrack!)
                }
            }
        }
        else {
            // self.logMessage(messageText:"No front or back capture device found!")
        }
    }
    
    @objc func flipCamera() {
        var newDevice: AVCaptureDevice?
        
        if let camera = self.camera, let captureDevice = camera.device {
            if captureDevice.position == .front {
                newDevice = CameraSource.captureDevice(position: .back)
            } else {
                newDevice = CameraSource.captureDevice(position: .front)
            }
            
            if let newDevice = newDevice {
                camera.selectCaptureDevice(newDevice) { (captureDevice, videoFormat, error) in
                    if let error = error {
                        // self.logMessage(messageText: "Error selecting capture device.\ncode = \((error as NSError).code) error = \(error.localizedDescription)")
                    } else {
                        self.viewController.previewView.shouldMirror = (captureDevice.position == .front)
                    }
                }
            }
        }
    }
    
    // MARK: RoomDelegate
    
    func roomDidConnect(room: Room) {
        // The Local Participant
        if let localParticipant = room.localParticipant {
            print("Local identity \(localParticipant.identity)")
            
            // Set the delegate of the local participant to receive callbacks
            localParticipant.delegate = self
        }
        
        // Connected participants already in the room
        print("Number of connected Participants \(room.remoteParticipants.count)")
        
        if ( !self.viewController.isCallOutgoing && room.remoteParticipants.count < 1 ) {
            self.viewController?.callEnd()
        } else if ( room.remoteParticipants.count > 0 ) {
            self.viewController?.onGoingCallView.trackCallDuration()
        }
        
        // Set the delegate of the remote participants to receive callbacks
        for remoteParticipant in room.remoteParticipants {
            remoteParticipant.delegate = self
        }
        
        if ( self.viewController.callType == "video" && self.viewController.isCallOutgoing == false ) {
                   room.localParticipant?.publishVideoTrack(self.localVideoTrack!)
        }
    }
    
    // First, we set a Participant Delegate when a Participant first connects:
    func participantDidConnect(room: Room, participant: RemoteParticipant) {
        print("Participant connected: \(participant.identity)")
        participant.delegate = self
        viewController.callPicked()
        
        if ( self.viewController.callType == "video" ) {
                   room.localParticipant?.publishVideoTrack(self.localVideoTrack!)
        }
    }
    
    func participantDidDisconnect(room: Room, participant: RemoteParticipant) {
        print ("Participant \(participant.identity) has left Room \(room.name)")
        viewController.showCallEndView()
    }
    
    //Display a Remote Participant's Video
    /*
     * In the Participant Delegate, we can respond when the Participant adds a Video
     * Track by rendering it on screen.
     */
    func didSubscribeToVideoTrack(videoTrack: RemoteVideoTrack,
                                  publication: RemoteVideoTrackPublication,
                                  participant: RemoteParticipant) {
        
        print("Participant \(participant.identity) added a video track.")
        if let remoteView = VideoView.init(frame: viewController.onGoingCallView!.recevierVideoRenderView.frame,
                                           delegate:self) {
            
            videoTrack.addRenderer(remoteView)
            
            viewController.onGoingCallView.userImage.isHidden = true
            viewController.onGoingCallView.recevierVideoRenderView.isHidden = false
            self.remoteView = remoteView
        }
        
        
        if (self.remoteParticipant == nil) {
            _ = renderRemoteParticipant(participant: participant)
        }
    }
    
    func didUnsubscribeFromVideoTrack(videoTrack: RemoteVideoTrack, publication: RemoteVideoTrackPublication, participant: RemoteParticipant) {
        viewController.onGoingCallView.userImage.isHidden = false
        viewController.onGoingCallView.recevierVideoRenderView.isHidden = true
        
    }
    
    func remoteParticipantDidUnpublishVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
        print(publication.isTrackSubscribed)
        //in case of audio call we need to remove participant on local variable to reshow video when subscribed again in the same call...
        if ( viewController.callType == "audio" ) {
            self.remoteParticipant = nil
        }
    }
    
    func remoteParticipantDidEnableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
           viewController.onGoingCallView.userImage.isHidden = true
           viewController.onGoingCallView.recevierVideoRenderView.isHidden = false
       }
       
       func remoteParticipantDidDisableVideoTrack(participant: RemoteParticipant, publication: RemoteVideoTrackPublication) {
           viewController.onGoingCallView.userImage.isHidden = false
           viewController.onGoingCallView.recevierVideoRenderView.isHidden = true
       }
    
    
    
    func renderRemoteParticipants(participants : Array<RemoteParticipant>) {
        for participant in participants {
            // Find the first renderable track.
            if participant.remoteVideoTracks.count > 0,
                renderRemoteParticipant(participant: participant) {
                break
            }
        }
    }
    
    func renderRemoteParticipant(participant : RemoteParticipant) -> Bool {
        // This example renders the first subscribed RemoteVideoTrack from the RemoteParticipant.
        let videoPublications = participant.remoteVideoTracks
        for publication in videoPublications {
            if let subscribedVideoTrack = publication.remoteTrack,
                publication.isTrackSubscribed {
                setupRemoteVideoView()
                subscribedVideoTrack.addRenderer(self.remoteView!)
                self.remoteParticipant = participant
                return true
            }
        }
        return false
    }
    
    // MARK: VideoViewDelegate
    
    // Lastly, we can subscribe to important events on the VideoView
    func videoViewDimensionsDidChange(view: VideoView, dimensions: CMVideoDimensions) {
        print("The dimensions of the video track changed to: \(dimensions.width)x\(dimensions.height)")
        self.viewController.onGoingCallView.setNeedsLayout()
    }
}
