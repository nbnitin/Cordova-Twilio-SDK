//
//  OnGoingCall.swift
//  HelloGenius
//
//  Created by ATLOGYS on 13/07/20.
//  Copyright © 2020 BigGee. All rights reserved.
//

import UIKit
import TwilioVideo
import SDWebImage

class OnGoingCall : UIView{
    
    deinit {
        if ( timer != nil ) {
            timer.invalidate()
        }
    }
    
    var timer : Timer!
    
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var cancelButton: UIButton!
    
    @IBOutlet weak var participantNameLabel: UILabel!
    @IBOutlet weak var callTypeImage: UIImageView!
    @IBOutlet weak var callTypeLabel: UILabel!
    @IBOutlet weak var recevierVideoRenderView: VideoView!
    @IBOutlet weak var callDurationLabel: UILabel!
    @IBOutlet var contentView: UIView!
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        Bundle.main.loadNibNamed("OnGoingCall", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        
    }
    
    var callType : String = "audio"   {
        didSet {
            if ( callType == "audio" ) {
                self.backgroundForAudio()
                self.callTypeLabel.text = "Voice Call"
                // previewView.isHidden = true
                // recevierVideoRenderView.isHidden = true
                // switchCamera.isHidden = true
                callTypeImage.image = UIImage(named:"Audio_Calling_Top")
                //switchCamera.setImage(UIImage(named:"NO_VIDEO"), for: .normal)
            } else {
                self.backgorundForVideo()
                self.callTypeLabel.text = "Video Call"
                userImage.isHidden = true
                callTypeImage.image = UIImage(named:"Video_Calling_Top")
            }
        }
    }
    
    var profile : String? = nil {
        didSet {
             if profile != nil && !(profile!.isEmpty) {
                userImage.sd_setImage(with: URL(string: profile!), placeholderImage: UIImage(named: "user_place_holder_logout"),completed:{(image, error, cache, url) in
                        self.userImage.image = image?.circle
                    
                })
                
            } else {
                userImage.image = UIImage(named:"user_place_holder_logout")?.circle
            }
           
            // participantNameLabel.text = profile?.name ?? profile?.nickName ?? "On Going Call With Participant"
            trackCallDuration()
        }
    }
    
    private func backgroundForAudio() {
        
        self.layer.sublayers?.forEach { if $0.name == "callingLayer" {$0.removeFromSuperlayer()} }
        
        let colorTop =  UIColor(red: 9/255.0, green: 127/255.0, blue: 103/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "callingLayer"
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func backgorundForVideo(){
        self.layer.sublayers?.forEach { if $0.name == "callingLayer" {$0.removeFromSuperlayer()} }
        let colorTop =  UIColor(red: 123/255.0, green: 4/255.0, blue: 46/255.0, alpha: 0.9).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "callingLayer"
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    func trackCallDuration(){
        var minutes = 0
        var seconds = 0
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: {_ in
            seconds += 1
            if ( seconds == 60 ) {
                seconds = 0
                minutes += 1
            }
            let minuteString = minutes < 10 ? "0\(minutes)" : "\(minutes)"
            let secondsString = seconds < 10 ? "0\(seconds)" : "\(seconds)"
            self.callDurationLabel.text = minuteString + ":" + secondsString
        })
    }
}


extension UIImage {
var circle: UIImage? {
        let square = CGSize(width: min(size.width, size.height), height: min(size.width, size.height))
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
    imageView.contentMode = .scaleAspectFill
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        UIGraphicsBeginImageContext(imageView.bounds.size)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
    imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}
