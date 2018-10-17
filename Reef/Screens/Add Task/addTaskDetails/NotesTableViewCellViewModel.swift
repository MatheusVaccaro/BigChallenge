//
//  NotesTableViewCellViewModel.swift
//  Reef
//
//  Created by Matheus Vaccaro on 20/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit

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
    
    var shouldShowDeleteIcon: Bool {
        return hasNotes
    }
    
    func rightImageClickHandler() {
        guard hasNotes else { return }
        removeNotes()
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
    
    private func removeNotes() {
        notes = ""
    }
    
    private var hasNotes: Bool {
        return !(notes == "")
    }
}

extension StaticIconCellPresentable {
    static func defaultNotesInputIconCellPresentable() -> StaticIconCellPresentable {
        let staticIconCellPresentable = StaticIconCellPresentable(title: Strings.NotesInputView.Cell.title,
                                                                  subtitle: Strings.NotesInputView.Cell.subtitle,
                                                                  imageName: "notesIcon",
                                                                  voiceOverHint: Strings.NotesInputView.Cell.subtitle,
                                                                  voiceOverValue: nil)
        return staticIconCellPresentable
    }
}
