//
//  Theme.swift
//  FacilityButler
//
//  Created by Maik Baumgartner on 08.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
// MARK: - Color Definition
struct Color {
    static let purple = UIColor(red: 121/255.0, green: 132/255.0, blue: 215/255.0, alpha: 1.0)
    static let orange = UIColor(red: 254.0/255.0, green: 149.0/255.0, blue: 0.0/255.0, alpha: 1.0)

    static let white = UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    static let whiteDark = UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)
    
    static let grey = UIColor(red: 127.0/255, green: 127.0/255, blue: 127.0/255.0, alpha: 1.0)
    static let greyDark = UIColor(red: 45.0/255, green: 45.0/255, blue: 45.0/255.0, alpha: 1.0)
    
    static let black = UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 29.0/255.0, alpha: 1.0)
}

// MARK: - Theme Definition
// INFO: - Add new cases to enumeration to add additional themes
enum Theme: Int {
    case Light, Dark
    
    var actionTintColor: UIColor {
        switch self {
        case .Light:
            return Color.purple
        case .Dark:
            return Color.orange
        }
    }
    
    var barTintColor: UIColor {
        switch self {
        case .Light:
            return Color.white
        case .Dark:
            return Color.greyDark
        }
    }
    
    var backgroundColor: UIColor {
        switch self {
        case .Light:
            return Color.whiteDark
        case .Dark:
            return Color.black
        }
    }
    
    var textColor: UIColor {
        switch self {
        case .Light:
            return Color.black
        case .Dark:
            return Color.white
        }
    }
    
    var secondaryTextColor: UIColor {
        switch self {
        case .Light:
            return Color.greyDark
        case .Dark:
            return Color.grey
        }
    }
    
    var contentBackground: UIColor {
        return self.barTintColor
    }
    
    var strokeColor: UIColor {
        switch self {
        case .Light:
            return Color.black
        case .Dark:
            return Color.white
        }
    }

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
// MARK: - Theme Functions
struct ThemeManager {
    // INFO: - Function to return the currently set theme
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: PropertyKey.currentTheme)) as? Int {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Light
        }
    }
    
    // INFO: - Function to set the selected theme as new default
    static func setTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.info("Set \(theme) theme for next application launch")
    }
    
    // INFO: - Function to apply the selected theme to the appearance
    static func applyTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.debug("Applied \(theme) theme")
        
        // global
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.actionTintColor
        
        let labelProxy = UILabel.appearance()
        labelProxy.textColor = theme.textColor
        
        let barButtonProxy = UIBarButtonItem.appearance()
        barButtonProxy.tintColor = theme.actionTintColor
        
        let textViewProxy = UITextView.appearance()
        textViewProxy.backgroundColor = theme.backgroundColor
        textViewProxy.textColor = theme.textColor
        
        /* FloorPlan Controller */
        // header
        let navigationBarProxy = UINavigationBar.appearance()
        navigationBarProxy.barStyle = theme.barStyle
        navigationBarProxy.barTintColor = theme.barTintColor
        navigationBarProxy.isTranslucent = false
        navigationBarProxy.shadowImage = UIImage()
        navigationBarProxy.setBackgroundImage(UIImage(), for: .default)
        
        let drawtoolBarViewProxy = DrawToolbarView.appearance()
        drawtoolBarViewProxy.backgroundColor = theme.barTintColor
        
        // footer
        let toolbarProxy = UIToolbar.appearance()
        toolbarProxy.barStyle = theme.barStyle
        toolbarProxy.barTintColor = theme.barTintColor
        toolbarProxy.isTranslucent = false        
        
        // background
        let tableViewProxy = UITableView.appearance()
        tableViewProxy.backgroundColor = theme.backgroundColor
        
        let tableCellProxy = UITableViewCell.appearance()
        tableCellProxy.backgroundColor = theme.contentBackground
        
        let drawViewProxy = DrawView.appearance()
        drawViewProxy.backgroundColor = theme.backgroundColor
        
        let floorPlanViewProxy = FloorPlanView.appearance()
        floorPlanViewProxy.backgroundColor = theme.backgroundColor
        
    }
}

