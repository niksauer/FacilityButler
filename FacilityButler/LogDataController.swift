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
    let logDataPath = CachesDirectory.appendingPathComponent("swiftybeaver.log")
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let logData = try String(contentsOf: logDataPath, encoding: .utf8)
            logTextView.text = logData
        } catch let error {
            log.debug(error)
        }
    }
    
}
