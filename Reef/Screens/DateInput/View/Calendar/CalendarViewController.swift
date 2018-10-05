//
//  CalendarViewController.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import JTAppleCalendar

protocol CalendarDelegate: class {
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState)
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState)
}

class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource {
    
    weak var delegate: CalendarDelegate?
    @IBOutlet weak var calendar: JTAppleCalendarView!
    @IBOutlet weak var weekdaysContainerView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        calendar.scrollingMode = .stopAtEachSection
        calendar.allowsDateCellStretching = false
        calendar.minimumInteritemSpacing = 0
        calendar.minimumLineSpacing = 0
        
        setupWeekdays()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        calendar.reloadData()
        view.setNeedsLayout()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendar.cellSize = (calendar.frame.width)/7
        calendar.invalidateIntrinsicContentSize()
    }
    
    func setupWeekdays() {
        let weekdays = weekdaysContainerView.subviews.compactMap({ $0 as? UILabel })
        
        for (index, weekdayLabel) in weekdays.enumerated() {
            weekdayLabel.text = Calendar.current.veryShortWeekdaySymbols[index]
            weekdayLabel.textColor = UIColor.DateInput.Calendar.weekday
        }
    }
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let today = Date()
        guard let tenYearsFromToday = Calendar.current.date(byAdding: DateComponents(year: 10), to: today) else {
            fatalError("Could not compute the date of three years from now.")
        }
        
        let parameters = ConfigurationParameters(startDate: today, endDate: tenYearsFromToday, numberOfRows: 6)
        
        return parameters
    }
}

extension CalendarViewController: JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell =  calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath)
        guard let calendarCell = cell as? CalendarCell else { return cell }
        
        calendarCell.configure(with: cellState, for: calendar)
        
        return calendarCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.configure(with: cellState, for: calendar)
    }
    
    func calendarSizeForMonths(_ calendar: JTAppleCalendarView?) -> MonthSize? {
        // TODO Make this accessibility-friendly
        return MonthSize(defaultSize: 20)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, headerViewForDateRange range: (start: Date, end: Date),
                  at indexPath: IndexPath) -> JTAppleCollectionReusableView {
        let headerView = calendar.dequeueReusableJTAppleSupplementaryView(withReuseIdentifier: "HeaderView",
                                                                          for: indexPath)
        
        guard let calendarHeaderView = headerView as? CalendarHeaderView else { return headerView }
        calendarHeaderView.configure(forDateRange: range)
        
        return headerView
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.select(basedOn: cellState)
        
        delegate?.calendar(calendar, didSelectDate: date, cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.deselect(basedOn: cellState)
        
        delegate?.calendar(calendar, didDeselectDate: date, cell: cell, cellState: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, shouldSelectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) -> Bool {
        // Check if selected date is after today
        let comparisonResult = Calendar.current.compare(Date.now(), to: date, toGranularity: .day)
        return comparisonResult == .orderedAscending || comparisonResult == .orderedSame
    }
}

extension CalendarDelegate {
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) { }
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) { }
}

extension CalendarViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "CalendarViewController"
    }
    
    static var storyboardIdentifier: String {
        return "Calendar"
    }
}
