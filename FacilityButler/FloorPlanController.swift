//
//  ViewController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController {
    let model = FloorPlanModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // discover new accessory
    var accessoires = [HMAccessory]()
    var scanActive = false
    
    @IBAction func setupNewAccessory(_ sender: UIButton) {
        if !scanActive {
            model.startAccessoryScan()
        } else {
            model.stopAccessoryScan()
        }
        
        scanActive = !scanActive
    }
    
    
}
