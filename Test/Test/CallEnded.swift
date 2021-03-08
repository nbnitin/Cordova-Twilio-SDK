//
//  OnGoingCall.swift
//
//  Created by Nitin Bhatia on 13/07/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import UIKit

class CallEnded: UIView{
    
    
    @IBOutlet weak var closeScreen: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var participantName: UILabel!
    @IBOutlet weak var callType: UILabel!
    @IBOutlet weak var callDuration: UILabel!
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
        Bundle.main.loadNibNamed("CallEnded", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight,.flexibleWidth]
        
        
    }
    
    
    var callTypeVar : String = "audio"   {
        didSet {
            if ( callTypeVar == "audio" ) {
                self.backgroundForAudio()
                self.callType.text = "Voice Call Ended"
            } else {
                self.backgorundForVideo()
                self.callType.text = "Video Call Ended"
            }
            doneButton.layer.cornerRadius = doneButton.frame.height / 2
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
           
           
        }
    }
    
    private func backgroundForAudio() {
        let colorTop =  UIColor(red: 9/255.0, green: 127/255.0, blue: 103/255.0, alpha: 1.0).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        self.layer.insertSublayer(gradientLayer, at:0)
    }
    
    private func backgorundForVideo(){
        let colorTop =  UIColor(red: 123/255.0, green: 4/255.0, blue: 46/255.0, alpha: 0.9).cgColor
        let colorBottom = UIColor(red: 0/255.0, green: 0/255.0, blue: 0/255.0, alpha: 0.48).cgColor
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [colorTop, colorBottom]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.frame = self.bounds
        gradientLayer.name = "callingLayer"
        self.layer.insertSublayer(gradientLayer, at:0)
    }
}
