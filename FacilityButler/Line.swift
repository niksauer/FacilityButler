//
//  Line.swift
//  FacilityButler
//
//  Created by Malcolm Malam on 06.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class Line: NSObject, NSCoding {
    
    // MARK: - Instance Properties
    var start: CGPoint
    var end: CGPoint
    
    // MARK: - Initialization
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    // MARK: - NSCoding Protocol
    required init?(coder aDecoder: NSCoder) {
        if let start = aDecoder.decodeObject(forKey: PropertyKey.lineStart) as? CGPoint, let end = aDecoder.decodeObject(forKey: PropertyKey.lineEnd) as? CGPoint {
            self.start = start
            self.end = end
        } else {
            return nil
        }
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(start, forKey: PropertyKey.lineStart)
        aCoder.encode(end, forKey: PropertyKey.lineEnd)
    }
}
