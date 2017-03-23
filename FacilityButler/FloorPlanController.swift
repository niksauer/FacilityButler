//
//  ViewController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 23.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class FloorPlanController: UIViewController, HMAccessoryBrowserDelegate {
    let model = FloorPlanModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.accessoryBrowser.delegate = self
    }
    
    @IBAction func setupNewAccessory(_ sender: UIButton) {
        model.findNewAccessory()
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        // stop network scan, as accessory has been found
        browser.stopSearchingForNewAccessories()
        print("stopped network scan")
    }
}
