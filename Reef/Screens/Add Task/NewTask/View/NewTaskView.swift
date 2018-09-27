//
//  NewTaskView.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 23/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol NewTaskViewDelegate: class {
    func presentDetails()
    func doneEditing()
}

class NewTaskView: UIView {
    weak var delegate: NewTaskViewDelegate?
    
    override var accessibilityLabel: String? {
        get { return Strings.Task.CreationScreen.VoiceOver.label }
        set { }
    }
    
    override var accessibilityHint: String? {
        get { return Strings.Task.CreationScreen.VoiceOver.hint }
        set { }
    }
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let detailsActionName = Strings.Task.CreationScreen.VoiceOver.ShowDetailsAction
            let doneActionName = Strings.Task.CreationScreen.VoiceOver.CreateTaskAction
            
            let detailsAction = UIAccessibilityCustomAction(name: detailsActionName,
                                                            target: self,
                                                            selector: #selector(activateDetailsButton))
            let doneAction = UIAccessibilityCustomAction(name: doneActionName,
                                                         target: self,
                                                         selector: #selector(activateDoneButton))
            return [detailsAction, doneAction]
        }
        
        set { }
    }
    
    @objc private func activateDetailsButton() {
        delegate?.presentDetails()
    }
    
    @objc private func activateDoneButton() {
        delegate?.doneEditing()
    }
        
}
