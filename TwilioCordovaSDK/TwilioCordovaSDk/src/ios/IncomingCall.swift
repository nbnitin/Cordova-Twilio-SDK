//
//  IncomingVideoCall.swift
//
//  Created by Nitin Bhatia on 13/07/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit
import Lottie
import TwilioVideo
import SDWebImage

class IncomingCall : UIView {
    
    var shouldHidePreview : Bool = false
    
    
  
    @IBOutlet weak var callTypeImage: UIImageView!
    @IBOutlet weak var participantName: UILabel!
    @IBOutlet weak var participantImage: UIImageView!
    @IBOutlet weak var cancelButton: CircleButton!
    @IBOutlet weak var recevieButton: CircleButton!
    @IBOutlet weak var callTypeLabel: UILabel!
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
        Bundle.main.loadNibNamed("IncomingCall", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        participantImage.frame.size.width = participantImage.frame.height
        participantImage.layer.cornerRadius = participantImage.frame.height / 2
    }
    
    var callType : String = "audio"  {
        didSet {
            if ( callType == "audio" ) {
                backgroundForAudio()
                callTypeLabel.text = "Voice Call"
                recevieButton.setImage(UIImage(named:"AUDIO_CALL_IN"), for: .normal)
                callTypeImage.image = UIImage(named:"Audio_Calling_Top")
                shouldHidePreview = true
            } else {
                backgorundForVideo()
                callTypeLabel.text = "Video Call"
                callTypeImage.image = UIImage(named:"Video_Calling_Top")
                recevieButton.setImage(UIImage(named:"VIDEO_CALL_IN"), for: .normal)
                shouldHidePreview = false
            }
            
        }
    }
    
    var profile : String? = nil {
        didSet {
            if profile != nil && !(profile!.isEmpty) {
                participantImage.sd_setImage(with: URL(string: profile!), placeholderImage: UIImage(named: "user_place_holder_logout"),completed:{(image, error, cache, url) in
                        self.participantImage.image = image?.circle
                    
                })
                
            } else {
                participantImage.image = UIImage(named:"user_place_holder_logout")?.circle
            }
           
           startAnimation()

        }
    }
    
    
    private func backgroundForAudio() {
        let colorTop =  UIColor(red: 9/255.0, green: 127/255.0, blue: 103/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.contentView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func backgorundForVideo(){
        let colorTop =  UIColor(red: 123/255.0, green: 4/255.0, blue: 46/255.0, alpha: 0.9).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "callingLayer"
        self.contentView.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func startAnimation(){
        let animation = Animation.named("lottie_file_call_ripple")
        let animationView = AnimationView()
        self.contentView.insertSubview(animationView, at: 0)
        animationView.animation = animation
        animationView.contentMode = .scaleToFill
        animationView.frame = self.frame
        animationView.bringSubviewToFront(participantImage)
        animationView.backgroundBehavior = .pauseAndRestore //it helps to restarts animation when application opens from background
        // animationContainer.layer.cornerRadius = animationView.frame.width / 2
        animationView.play()
        animationView.loopMode = .loop
        // 3. THIRD STEP (LAYOUT PREFERENCES):
        animationView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            //            animationView.leftAnchor.constraint(equalTo: self.leftAnchor),
            //            animationView.rightAnchor.constraint(equalTo: self.rightAnchor),
            //            animationView.topAnchor.constraint(equalTo: self.topAnchor),
            //            animationView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            
            animationView.centerYAnchor.constraint(equalTo: self.participantImage.centerYAnchor),
            animationView.centerXAnchor.constraint(equalTo: self.participantImage.centerXAnchor)
            
        ])
        
        layoutIfNeeded()
        
    }
    
}
