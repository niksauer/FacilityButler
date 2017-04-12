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
    var barStyle: UIBarStyle {
        switch self {
        case .Light:
            return UIBarStyle.default
        case.Dark:
            return UIBarStyle.black
        }
    
    }
    var statusBarStyle: UIStatusBarStyle {
        switch self {
        case .Light:
            return UIStatusBarStyle.default
        case .Dark:
            return UIStatusBarStyle.lightContent
        }
    }
        var navBar: UIColor {
        switch self {
        case .Light:
            return UIColor(red: 0.0/255.0, green: 122.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 28.0/255.0, green: 28.0/255.0, blue: 29.0/255.0, alpha: 1.0)
        }
    }
    
    var navbarEffect: UIVisualEffectView {
        switch self {
            case .Light:
                return UIVisualEffectView(effect: UIBlurEffect(style: .light))
            case .Dark:
                return UIVisualEffectView(effect: UIBlurEffect(style: .dark))
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
    
    static func applyTheme(_ theme: Theme) {
        UserDefaults.standard.setValue(theme.rawValue, forKey: PropertyKey.currentTheme)
        UserDefaults.standard.synchronize()
        log.info("Set current theme to \(theme)")
        
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        
        // tables
        let tableView = UITableView.appearance()
        tableView.backgroundColor = theme.backgroundColor
        
        let tableViewCell = UITableViewCell.appearance()
        tableViewCell.backgroundColor = theme.backgroundColor
        
        let labelView = UILabel.appearance()
        labelView.textColor = theme.textColor
        
        let navBar = UINavigationBar.appearance()
        //navBar.barTintColor = theme.navBar
        //navBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor(red: 241.0/255.0, green: 241.0/255.0, blue: 241.0/255.0, alpha: 1.0)]
        //navBar.isTranslucent = true
        //navBar.shadowImage = UIImage()
        
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = theme.barStyle
        
        let switches = UISwitch.appearance()
        switches.onTintColor = theme.mainColor
        sharedApplication.statusBarStyle = theme.statusBarStyle
        
        let bounds = navBar.bounds as CGRect!
        let visualEffectView = theme.navbarEffect
        visualEffectView.frame = bounds!
        visualEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        navBar.addSubview(visualEffectView)
        navBar.sendSubview(toBack: visualEffectView)
    }
}
