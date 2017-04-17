//
//  Views.swift
//  FacilityButler
//
//  Created by Niklas Sauer on 13.04.17.
//  Copyright © 2017 Hewlett Packard Enterprise. All rights reserved.
//

import UIKit
import HomeKit

class DrawToolBarView: UIView { }

class FloorPlanView: UIView { }

protocol AccessoryButtonDelegate {
    func shouldPresentError(_ error: Error)
    func shouldUnblockAccessory(_ accessory: HMAccessory, completion: @escaping (() -> Void))
}

class AccessoryButton: UIButton, HMAccessoryDelegate {
    
    // MARK: Instance Properties
    let accessory: HMAccessory
    var position: CGPoint
    let delegate: AccessoryButtonDelegate
    
    var active = false {
        didSet {
            setImage(AccessoryButton.getBackgroundImage(for: accessory, active: active), for: .normal)
        }
    }
    
    static let statePicturesLight = [
        HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "lightbulb_off")],
        HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "bridge_off")],
        HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "lightbulb_off")]
    ]
    
    static let statePicturesDark = [
        HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")],
        HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "dark_bridge_off"), #imageLiteral(resourceName: "dark_bridge_on")],
        HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")]
    ]

    // MARK: Initializers
    required init(of accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        self.accessory = accessory
        self.position = position
        self.delegate = delegate
        super.init(frame: .zero)

        let image = AccessoryButton.getBackgroundImage(for: accessory, active: active)
        setImage(image, for: .normal)
        frame = CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height)
        
        switch accessory.category.categoryType {
        case HMAccessoryCategoryTypeBridge:
            active = accessory.isReachable
        default:
            if let primaryCharacteristic = AccessoryButton.getPrimaryCharacteristic(of: accessory) {
                primaryCharacteristic.readValue(completionHandler: { (errorMessage) in
                    if let error = errorMessage {
                        log.error(error)
                    } else {
                        self.active = primaryCharacteristic.value as! Bool
                    }
                })
                
                primaryCharacteristic.enableNotification(true, completionHandler: { (errorMessage) in
                    if let error = errorMessage {
                        log.error(error)
                    } else {
                        log.debug("Enabled notifications for characteristic \(primaryCharacteristic.localizedDescription) of accessory \(accessory)")
                    }
                })
            }
        }
        
        accessory.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Class Functions
    static func getBackgroundImage(for accessory: HMAccessory, active: Bool) -> UIImage {
        var category = accessory.category.categoryType
        
        if category.isEmpty {
            category = HMAccessoryCategoryTypeOther
        }
        
        let index = active ? 1 : 0
        
        switch ThemeManager.currentTheme() {
        case .Light:
            return statePicturesLight[category]![index]
        case .Dark:
            return statePicturesDark[category]![index]
        }
    }
    
    static func getPrimaryCharacteristic(of accessory: HMAccessory) -> HMCharacteristic? {
        let primaryFunctions = [
            HMAccessoryCategoryTypeLightbulb : [HMServiceTypeLightbulb, HMCharacteristicTypePowerState]
        ]
        
        var category = accessory.category.categoryType
        
        if category.isEmpty {
            log.warning("No category specified for accessory \(accessory), assuming lightbulb")
            category = HMAccessoryCategoryTypeLightbulb
        }
        
        if let primaryService = primaryFunctions[category]?[0], let primaryCharacteristic = primaryFunctions[category]?[1], let service = accessory.services.first(where: { $0.serviceType == primaryService }), let characteristic = service.characteristics.first(where: { $0.characteristicType == primaryCharacteristic }) {
            return characteristic
        } else {
            return nil
        }
    }
    
    // MARK: Accessory Delegate
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if let primaryCharacteristic = AccessoryButton.getPrimaryCharacteristic(of: accessory), primaryCharacteristic.characteristicType == characteristic.characteristicType {
            switch accessory.category.categoryType {
            case HMAccessoryCategoryTypeLightbulb:
                active = primaryCharacteristic.value as! Bool
            default:
                break
            }
        }
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
                                self.active = newValue
                                log.debug("Sucessfully turned \(self.active ? "on" : "off") accessory \(self.accessory)")
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
    
}

class Bridge: AccessoryButton {
    
    // MARK: Initializers
    required init(of accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        super.init(of: accessory, at: position, delegate: delegate)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

