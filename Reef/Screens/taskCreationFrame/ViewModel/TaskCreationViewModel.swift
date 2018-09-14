//
//  taskCreationViewModel.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation

protocol TaskCreationDelegate: class {
    func didTapAddTask()
    func didPanAddTask()
    func didPressAddDetails()
}

class TaskCreationViewModel {
    weak var delegate: TaskCreationDelegate?
}
