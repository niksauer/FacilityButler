//
//  AccessoryButton.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 18.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

protocol AccessoryButtonDelegate {
    func shouldPresentError(_ error: Error)
    func shouldUnblockAccessory(_ accessory: HMAccessory, completion: @escaping (() -> Void))
}

class AccessoryButton: UIButton, HMAccessoryDelegate {
    
    // MARK: Instance Properties
    let accessory: HMAccessory
    var position: CGPoint
    let delegate: AccessoryButtonDelegate
    var searchIndicator: UIActivityIndicatorView?
    
    var primaryCharacteristicSet = false {
        didSet {
            setImage(AccessoryButton.getBackgroundImage(for: accessory, state: primaryCharacteristicSet), for: .normal)
        }
    }
    
    var reachable = false {
        didSet {
            if !reachable {
                primaryCharacteristicSet = false
                log.warning("Accessory \(accessory) is not reachable")
                
//                searchIndicator = UIActivityIndicatorView(activityIndicatorStyle: ThemeManager.currentTheme().activityIndicatorStyle)
//                searchIndicator?.startAnimating()
//                searchIndicator!.translatesAutoresizingMaskIntoConstraints = false
//                self.addSubview(searchIndicator!)
//                
//                let topConstraint = searchIndicator!.topAnchor.constraint(equalTo: self.topAnchor)
//                let rightConstraint = searchIndicator!.rightAnchor.constraint(equalTo: self.rightAnchor)
//                
//                topConstraint.isActive = true
//                rightConstraint.isActive = true
            } else {
                log.info("Accessory \(accessory) is reachable")
                searchIndicator?.stopAnimating()
            }
        }
    }
    
    // MARK: Initializers
    required init(of accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        self.accessory = accessory
        self.position = position
        self.delegate = delegate
        
        super.init(frame: .zero)
        
        if accessory.category.categoryType.isEmpty {
            log.warning("No category specified for accessory \(accessory), assuming lightbulb")
        }
        
        accessory.delegate = self
        checkNetworkStatus()
        
        if accessory.isReachable {
            checkPrimaryCharacteristic()
            enablePrimaryCharacteristicNotifications()
        }
        
        if let image = AccessoryButton.getBackgroundImage(for: accessory, state: primaryCharacteristicSet) {
            setImage(image, for: .normal)
            frame = CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    func checkNetworkStatus() {
        if accessory.isReachable {
            if !(accessory.isBlocked) {
                reachable = true
            } else {
                delegate.shouldUnblockAccessory(accessory, completion: checkNetworkStatus)
            }
        } else {
            reachable = false
        }
    }
    
    func checkPrimaryCharacteristic() {
        preconditionFailure("This method must be overridden")
    }
    
    func enablePrimaryCharacteristicNotifications() {
        if let primaryCharacteristic = AccessoryButton.getPrimaryCharacteristic(of: accessory) {
            if !(primaryCharacteristic.isNotificationEnabled) {
                primaryCharacteristic.enableNotification(true, completionHandler: { (errorMessage) in
                    if let error = errorMessage {
                        log.error("Failed to enable notifications for characteristic \(primaryCharacteristic.localizedDescription) of accessory \(self.accessory) due to error: \(error)")
                    } else {
                        log.debug("Enabled notifications for characteristic \(primaryCharacteristic.localizedDescription) of accessory \(self.accessory)")
                    }
                })
            }
        } else {
            log.warning("No primary characteristic associated with accessory \(accessory)")
        }
    }
    
    // MARK: Class Functions
    static let statePicturesLight = [
        HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "lightbulb_off"), #imageLiteral(resourceName: "lightbulb_on")],
        HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "bridge_off"), #imageLiteral(resourceName: "bridge_on")],
        HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "lightbulb_off"), #imageLiteral(resourceName: "lightbulb_on")]
    ]
    
    static let statePicturesDark = [
        HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")],
        HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "dark_bridge_off"), #imageLiteral(resourceName: "dark_bridge_on")],
        HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")]
    ]
    
    static func getBackgroundImage(for accessory: HMAccessory, state: Bool) -> UIImage? {
        var category = accessory.category.categoryType
        
        if category.isEmpty {
            category = HMAccessoryCategoryTypeOther
        }
        
        let index = state ? 1 : 0
        let image: UIImage?
        
        switch ThemeManager.currentTheme() {
        case .Light:
            image = statePicturesLight[category]?[index]
        case .Dark:
            image = statePicturesDark[category]?[index]
        }
        
        if let background = image {
            return background
        } else {
            return nil
        }
    }
    
    static func getPrimaryCharacteristic(of accessory: HMAccessory) -> HMCharacteristic? {
        let primaryFunctions = [
            HMAccessoryCategoryTypeLightbulb : [HMServiceTypeLightbulb, HMCharacteristicTypePowerState]
        ]
        
        var category = accessory.category.categoryType
        
        if category.isEmpty {
            //            log.warning("No category specified for accessory \(accessory), assuming lightbulb")
            category = HMAccessoryCategoryTypeLightbulb
        }
        
        if let primaryService = primaryFunctions[category]?[0], let primaryCharacteristic = primaryFunctions[category]?[1], let service = accessory.services.first(where: { $0.serviceType == primaryService }), let characteristic = service.characteristics.first(where: { $0.characteristicType == primaryCharacteristic }) {
            return characteristic
        } else {
            return nil
        }
    }
    
    static func getButton(for accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) -> AccessoryButton? {
        let category = accessory.category.categoryType
        
        if category.isEmpty {
            return Lightbulb(of: accessory, at: position, delegate: delegate)
        } else {
            switch category {
            case HMAccessoryCategoryTypeLightbulb:
                return Lightbulb(of: accessory, at: position, delegate: delegate)
            case HMAccessoryCategoryTypeBridge:
                return Bridge(of: accessory, at: position, delegate: delegate)
            default:
                return nil
            }
        }

    }
    
    // MARK: Accessory Delegate
    func accessoryDidUpdateReachability(_ accessory: HMAccessory) {
        checkNetworkStatus()
        enablePrimaryCharacteristicNotifications()
    }
    
}

class Lightbulb: AccessoryButton {
    
    // MARK: Initializers
    required init(of accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        super.init(of: accessory, at: position, delegate: delegate)
        addTarget(self, action: #selector(togglePowerState), for: .touchUpInside)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    func togglePowerState() {
        if accessory.isReachable {
            if !accessory.isBlocked {
                if let lightBulbService = accessory.services.first(where: { $0.serviceType == HMServiceTypeLightbulb }), let powerState = lightBulbService.characteristics.first(where: { $0.characteristicType == HMCharacteristicTypePowerState }) {
                    if let on = powerState.value as? Bool {
                        let newValue = on ? false : true
                        powerState.writeValue(newValue, completionHandler: { (errorMessage) in
                            if let error = errorMessage {
                                self.delegate.shouldPresentError(error)
                            } else {
                                self.primaryCharacteristicSet = newValue
                                log.debug("Sucessfully turned \(self.primaryCharacteristicSet ? "on" : "off") accessory \(self.accessory)")
                            }
                        })
                    } else {
                        self.delegate.shouldPresentError(FacilityError.noOldValue)
                    }
                } else {
                    self.delegate.shouldPresentError(FacilityError.serviceUnreachable)
                }
            } else {
                delegate.shouldUnblockAccessory(accessory, completion: togglePowerState)
            }
        } else {
            delegate.shouldPresentError(FacilityError.accessoryUnreachable)
        }
    }
    
    override func checkPrimaryCharacteristic() {
        if let primaryCharacteristic = AccessoryButton.getPrimaryCharacteristic(of: accessory) {
            primaryCharacteristic.readValue(completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error("Failed to read \(primaryCharacteristic.localizedDescription) value of accessory \(self.accessory) due to error: \(error)")
                } else {
                    if let newValue = primaryCharacteristic.value as? Bool {
                        self.primaryCharacteristicSet = newValue
                    } else {
                        self.primaryCharacteristicSet = false
                    }
                }
            })
        }
    }
    
    // MARK: Accessory Delegate
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if let primaryCharacteristicType = AccessoryButton.getPrimaryCharacteristic(of: accessory)?.characteristicType, primaryCharacteristicType == characteristic.characteristicType {
            if let newValue = characteristic.value as? Bool {
                primaryCharacteristicSet = newValue
            } else {
                primaryCharacteristicSet = false
            }
        }
    }
    
}

class Bridge: AccessoryButton {
    
    // MARK: Initializers
    required init(of accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        super.init(of: accessory, at: position, delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    override func checkPrimaryCharacteristic() {
        if accessory.isReachable {
            primaryCharacteristicSet = true
        } else {
            primaryCharacteristicSet = false
        }
    }
    
    // MARK: Accessory Delegate
    override func accessoryDidUpdateReachability(_ accessory: HMAccessory) {
        if accessory.isReachable {
            primaryCharacteristicSet = true
        } else {
            primaryCharacteristicSet = false
        }
    }
    
}

