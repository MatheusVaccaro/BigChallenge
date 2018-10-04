//
//  PlaceholderLocationInputIconCellPresentable.swift
//  Reef
//
//  Created by Max Zorzetti on 04/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

struct DefaultLocationInputIconCellPresentable: IconCellPresentable {
    
    var title: String { return Strings.LocationInputView.Cell.title }
    
    var subtitle: String { return Strings.LocationInputView.Cell.subtitle }
    
    var imageName: String { return "locationIcon" }
    
    var voiceOverHint: String { return Strings.LocationInputView.Cell.subtitle }

    var voiceOverValue: String? { return nil }
}
