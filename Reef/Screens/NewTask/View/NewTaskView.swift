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
        get { return "accessibilityLabel" }
        set { }
    }
    
    override var accessibilityHint: String? {
        get { return "accessibilityHint" }
        set { }
    }
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get { //TODO: localize
            let detailsAction = UIAccessibilityCustomAction(name: "add details",
                                                            target: self,
                                                            selector: #selector(activateDetailsButton))
            let doneAction = UIAccessibilityCustomAction(name: "create",
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
