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
    var canCreateTask: Bool { get }
    var isPresentingMoreDetails: Bool { get }
    var taskTitle: String? { get }
}

class NewTaskView: UIView {
    weak var delegate: NewTaskViewDelegate!
    
    override var accessibilityLabel: String? {
        get { return Strings.Task.CreationScreen.VoiceOver.label }
        set { }
    }
    
    override var accessibilityValue: String? {
        get {
            return delegate.taskTitle
        }
        set { }
    }
    
    override var accessibilityHint: String? {
        get {
            guard delegate.isPresentingMoreDetails else { return nil }
            return Strings.Task.CreationScreen.VoiceOver.hint
        }
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
            var ans: [UIAccessibilityCustomAction] = []
            
            if delegate.canCreateTask { ans.append(doneAction) }
            if !delegate.isPresentingMoreDetails { ans.append(detailsAction) }
            
            return ans
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
