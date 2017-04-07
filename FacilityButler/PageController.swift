//
//  PageController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 07.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

class PageController: UIPageViewController, UIPageViewControllerDataSource {

    let pageTitles = [ "Title1", "Title2" ]
    let images = [ "image1", "image2" ]
    var count = 0
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        return nil
    }
}
