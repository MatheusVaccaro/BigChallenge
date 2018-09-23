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
        return Strings.MoreOptionsScreen.NotesCell.title
    }
    
    var subtitle: String {
        if notes != "" {
            return notes
        } else {
            return Strings.MoreOptionsScreen.NotesCell.subtitle
        }
    }
    
    var imageName: String {
        return "notesIcon"
    }
    
    var voiceOverHint: String {
        return Strings.MoreOptionsScreen.NotesCell.subtitle
    }
    
    var voiceOverValue: String? {
        if notes != "" {
            return subtitle
        } else {
            return nil
        }
    }
}
