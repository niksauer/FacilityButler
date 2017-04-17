//
//  Views.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 13.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class DrawToolBarView: UIView { }

class FloorPlanView: UIView { }

class AccessoryButton: UIButton {
    let identifier: String
    let category: String
    var isOn = false
    let delegate: AccessoryButtonDelegate!
    
    let statePictures = [
        HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "lightbulb_off.png"), #imageLiteral(resourceName: "lightbulb_on.png")]
    ]
    
    required init(identifier: String, category: String, delegate: AccessoryButtonDelegate) {
        self.identifier = identifier
        self.category = category
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        let image = statePictures[category]![0]
        setImage(image, for: .normal)
        addTarget(self, action: #selector(tappedAccessoryButton), for: .touchUpInside)
        frame = CGRect(x: 100, y: 100, width: image.size.width/3, height: image.size.height/3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func toggleState() {
        if isOn {
            setImage(statePictures[category]![0], for: .normal)
            isOn = false
        } else {
            setImage(statePictures[category]![1], for: .normal)
            isOn = true
        }
    }
    
    func tappedAccessoryButton() {
        delegate.didAttempToToggleState(sender: self)
    }
}

protocol AccessoryButtonDelegate {
    func didAttempToToggleState(sender: AccessoryButton)
}
