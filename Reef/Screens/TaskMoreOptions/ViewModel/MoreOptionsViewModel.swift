//
//  MoreOptionsViewModel.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 01/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import CoreLocation

protocol MoreOptionsViewModelDelegate: class {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectTimeOfDay timeOfDay: DateComponents)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency)
}

class MoreOptionsViewModel: MoreOptionsViewModelProtocol {
    
    weak var delegate: MoreOptionsViewModelDelegate?
    let locationInputViewModel: LocationInputViewModel
    private(set) var dateInputViewModel: DateInputViewModelProtocol
    private var numberOfRowsInSection0: Int
    private var numberOfRowsInSection1: Int
    private(set) var isShowingLocationCell: Bool
    private(set) var isShowingTimeCell: Bool
    
    init(locationInputViewModel: LocationInputViewModel, dateInputViewModel: DateInputViewModelProtocol) {
        self.numberOfRowsInSection0 = 0
        self.numberOfRowsInSection1 = 0
        self.isShowingLocationCell = false
        self.isShowingTimeCell = false
        self.locationInputViewModel = locationInputViewModel
        self.dateInputViewModel = dateInputViewModel
        self.locationInputViewModel.delegate = self
        self.dateInputViewModel.delegate = self
        
        print("+++ INIT MoreOptionsViewModel")
    }
    
    deinit {
        print("--- DEINIT MoreOptionsViewModel")
    }
    
    func numberOfRows(in section: Int) -> Int {
        if section == 0 {
            return numberOfRowsInSection0
        } else if section == 1 {
            return numberOfRowsInSection1
        } else {
            return 0
        }
    }
    
    func numberOfSections() -> Int {
        return 2
    }
    
    func showLocationCell() {
        if !isShowingLocationCell {
            isShowingLocationCell = !isShowingLocationCell
            numberOfRowsInSection0 += 1
        }
    }
    
    func collapseLocationCell() {
        if isShowingLocationCell {
            isShowingLocationCell = !isShowingLocationCell
            numberOfRowsInSection0 -= 1
        }
    }
    
    func showTimeCell() {
        if !isShowingTimeCell {
            isShowingTimeCell = !isShowingTimeCell
            numberOfRowsInSection1 += 1
        }
    }
    
    func collapseTimeCell() {
        if isShowingTimeCell {
            isShowingTimeCell = !isShowingTimeCell
            numberOfRowsInSection1 -= 1
        }
    }
    
    func locationViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return LocationTableViewCellViewModel()
    }
    
    func timeViewModel() -> MoreOptionsTableViewCellViewModelProtocol {
        return TimeTableViewCellViewModel()
    }
}

extension MoreOptionsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputView: LocationInputView, didFind location: CLCircularRegion, arriving: Bool) {
        delegate?.locationInput(locationInputView, didFind: location, arriving: arriving)
    }
}

extension MoreOptionsViewModel: DateInputViewModelDelegate {

    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: DateComponents) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectTimeOfDay timeOfDay: DateComponents) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectTimeOfDay: timeOfDay)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}
