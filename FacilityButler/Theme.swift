//
//  Theme.swift
//  FacilityButler
//
//  Created by Maik Baumgartner on 08.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

struct Color {
    static let whiteLight = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let whiteDark = UIColor(red: 246.0/255.0, green: 245.0/255.0, blue: 247.0/255.0, alpha: 1.0)
    static let white = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    static let orange = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)
    static let grey = UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255.0, alpha: 1.0)
    static let blackLight = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 29.0/255.0, alpha: 1.0)
    static let blackDark = UIColor(red: 15.0/255.0, green: 15.0/255.0, blue: 15.0/255.0, alpha: 1.0)
    static let blue = UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
}

enum Theme: Int {
    case Light, Dark
    
    var actionTintColor: UIColor {
        switch self {
        case .Light:
            return Color.blue
        case .Dark:
            return Color.orange
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .Light:
            return Color.whiteDark
        case .Dark:
            return Color.blackLight
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Light:
            return Color.white
        case .Dark:
            return Color.blackLight
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .Light:
            return Color.blackDark
        case .Dark:
            return Color.white
        }
    }
    
    var contentBackground: UIColor {
        switch self {
        case .Light:
            return Color.whiteLight
        case .Dark:
            return Color.grey
        }
    }
    
    var strokeColor: UIColor {
        switch self {
        case .Light:
            return Color.blackDark
        case .Dark:
            return Color.white
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

    var activityIndicatorStyle: UIActivityIndicatorViewStyle {
        switch self {
        case .Light:
            return .gray
        case .Dark:
            return .white
        }
    }
}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: PropertyKey.currentTheme)) as? Int {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Light
        }
    }
    
    static func setTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.info("Set \(theme) theme for next application launch")
    }
    
    static func applyTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.debug("Applied \(theme) theme")
        
        // only apply dark theme, otherwise use system defaults
        guard theme == .Dark else {
            return
        }
        
        /* does not need window reload > can be changed on the fly */
        // text
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.actionTintColor
        
        /* needs window reload */
        let labelProxy = UILabel.appearance()
        labelProxy.textColor = theme.textColor
        
        let barButtonProxy = UIBarButtonItem.appearance()
        barButtonProxy.tintColor = theme.actionTintColor
        
//        let switchProxy = UISwitch.appearance()
//        switchProxy.onTintColor = theme.actionTintColor
        
        // navigation bar + toolbar
        let navigationBarProxy = UINavigationBar.appearance()
        navigationBarProxy.barStyle = theme.barStyle
        navigationBarProxy.barTintColor = theme.barTintColor
        
        let toolbarProxy = UIToolbar.appearance()
        toolbarProxy.barStyle = theme.barStyle
        toolbarProxy.barTintColor = theme.barTintColor
    
        // content background
        let tableCellProxy = UITableViewCell.appearance()
        tableCellProxy.backgroundColor = theme.contentBackground
        
        let drawToolBarViewProxy = DrawToolBarView.appearance()
        drawToolBarViewProxy.backgroundColor = theme.contentBackground
        
        // background
        let tableViewProxy = UITableView.appearance()
        tableViewProxy.backgroundColor = theme.backgroundColor
        
        let drawViewProxy = DrawView.appearance()
        drawViewProxy.backgroundColor = theme.backgroundColor
        
        let floorPlanViewProxy = FloorPlanView.appearance()
        floorPlanViewProxy.backgroundColor = theme.backgroundColor
    }
}
