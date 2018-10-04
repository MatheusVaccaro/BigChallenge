//
//  PlaceholderDateInputIconCellPresentable.swift
//  Reef
//
//  Created by Max Zorzetti on 04/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

struct DefaultDateInputIconCellPresentable: IconCellPresentable {
    
    var title: String { return Strings.DateInputView.Cell.title }
    
    var subtitle: String { return Strings.DateInputView.Cell.subtitle }
    
    var imageName: String { return "dateIcon" }
    
    var voiceOverHint: String { return Strings.DateInputView.Cell.subtitle }
    
    var voiceOverValue: String? { return nil }
}
