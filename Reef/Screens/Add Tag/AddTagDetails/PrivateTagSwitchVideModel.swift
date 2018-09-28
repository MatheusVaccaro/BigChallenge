//
//  PrivateTagSwitchVideModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 28/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import ReefKit

protocol PrivateTagViewModelDelegate: class {
    func privateTagViewModel(_ privateTagViewModel: PrivateTagViewModel, didActivate: Bool)
}

class PrivateTagViewModel: IconCellPresentable {
    
    weak var delegate: PrivateTagViewModelDelegate?
    
    var title: String {
        get {
            return Strings.Tag.Private.Cell.title
        }
    }
    
    var subtitle: String {
        get {
            return Strings.Tag.Private.Cell.subtitle
        }
    }
    
    var imageName: String {
        get {
            return "teteuzika"
        }
    }
    
    var voiceOverHint: String {
        return Strings.Tag.Private.Cell.VoiceOver.hint
    }
    
    var voiceOverValue: String? {
        return isSwitchOn
            ? Strings.General.on
            : Strings.General.off
    }
    
    var isSwitchCell: Bool {
        return true
    }
    
    private var _isSwitchOn: Bool = false
    
    var isSwitchOn: Bool {
        get {
            return _isSwitchOn
        }
        set {
            _isSwitchOn = newValue
        }
    }
    
    func switchActivated(bool: Bool, completion: @escaping ((Bool) -> Void)) {
        Authentication.authenticate { granted in
            if granted {
                self.isSwitchOn = !self.isSwitchOn
            }
            self.delegate?.privateTagViewModel(self, didActivate: self.isSwitchOn)
            completion(self.isSwitchOn)
            }
    }
}
