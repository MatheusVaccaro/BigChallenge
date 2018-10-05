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
                       didFind location: CLCircularRegion?,
                       named: String,
                       arriving: Bool)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectDate date: Date?)
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency)
    
    func shouldPresent(viewModel: IconCellPresentable)
    
    func privateTagViewModel(_ privateTagViewModel: PrivateTagViewModel, didActivate: Bool)
}

private enum TagDetailsCellType: Int {
    case locationCell
    case dateCell
    case privateTagCell
}

class AddTagDetailsViewModel {
    
    weak var delegate: AddTagDetailsViewModelDelegate?
    
    let locationInputViewModelType: LocationInputViewModel.Type
    var locationInputViewModel: LocationInputViewModel?
    
    let dateInputViewModelType: DateInputViewModelProtocol.Type
    var dateInputViewModel: DateInputViewModelProtocol?
    
    let privateTagViewModelType: PrivateTagViewModel.Type
    var privateTagViewModel: PrivateTagViewModel?
    
    private let _numberOfSections = 1
    private let _numberOfRows = 3
    
    private var cells: [TagDetailsCellType : IconCellPresentable]
    private var placeholderCells: [TagDetailsCellType : IconCellPresentable]
    
    init() {
        self.locationInputViewModelType = LocationInputViewModel.self
        self.dateInputViewModelType = DateInputViewModel.self
        self.privateTagViewModelType = PrivateTagViewModel.self
        
        self.privateTagViewModel = privateTagViewModelType.init()
        self.cells = [.privateTagCell: privateTagViewModel!]
        self.placeholderCells = [.locationCell: DefaultLocationInputIconCellPresentable(),
                                 .dateCell: DefaultDateInputIconCellPresentable()]
    }
    
    func edit(_ tag: Tag?) {
        guard let tag = tag else { return }
        
        if tag.location != nil {
            instantiateCell(ofType: .locationCell)
            locationInputViewModel?.edit(tag)
        }
        
        if tag.dueDate != nil {
            instantiateCell(ofType: .dateCell)
            dateInputViewModel?.edit(tag)
        }
        
        if tag.requiresAuthentication {
            privateTagViewModel?.edit(tag)
        }
    }
}

extension AddTagDetailsViewModel: AddDetailsProtocol {
    var numberOfSections: Int {
        return _numberOfSections
    }
    
    var numberOfRows: Int {
        return _numberOfRows
    }
    
    func viewModelForCell(at row: Int) -> IconCellPresentable {
        if let tagDetailsCellType = TagDetailsCellType.init(rawValue: row),
           let cellViewModel = cells[tagDetailsCellType] ?? placeholderCells[tagDetailsCellType] {
            return cellViewModel
            
        } else {
            return placeholderCells.values.first!
        }
    }
    
    func shouldPresentView(at row: Int) {
        if let tagDetailsCellType = TagDetailsCellType.init(rawValue: row),
           let cellViewModel = cells[tagDetailsCellType] ?? instantiateCell(ofType: tagDetailsCellType) {
            delegate?.shouldPresent(viewModel: cellViewModel)
        }
    }
    
    @discardableResult
    private func instantiateCell(ofType cellType: TagDetailsCellType) -> IconCellPresentable? {
        let iconCellPresentable: IconCellPresentable?
        
        switch cellType {
        case .privateTagCell:
            privateTagViewModel = privateTagViewModelType.init()
            privateTagViewModel?.delegate = self
            iconCellPresentable = privateTagViewModel
            
        case .locationCell:
            locationInputViewModel = locationInputViewModelType.init()
            locationInputViewModel?.delegate = self
            iconCellPresentable = locationInputViewModel
            
        case .dateCell:
            let nextHour = Date.now().snappedToNextHour()
            let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: nextHour)
            dateInputViewModel = dateInputViewModelType.init(calendarDate: calendarDate, timeOfDay: timeOfDay,
                                                             frequency: .none, delegate: self)
            iconCellPresentable = dateInputViewModel
        }
        
        cells[cellType] = iconCellPresentable
        
        return iconCellPresentable
    }
}

extension AddTagDetailsViewModel: LocationInputDelegate {
    func locationInput(_ locationInputViewModel: LocationInputViewModel,
                       didFind location: CLCircularRegion?, named: String, arriving: Bool) {
        delegate?.locationInput(locationInputViewModel, didFind: location, named: named, arriving: arriving)
    }
}

extension AddTagDetailsViewModel: DateInputViewModelDelegate {
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: Date?) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectDate: date)
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol,
                            didSelectFrequency frequency: NotificationOptions.Frequency) {
        delegate?.dateInputViewModel(dateInputViewModel, didSelectFrequency: frequency)
    }
}

extension AddTagDetailsViewModel: PrivateTagViewModelDelegate {
    func privateTagViewModel(_ privateTagViewModel: PrivateTagViewModel, didActivate: Bool) {
        delegate?.privateTagViewModel(privateTagViewModel, didActivate: didActivate)
    }
}

private extension DateInputViewModelProtocol {
    func edit(_ tag: Tag) {
        guard let dueDate = tag.dueDate else { return }
        
        let (calendarDate, timeOfDay) = Calendar.current.splitCalendarDateAndTimeOfDay(from: dueDate)
        
        self.calendarDate.onNext(calendarDate)
        self.timeOfDay.onNext(timeOfDay)
    }
}

private extension LocationInputViewModel {
    func edit(_ tag: Tag) {
        guard tag.location != nil else { return }
        location = tag.location
        isArriving = tag.isArrivingLocation
        placeName = tag.locationName!
    }
}

private extension PrivateTagViewModel {
    func edit(_ tag: Tag) {
        isSwitchOn = tag.requiresAuthentication
    }
}
