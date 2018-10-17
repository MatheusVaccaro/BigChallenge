//
//  OptionTableViewCellViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 09/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

protocol IconCellPresentable {
    var title: String { get }
    var subtitle: String { get }
    var imageName: String { get }
    
    var isSwitchCell: Bool { get }
    var isSwitchOn: Bool { get set }
    func switchActivated(bool: Bool, completion: @escaping ((Bool) -> Void))
    
    var shouldShowDeleteIcon: Bool { get }
    func rightImageClickHandler()
    
    ///Can't have count > 2
    var tagInfo: [String] { get set }
    
    var voiceOverHint: String { get }
    var voiceOverValue: String? { get }
}

extension IconCellPresentable {
    var isSwitchCell: Bool { return false }
    var isSwitchOn: Bool { get { return false } set { } }
    func switchActivated(bool: Bool, completion: @escaping ((Bool) -> Void)) {}
    
    var shouldShowDeleteIcon: Bool { return false }
    func rightImageClickHandler() { }
    
    var tagInfo: [String] {
        get { return [] }
        set { }
    }
}
