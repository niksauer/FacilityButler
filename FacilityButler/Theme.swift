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
    
    var barStyle: UIStatusBarStyle {
        switch self {
        case .Default:
            return .default
        case .Dark:
            log.debug("dark tab")
            return .lightContent
        }
    }
    var textColor: UIColor {
        switch self {
        case .Default:
            return .black
        case .Dark:
            return .white
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
    static func applyTheme(theme: Theme) {
        // 1
        UserDefaults.standard.setValue(theme.rawValue, forKey: SelectedThemeKey)
        UserDefaults.standard.synchronize()
        
        // 2
        let sharedApplication = UIApplication.shared
        sharedApplication.delegate?.window??.tintColor = theme.mainColor
        let view = UIView.appearance()
        view.backgroundColor = theme.backgroundColor
        
    
    }
}
