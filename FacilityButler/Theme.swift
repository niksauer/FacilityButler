//
//  Theme.swift
//  FacilityButler
//
//  Created by Maik Baumgartner on 08.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

enum Theme: Int {
    case Light, Dark
    
    var mainColor: UIColor {
        switch self {
        case .Light:
            return UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 255.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Light:
            return UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .Light:
            return UIColor(red: 15.0/255.0, green: 15.0/255.0, blue: 15.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
        }
    }
    
    // default: translucency = true
    var barStyle: UIBarStyle {
        switch self {
        case .Light:
            return .default
        case .Dark:
            return .black
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .Light:
            return UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        }
    }
    
    var activityIndicatorStyle: UIActivityIndicatorViewStyle {
        switch self {
        case .Light:
            return .gray
        case .Dark:
            return .white
        }
    }
    
    var cellBackground: UIColor {
        switch self {
        case .Light:
            return UIColor.white
        case .Dark:
            return UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255.0, alpha: 1.0)
        }
    }
    
    var toolBarColor: UIColor {
        switch self {
        case .Light:
            return UIColor.white
        case .Dark:
            return UIColor(red: 61.0/255, green: 61.0/255, blue: 62.0/255.0, alpha: 1.0)
        }
    }
    
    /*
    var navbarEffect: UIVisualEffectView {
        switch self {
        case .Light:
            return UIVisualEffectView(effect: UIBlurEffect(style: .light))
        case .Dark:
            return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        }
    }
    */
    
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: PropertyKey.currentTheme)) as? Int {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Light
        }
    }
    
    static func applyTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.info("Applied \(theme) theme")
        
        guard theme == .Dark else {
            return
        }
        
        // does not need window reload > can be changed on the fly
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        // needs window reload
        let navigationBarProxy = UINavigationBar.appearance()
        navigationBarProxy.barStyle = theme.barStyle
        navigationBarProxy.barTintColor = theme.barTintColor
        
        let toolbarProxy = UIToolbar.appearance()
        toolbarProxy.barStyle = theme.barStyle
        toolbarProxy.barTintColor = theme.barTintColor
        
        let barButtonProxy = UIBarButtonItem.appearance()
        barButtonProxy.tintColor = theme.mainColor
    
        let labelProxy = UILabel.appearance()
        labelProxy.textColor = theme.textColor
    
        let tableProxy = UITableView.appearance()
        tableProxy.backgroundColor = theme.backgroundColor
        
        let tableCellProxy = UITableViewCell.appearance()
        tableCellProxy.backgroundColor = theme.cellBackground
        
        let drawToolProxy = DrawView.appearance()
        drawToolProxy.backgroundColor = theme.backgroundColor
        
        let drawToolBarViewProxy = DrawToolBarView.appearance()
        drawToolBarViewProxy.backgroundColor = theme.cellBackground
        
        let floorPlanViewProxy = FloorPlanView.appearance()
        floorPlanViewProxy.backgroundColor = theme.backgroundColor
        
        // cannot be set
        let activityIndicatorProxy = UIActivityIndicatorView.appearance()
        activityIndicatorProxy.activityIndicatorViewStyle = .whiteLarge
    
        
//        navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)]
//        navBar.shadowImage = UIImage()
//        
//        let switches = UISwitch.appearance()
//        switches.onTintColor = theme.mainColor
//        
//        let bounds = navigationBarProxy.bounds as CGRect!
//        let visualEffectView = theme.navbarEffect
//        visualEffectView.frame = bounds!
//        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        navigationBarProxy.addSubview(visualEffectView)
//        navigationBarProxy.sendSubview(toBack: visualEffectView)
        
        
    }
}
