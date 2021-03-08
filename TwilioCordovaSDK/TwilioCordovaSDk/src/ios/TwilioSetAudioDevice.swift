//
//  TwilioSetAudioDevice.swift
//  Test
//
//  Created by Nitin Bhatia on 9/30/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import Foundation
import TwilioVideo

class SetTwilioAudio:AppDelegate {
    
    static let shared = SetTwilioAudio()
    var audioDevice : DefaultAudioDevice! = DefaultAudioDevice()
    
    override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        TwilioVideoSDK.audioDevice = audioDevice
      return true
    }
}
