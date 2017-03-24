//
//  AddAccessoryController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 24.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class AddAccessoryController: UITableViewController, HMAccessoryBrowserDelegate {
    let model = FloorPlanModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        model.accessoryBrowser.delegate = self
        model.startAccessoryScan()
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        // add newest found item to table view
//        accessoires.append(accessory)
        print(accessory)
    }
}
