//
//  NotesInputViewModel.swift
//  Reef
//
//  Created by Matheus Vaccaro on 20/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol NotesInputViewModelOutputDelegate: class {
    func notesInput(_ notesInputViewModel: NotesInputViewModel, didUpdateNotes notes: String?)
}

class NotesInputViewModel {
    
    weak var outputDelegate: NotesInputViewModelOutputDelegate?
    
    var notes: String? {
        didSet {
            outputDelegate?.notesInput(self, didUpdateNotes: notes)
        }
    }
    
    var textViewPlaceholder: String {
        return Strings.NotesInputView.textViewPlaceholder
    }
    
}
