//
//  SettingsController.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 04.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class SettingsController: UITableViewController, HMHomeManagerDelegate {

    // MARK: - Instance Properties
    let list = SettingsList()
    
    // MARK: - Initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        list.homeBrowser.delegate = self
        navigationItem.rightBarButtonItem = editButtonItem
    }

    // MARK: - Home Manager Delegate
    func homeManagerDidUpdateHomes(_ manager: HMHomeManager) {
        if !(manager.homes.isEmpty) {
            let sectionIndex = list.sectionTitles.index(of: list.homeSection)!
            var rowIndex = 0
            
            for home in manager.homes {
                list.homes.append(home)
                rowIndex = list.homes.endIndex
                tableView.insertRows(at: [IndexPath(row: rowIndex, section: sectionIndex)], with: .automatic)
            }
        }
    }
    
    // MARK: - Table View Controller
    override func numberOfSections(in tableView: UITableView) -> Int {
        return list.sectionTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let homeSectionIndex = list.sectionTitles.index(of: list.homeSection), homeSectionIndex == section {
            return (list.homes.count+1)
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionIndex = indexPath.section
        let rowIndex = indexPath.row
        let cell: UITableViewCell
        
        if let homeSectionIndex = list.sectionTitles.index(of: list.homeSection), homeSectionIndex == sectionIndex {
            if rowIndex == 0 {
                cell = tableView.dequeueReusableCell(withIdentifier: "addHomeUITableViewCell", for: indexPath)
            } else {
                let home = list.homes[rowIndex-1]
                cell = tableView.dequeueReusableCell(withIdentifier: "homeUITableViewCell", for: indexPath)
                
                cell.textLabel?.text = home.name
                cell.detailTextLabel?.text = home.isPrimary ? "Primary home" : ""
            }
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "settingUITableViewCell", for: indexPath)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let homeSectionIndex = list.sectionTitles.index(of: list.homeSection)!
        
        if homeSectionIndex == indexPath.section, indexPath.row != 0 {
            return true
        } else {
            return false
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return list.sectionTitles[section]
    }
    
    /*
     
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
