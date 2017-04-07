//
//  PageContentController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 07.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class PageContentController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    
    // MARK: - Instance Properties
    var pageIndex: Int?
    var titleText: String!
    var imageName: String!

}
