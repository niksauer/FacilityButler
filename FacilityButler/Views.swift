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

let statePicturesLight = [
    HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "lightbulb_off")],
    HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "bridge_off")],
    HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "lightbulb_off")]
]

let statePicturesDark = [
    HMAccessoryCategoryTypeLightbulb : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")],
    HMAccessoryCategoryTypeBridge : [#imageLiteral(resourceName: "dark_bridge_off"), #imageLiteral(resourceName: "dark_bridge_on")],
    HMAccessoryCategoryTypeOther : [#imageLiteral(resourceName: "dark_lightbulb_off"), #imageLiteral(resourceName: "dark_lightbulb_on")]
]


protocol AccessoryButtonDelegate {
    func shouldPresentError(_ error: Error)
    func shouldUnblockAccessory(_ accessory: HMAccessory, completion: @escaping (() -> Void))
}

class AccessoryButton: UIButton, HMAccessoryDelegate {
    
    // MARK: Instance Properties
    let accessory: HMAccessory
    var position: CGPoint
    let delegate: AccessoryButtonDelegate

    // MARK: Initializers
    init(_ accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        self.accessory = accessory
        self.position = position
        self.delegate = delegate
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Actions
    func getBackgroundImage(for theme: Theme, active: Bool) -> UIImage {
        var category = accessory.category.categoryType
        
        if category.isEmpty {
            category = HMAccessoryCategoryTypeOther
        }
        
        let index = active ? 1 : 0
        
        switch theme {
        case .Light:
            return statePicturesLight[category]![index]
        case .Dark:
            return statePicturesDark[category]![index]
        }
    }
    
    func getPrimaryCharacteristic() -> HMCharacteristic? {
        let primaryFunctions = [
            HMAccessoryCategoryTypeLightbulb : [HMServiceTypeLightbulb, HMCharacteristicTypePowerState]
        ]
        
        let category = accessory.category.categoryType
        
        if let primaryService = primaryFunctions[category]?[0], let primaryCharacteristic = primaryFunctions[category]?[1], let service = accessory.services.first(where: { $0.serviceType == primaryService }), let characteristic = service.characteristics.first(where: { $0.characteristicType == primaryCharacteristic }) {
            return characteristic
        } else {
            return nil
        }
    }
    
}

class Lightbulb: AccessoryButton {
    
    // MARK: Instance Properties
    var isOn = false {
        didSet {
            setImage(getBackgroundImage(for: ThemeManager.currentTheme(), active: isOn), for: .normal)
        }
    }
    
    // MARK: Initializers
    init(accessory: HMAccessory, at position: CGPoint, delegate: AccessoryButtonDelegate) {
        super.init(accessory, at: position, delegate: delegate)
        
        let image = getBackgroundImage(for: ThemeManager.currentTheme(), active: isOn)
        setImage(image, for: .normal)
        frame = CGRect(x: position.x, y: position.y, width: image.size.width, height: image.size.height)
        
        addTarget(self, action: #selector(togglePowerState), for: .touchUpInside)
    
        if let primaryCharacteristic = getPrimaryCharacteristic() {
            primaryCharacteristic.enableNotification(true, completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error(error)
                } else {
                    log.debug("Enabled value change notifications for characteristic \(primaryCharacteristic.localizedDescription) of accessory \(accessory.name)")
                }
            })
            
            primaryCharacteristic.readValue(completionHandler: { (errorMessage) in
                if let error = errorMessage {
                    log.error(error)
                } else {
                    self.isOn = primaryCharacteristic.value as! Bool
                }
            })
        }
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
                                self.isOn = newValue
                                log.debug("Sucessfully turned \(self.isOn ? "on" : "off") accessory \(self.accessory)")
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
    
    // MARK: Accessory Delegate
    func accessory(_ accessory: HMAccessory, service: HMService, didUpdateValueFor characteristic: HMCharacteristic) {
        if let characteristic = getPrimaryCharacteristic() {
            print(characteristic.localizedDescription)
                
            switch characteristic.characteristicType {
            case HMCharacteristicTypePowerState:
                characteristic.readValue(completionHandler: { (error) in
                    self.isOn = characteristic.value as! Bool
                })
            default:
                break
            }
        }
    }
    
}

