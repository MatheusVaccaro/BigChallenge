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
        return Strings.MoreOptionsScreen.NotesCell.subtitle
    }
    
    var imageName: String {
        return "notesIcon"
    }
    
    
}
