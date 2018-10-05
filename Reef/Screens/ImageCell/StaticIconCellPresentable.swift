//
//  StaticIconCellPresentable.swift
//  Reef
//
//  Created by Max Zorzetti on 05/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

struct StaticIconCellPresentable: IconCellPresentable {
    var title: String
    var subtitle: String
    var imageName: String
    var voiceOverHint: String
    var voiceOverValue: String?
    var accessibilityCustomActions: [UIAccessibilityCustomAction]?
    
    init(title: String, subtitle: String, imageName: String, voiceOverHint: String, voiceOverValue: String?) {
        self.title = title
        self.subtitle = subtitle
        self.imageName = imageName
        self.voiceOverHint = voiceOverHint
        self.voiceOverValue = voiceOverValue
    }
}
