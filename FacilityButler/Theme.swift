//
//  Theme.swift
//  FacilityButler
//
//  Created by Maik Baumgartner on 08.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit

let SelectedThemeKey = "SelectedTheme"

enum Theme: Int {
    case Default, Dark
    
    var mainColor: UIColor {
        switch self {
        case .Default:
            return .blue
        case .Dark:
            return UIColor(red: 242.0/255.0, green: 101.0/255.0, blue: 34.0/255.0, alpha: 1.0)
        }
    }
    var backgroundColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        case .Dark:
        return UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        }
    }
    
    var barStyle: UIBarStyle {
        switch self {
        case .Default:
            return UIBarStyle.default
        case .Dark:
            log.debug("dark tab")
            return UIBarStyle.black
        }
    }
    var textColor: UIColor {
        switch self {
        case .Default:
            return UIColor(red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0)
        case .Dark:
            return UIColor(red: 255.0/255.0, green: 255.0/255.0, blue: 255.0/255.0, alpha: 1.0)
        }
    }
    
    

}

struct ThemeManager {
    static func currentTheme() -> Theme {
        if let storedTheme = (UserDefaults.standard.value(forKey: SelectedThemeKey) as AnyObject).integerValue {
            return Theme(rawValue: storedTheme)!
        } else {
            return .Default
        }
    }
    static func applyTheme(theme: Theme){
        // 1
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        // 2
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        let tableView = UITableView.appearance()
        tableView.backgroundColor = theme.backgroundColor
        let tableViewCell = UITableViewCell.appearance()
        tableViewCell.backgroundColor = theme.backgroundColor
        let labelView = UILabel.appearance()
        labelView.textColor = theme.textColor
        let navBar = UINavigationBar.appearance()
        navBar.barTintColor = theme.backgroundColor
        navBar.titleTextAttributes = [NSForegroundColorAttributeName: theme.textColor]
        let tabBar = UITabBar.appearance()
        tabBar.barStyle = theme.barStyle
        UINavigationBar.appearance().barTintColor = theme.backgroundColor
        
        
    }
}
