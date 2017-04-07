//
//  Line.swift
//  FacilityButler
//
//  Created by Malcolm Malam on 06.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class Line {
    
    // MARK: - Instance Properties
    var start: CGPoint
    var end: CGPoint
    
    // MARK: - Initialization
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
}
