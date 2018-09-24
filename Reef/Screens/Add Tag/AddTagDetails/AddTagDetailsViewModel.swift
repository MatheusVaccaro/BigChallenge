//
//  AddTagDetailsViewModel.swift
//  Reef
//
//  Created by Gabriel Paul on 24/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//
import CoreLocation
import ReefKit
import RxSwift

protocol AddTagDetailsViewModelDelegate: class {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion, arriving: Bool)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: Date)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency)
    
    func shouldPresent(viewModel: IconCellPresentable)
}

class AddTagDetailsViewModel {
    
    weak var delegate: AddTagDetailsViewModelDelegate?
    
    let locationInputViewModel: LocationInputViewModel
    let dateInputViewModel: DateInputViewModel
    
    private let _numberOfSections = 1
    private let _numberOfRows = 2
    
    private var cells: [IconCellPresentable] {
        return [ locationInputViewModel, dateInputViewModel ]
    }
    
    init() {
        //TODO: Private
        locationInputViewModel = LocationInputViewModel()
        dateInputViewModel = DateInputViewModel()
        
        locationInputViewModel.delegate = self
        dateInputViewModel.delegate = self
    }
    
    func edit(_ tag: Tag?) {
        locationInputViewModel.edit(tag)
        dateInputViewModel.edit(tag)
    }
}

extension AddTagDetailsViewModel: MoreOptionsViewModelProtocol {
    var numberOfSections: Int {
        return _numberOfSections
    }
    
    var numberOfRows: Int {
        return _numberOfRows
    }
    
    func viewModelForCell(at row: Int) -> IconCellPresentable {
        return cells[row]
    }
    
    func shouldPresentView(at row: Int) {
        delegate?.shouldPresent(viewModel: cells[row])
    }
}

extension AddTagDetailsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputViewModel: LocationInputViewModel, didFind location: CLCircularRegion, arriving: Bool) {
        delegate?.locationInput(locationInputViewModel, didFind: location, arriving: arriving)
    }
}

extension AddTagDetailsViewModel: DateInputViewModelDelegate {
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}

private extension DateInputViewModel {
    func edit(_ tag: Tag?) {
        guard let tag = tag, let dueDate = tag.dueDate else { return }
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: dueDate)
        
        self.calendarDate.onNext(calendarDate)
        self.timeOfDay.onNext(timeOfDay)
    }
}

private extension LocationInputViewModel {
    func edit(_ tag: Tag?) {
        location = tag?.region
        isArriving = tag?.arriving ?? false
    }
}