//
//  DefaultNotesInputIconCellPresentable.swift
//  Reef
//
//  Created by Max Zorzetti on 04/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

struct DefaultNotesInputIconCellPresentable: IconCellPresentable {
    
    var title: String { return Strings.NotesInputView.Cell.title }
    
    var subtitle: String { return Strings.NotesInputView.Cell.subtitle }
    
    var imageName: String { return "notesIcon" }
    
    var voiceOverHint: String { return Strings.NotesInputView.Cell.subtitle }
    
    var voiceOverValue: String? { return nil }
}
