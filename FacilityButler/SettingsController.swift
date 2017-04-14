//
//  SettingsController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 04.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class SettingsController: UITableViewController {
    
    // MARK: - Outlets
    weak var createAlertAction: UIAlertAction!
    
    // MARK: - Instance Properties
    // TODO: apply DIP principle
    let list = SettingsList()
    var model: FacilityButler!
    
    // MARK: - Actions
    /// creates facility from given user input
    func addHome() {
        let title = NSLocalizedString("New Facility", comment: "alert box title to add new facility")
        let message = NSLocalizedString("Please enter a name for this facility.", comment: "alert box message to add new facility")
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addTextField(configurationHandler: { (textField) in
            textField.addTarget(self, action: #selector(self.textChanged(_:)), for: .editingChanged)
        })
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "alert box dismiss"), style: .cancel, handler: nil)
        let createAction = UIAlertAction(title: NSLocalizedString("Create", comment: "alert box accept"), style: .default, handler: { (action) -> Void in
            let facilityName = (alertController.textFields![0].text)!
            self.model.createFacility(name: facilityName, completion: { (error) in
                if !(presentError(viewController: self, error: error)) {
                    let sectionIndex = self.list.sectionTitles.index(of: self.list.homeSection)!
                    let rowIndex = self.model.butler.homes.count
                    self.tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
                }
            })
        })
        
        createAction.isEnabled = false
        createAlertAction = createAction
        
        alertController.addAction(cancelAction)
        alertController.addAction(createAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    /// dis/enables create home alert action depending on input length
    /// - Parameter sender: textfield that receives input
    func textChanged(_ sender: UITextField) {
        createAlertAction?.isEnabled = ((sender.text?.utf16.count)! >= 1)
    }
    
    // MARK: - Table View Controller
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let homeSectionIndex = list.sectionTitles.index(of: list.homeSection), homeSectionIndex == section {
            return (model.butler.homes.count+1)
        } else {
            return list.settings.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        let cell: UITableViewCell
        
        if let homeSectionIndex = list.sectionTitles.index(of: list.homeSection), homeSectionIndex == sectionIndex {
            if indexPath.row == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "addHomeUITableViewCell", for: indexPath)
            } else {
                let home = model.butler.homes[rowIndex-1]
                
                cell = tableView.dequeueReusableCell(withIdentifier: "homeUITableViewCell", for: indexPath)
                cell.textLabel?.text = home.name
                
                if home.isPrimary {
                    list.primaryFacility = indexPath
                    cell.accessoryType = .checkmark
                    cell.detailTextLabel?.text = NSLocalizedString("Primary home", comment: "Primary home marker")
                }
            }
        } else {
            if rowIndex == 0 {
                // Dark Mode Cell
                cell = tableView.dequeueReusableCell(withIdentifier: "settingUITableViewCell", for: indexPath)
                cell.textLabel?.text = NSLocalizedString("Dark Mode", comment: "Label for dark mode switch")
                
                let darkModeSwitch = UISwitch()
                darkModeSwitch.addTarget(self, action: #selector(toggleDarkMode(_:)), for: .valueChanged)
                
                cell.accessoryView = darkModeSwitch
                
                switch ThemeManager.currentTheme() {
                case .Light:
                    enableSwitch.isOn = false
                case .Dark:
                    enableSwitch.isOn = true
                }
            case .DarkIcon:
                if #available(iOS 10.3, *) {
                    cell.textLabel?.text = "Dark App Icon"
                    enableSwitch.addTarget(self, action: #selector(toggleAppIcon(_:)), for: .valueChanged)
                    
                    if let isDarkIconSet = UserDefaults.standard.value(forKey: PropertyKey.darkIcon) as? Bool, isDarkIconSet == true {
                        enableSwitch.isOn = true
                    } else {
                        enableSwitch.isOn = false
                    }
                }
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if tableView.cellForRow(at: indexPath)?.reuseIdentifier == "homeUITableViewCell" {
            return true
        } else {
            return false
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list.sectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let home = model.butler.homes[indexPath.row-1]
            
            let title = "\(home.name)"
            let message = NSLocalizedString("Are you sure you want to delete this facility?", comment: "alert box message for deleting facility")
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: "alert box cancel button"), style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: "alert box delete button"), style: .destructive, handler: { (action) -> Void in
                self.model.deleteFacility(home: home, completion: { (error) in
                    if !(presentError(viewController: self, error: error)) {
                        self.tableView.reloadData()
                        
                        if self.model.butler.primaryHome == nil {
                            presentError(viewController: self, error: FacilityError.noFaciltiySet)
                        }
                    }
                })
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let identifier = (tableView.cellForRow(at: indexPath)?.reuseIdentifier)!
        
        switch identifier {
        case "homeUITableViewCell":
            let home = model.butler.homes[indexPath.row-1]
            
            do {
                try model.save()
            } catch {
                presentError(viewController: self, error: error)
            }
            
            model.setCurrentFacility(home: home, completion: { (error) in
                if !(presentError(viewController: self, error: error)) {
                    if let oldPrimaryIndexPath = self.list.primaryFacility, let oldPrimaryFacilityCell = tableView.cellForRow(at: oldPrimaryIndexPath) {
                        oldPrimaryFacilityCell.accessoryType = .none
                        oldPrimaryFacilityCell.detailTextLabel?.text = ""
                    }
                    
                    self.list.primaryFacility = indexPath
                    let newPrimaryFacilityCell = tableView.cellForRow(at: indexPath)
                    newPrimaryFacilityCell?.accessoryType = .checkmark
                    newPrimaryFacilityCell?.detailTextLabel?.text = NSLocalizedString("Primary Facility", comment: "primary facility marker")
                }
            })
        case "addHomeUITableViewCell":
            addHome()
            break
        default:
            break
        }
        
    }
    
    // MARK: - Settings Target Actions
    func toggleDarkMode(_ sender: UISwitch) {
        if sender.isOn {
            ThemeManager.setTheme(Theme.Dark)
        } else {
            ThemeManager.setTheme(Theme.Light)
        }
        
        let alert = UIAlertController(title: NSLocalizedString("Info", comment: "information alert box title"), message: NSLocalizedString("Please force quit the app to see theme changes.", comment: "alert box message after changing themes"), preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: NSLocalizedString("Dismiss", comment: "alert box dismiss button"), style: .default, handler: nil)
        alert.addAction(dismissAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @available(iOS 10.3, *)
    func toggleAppIcon(_ sender: UISwitch) {
        if sender.isOn {
            UIApplication.shared.setAlternateIconName("darkAppIcon", completionHandler: { (error) in
                if let errorMessage = error {
                    log.error(errorMessage)
                    sender.isOn = false
                } else {
                    UserDefaults.standard.setValue(sender.isOn, forKey: PropertyKey.darkIcon)
                    UserDefaults.standard.synchronize()
                    log.debug("Set dark app icon")
                }
            })
        } else {
            UIApplication.shared.setAlternateIconName(nil, completionHandler: { (error) in
                if let errorMessage = error {
                    log.error(errorMessage)
                    sender.isOn = false
                } else {
                    UserDefaults.standard.setValue(sender.isOn, forKey: PropertyKey.darkIcon)
                    UserDefaults.standard.synchronize()
                    log.debug("Set dark app icon")
                }
            })
        }
    }

}

