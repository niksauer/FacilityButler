//
//  LogDataController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 10.05.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class LogDataController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var logTextView: UITextView!
    
    // MARK: - Instance Properties
    let logData: String! = nil
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let path = CachesDirectory.appendingPathComponent("swiftybeaver.log")
        log.debug(path);
    }
    
}
