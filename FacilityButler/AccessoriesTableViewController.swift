//
//  AddAccessoryTableViewController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 24.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit
import os.log

class AccessoriesTableViewController: UITableViewController, HMAccessoryBrowserDelegate, HMHomeManagerDelegate {
    // MARK: - Outlets
    @IBOutlet var table: UITableView!
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    // MARK: - Properties
    let list = AccessoryList()
    let home = Home()
    
    // MARK: - Navigation
    // INFO: - atomically dismisses modally presented view (self)
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        list.stopAccessoryScan()
        os_log("Canceled to add accessory", log: OSLog.default, type: .debug)
        dismiss(animated: true, completion: nil)
    }
    
    // INFO: - adds selected (un)configured accessory to home, i.e. makes it placeable on floor plan
    @IBAction func save(_ sender: UIBarButtonItem) {
        home.saveAccessory(accessory: list.selection.accessory, completion: {
            self.list.stopAccessoryScan()
            self.transitionToFloorPlan()
        })
    }
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        home.manager.delegate = self
        list.accessoryBrowser.delegate = self
        
        navigationItem.rightBarButtonItem = editButtonItem
        
        list.startAccessoryScan()
    }
    
    // MARK: - Private Actions
    // INFO: - unwinds to floor plan controller, to be used in completion closure
    private func transitionToFloorPlan() {
        performSegue(withIdentifier: "unwindToFloorPlan", sender: self)
    }
    
    // MARK: - Accessory Browser Delegate
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        let sectionIndex = list.sectionTitles.index(of: list.unconfiguredSection)!
        let rowIndex = list.insertIntoSection(sectionIndex, accessory: accessory)
        tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
        os_log("Found accessory: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        let sectionIndex = list.sectionTitles.index(of: list.unconfiguredSection)!
        let rowIndex = list.removeFromSection(sectionIndex, accessory: accessory)
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
        os_log("Lost accessory: %@", log: OSLog.default, type: .debug, accessory as CVarArg)
    }
    
    // MARK: - Home Manager Delegate
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        home.setCurrentHome(manager.primaryHome, completion: {
            let sectionIndex = list.sectionTitles.index(of: list.configuredSection)!
            
            for accessory in home.currentHome!.accessories {
                let rowIndex = list.insertIntoSection(sectionIndex, accessory: accessory)
                tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
            }
            
            if list.accessories[sectionIndex].count == 0 {
                editButtonItem.isEnabled = false
            } else {
                editButtonItem.isEnabled = true
            }
        })
    }
    
    // MARK: - Table View Controller
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.sectionTitles.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list.sectionTitles[section]
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.accessories[section].count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier (as specified in IB)
        // returns new UITableViewCell if none can be found
        let cell = tableView.dequeueReusableCell(withIdentifier: "accessoryUITableViewCell", for: indexPath)
        let accessory = list.accessories[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = accessory.name
        cell.detailTextLabel?.text = accessory.category.localizedDescription
        
        return cell
    }
    
    // INFO: - (un)marks single selected row
    override func tableView(_ tableView: UITableView, didSelectRowAt newIndexPath: IndexPath) {
        if let oldIndexPath = list.selection.indexPath, newIndexPath == oldIndexPath {
            let cell = tableView.cellForRow(at: oldIndexPath)!
            
            switch cell.accessoryType {
            case .none:
                cell.accessoryType = .checkmark
                list.selection.indexPath = oldIndexPath
                list.selection.accessory = list.accessories[oldIndexPath.section][oldIndexPath.row]
                os_log("Selected accessory: %@", log: OSLog.default, type: .debug, list.selection.accessory!)
            case .checkmark:
                cell.accessoryType = .none
                os_log("Deselected accessory: %@", log: OSLog.default, type: .debug, list.selection.accessory!)
                list.selection.accessory = nil
                list.selection.indexPath = nil
            default:
                break
            }
        } else {
            if let oldIndex = list.selection.indexPath {
                os_log("Deselected accessory: %@", log: OSLog.default, type: .debug, list.selection.accessory!)
                tableView.cellForRow(at: oldIndex)!.accessoryType = .none
            }
            
            list.selection.indexPath = newIndexPath
            list.selection.accessory = list.accessories[newIndexPath.section][newIndexPath.row]
            tableView.cellForRow(at: newIndexPath)!.accessoryType = .checkmark
            os_log("Selected accessory: %@", log: OSLog.default, type: .debug, list.selection.accessory!)
        }
    }
    
    // INFO: - allows conditional editing of the table
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let section = list.sectionTitles.index(of: list.configuredSection), indexPath.section == section {
            return true
        } else {
            return false
        }
    }
    
    // INFO: - removes accessory from home
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let accessory = list.accessories[indexPath.section][indexPath.row]
            
            let title = "Delete \(accessory.name)?"
            let message = "Are you sure you want to delete this accessory?"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.list.removeFromSection(indexPath.section, accessory: accessory)
                self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                self.home.deleteAccessory(accessory: accessory, completion: {
                    if self.list.accessories[indexPath.section].count == 0 {
                        self.editButtonItem.isEnabled = false
                    } else {
                        self.editButtonItem.isEnabled = true
                    }
                    
                    self.setEditing(false, animated: true)
                })
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
