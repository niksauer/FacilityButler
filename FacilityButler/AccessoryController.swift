//
//  AccessoryListController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 24.03.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class AccessoryController: UITableViewController, HMAccessoryBrowserDelegate {
    
    // MARK: - Instance Properties
    // TODO: apply DIP principle
    let list = AccessoryList()
    var model: FacilityButler!
   
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        list.accessoryBrowser.delegate = self
        list.startAccessoryScan()
        navigationItem.rightBarButtonItem = editButtonItem
        
        insertUnplacedFacilityAccessories()
    }
    
    // MARK: - Navigation
    /// atomically dismisses modally presented view (self)
    @IBAction func cancel(_ sender: UIBarButtonItem) {
        list.stopAccessoryScan()
        log.debug("canceled to add accessory")
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private Actions
    /// unwinds to floor plan controller, to be used in completion closure
    private func transitionToFloorPlan() {
        performSegue(withIdentifier: "unwindToFloorPlan", sender: self)
    }
    
    private func insertUnplacedFacilityAccessories() {
        let sectionIndex = list.sectionTitles.index(of: list.configuredSection)!
        let placedAccessories = model.facility.getPlacedAccessoires()
        
        for accessory in model.instance.accessories {
            if placedAccessories.contains(accessory.uniqueIdentifier.uuidString) == false {
                let rowIndex = list.insertIntoSection(sectionIndex, accessory: accessory)
                tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
            }
        }
        
        if list.accessories[sectionIndex].count == 0 {
            editButtonItem.isEnabled = false
        } else {
            editButtonItem.isEnabled = true
        }
    }
    
    // MARK: - Accessory Browser Delegate
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didFindNewAccessory accessory: HMAccessory) {
        let sectionIndex = list.sectionTitles.index(of: list.unconfiguredSection)!
        let rowIndex = list.insertIntoSection(sectionIndex, accessory: accessory)
        tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
        log.debug("found accessory \(accessory)")
    }
    
    func accessoryBrowser(_ browser: HMAccessoryBrowser, didRemoveNewAccessory accessory: HMAccessory) {
        let sectionIndex = list.sectionTitles.index(of: list.unconfiguredSection)!
        let rowIndex = list.removeFromSection(sectionIndex, accessory: accessory)
        tableView.deleteRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
        log.debug("lost accessory \(accessory)")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "accessoryUITableViewCell", for: indexPath)
        let accessory = list.accessories[indexPath.section][indexPath.row]
        
        cell.textLabel?.text = accessory.name
        cell.detailTextLabel?.text = accessory.category.localizedDescription
        
        return cell
    }
    
    /// adds selected (un)configured accessory to facility, i.e. hands it off to floor plan
    override func tableView(_ tableView: UITableView, didSelectRowAt newIndexPath: IndexPath) {
        let accessory = list.accessories[newIndexPath.section][newIndexPath.row]

        model.saveAccessory(accessory, completion: { (error) in
            if !(presentError(viewController: self, error: error)) {
                self.list.stopAccessoryScan()
                self.transitionToFloorPlan()
            }
        })
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let section = list.sectionTitles.index(of: list.configuredSection), indexPath.section == section {
            return true
        } else {
            return false
        }
    }
    
    /// removes accessory from facility
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let accessory = list.accessories[indexPath.section][indexPath.row]
            
            let title = "\(accessory.name)"
            let message = "Are you sure you want to delete this accessory?"
            
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) -> Void in
                self.list.removeFromSection(indexPath.section, accessory: accessory)
                self.tableView.deleteRows(at: [IndexPath(row: indexPath.row, section: indexPath.section)], with: .automatic)
                self.model.deleteAccessory(accessory, completion: { (error) in
                    if !(presentError(viewController: self, error: error)) {
                        if self.list.accessories[indexPath.section].count == 0 {
                            self.editButtonItem.isEnabled = false
                        } else {
                            self.editButtonItem.isEnabled = true
                        }
                        
                        self.setEditing(false, animated: true)
                    }
                })
            })
            
            alertController.addAction(cancelAction)
            alertController.addAction(deleteAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
}
