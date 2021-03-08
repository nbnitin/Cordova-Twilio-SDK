//
//  CircleButton.swift
//  tt
//
//  Created by Nitin Bhatia on 22/07/20.
//  Copyright © 2020 Nitin. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class CircleButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 3.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    override func awakeFromNib() {
        self.setupView()
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        self.setupView()
    }
    
    func setupView() {
        self.imageView?.contentMode = .scaleAspectFit
        self.layer.cornerRadius = self.frame.width / 2
    }
}
