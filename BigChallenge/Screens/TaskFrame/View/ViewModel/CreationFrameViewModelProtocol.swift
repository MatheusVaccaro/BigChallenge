//
//  CreationFrameViewModelProtocol.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 10/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import RxSwift

protocol CreationFrameViewModelProtocol {
    func didTapCancelButton()
    func didTapSaveButton()
    var doneButtonObservable: BehaviorSubject<Bool> { get }
    var delegate: CreationFrameViewModelDelegate? { get set }
}

protocol CreationFrameViewModelDelegate: class {
    func didTapCancelButton()
    func didTapSaveButton()
}
