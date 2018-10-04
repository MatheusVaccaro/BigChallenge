//
//  NotesTableViewCellViewModel.swift
//  Reef
//
//  Created by Matheus Vaccaro on 20/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

extension NotesInputViewModel: IconCellPresentable {
    var title: String {
        return Strings.NotesInputView.Cell.title
    }
    
    var subtitle: String {
        if notes != "" {
            return notes
        } else {
            return Strings.NotesInputView.Cell.subtitle
        }
    }
    
    var imageName: String {
        return "notesIcon"
    }
    
    var rightImageName: String {
        if !hasNotes {
            return "rightArrow"
        } else {
            return "removeButton"
        }
    }
    
    func rightImageClickHandler() {
        notes = ""
    }
    
    var voiceOverHint: String {
        return Strings.NotesInputView.Cell.subtitle
    }
    
    var voiceOverValue: String? {
        if notes != "" {
            return subtitle
        } else {
            return nil
        }
    }
    
    private var hasNotes: Bool {
        return !(notes == "")
    }
}
