//
//  CalendarViewController.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarViewController: UIViewController, JTAppleCalendarViewDataSource, JTAppleCalendarViewDelegate {
    
    @IBOutlet weak var calendar: JTAppleCalendarView!
    
    func configureCalendar(_ calendar: JTAppleCalendarView) -> ConfigurationParameters {
        let today = Date()
        guard let threeYearsFromToday = Calendar.current.date(byAdding: DateComponents(year: 3), to: today) else {
            fatalError("Could not compute the date of three years from now.")
        }
        
        let parameters = ConfigurationParameters(startDate: today, endDate: threeYearsFromToday)
        
        return parameters
    }
}

extension JTAppleCalendarViewDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, cellForItemAt date: Date,
                  cellState: CellState, indexPath: IndexPath) -> JTAppleCell {
        let cell =  calendar.dequeueReusableJTAppleCell(withReuseIdentifier: "CalendarCell", for: indexPath)
        guard let calendarCell = cell as? CalendarCell else { return cell }
        
        calendarCell.configure(with: cellState)
        
        return calendarCell
    }
    
    func calendar(_ calendar: JTAppleCalendarView, willDisplay cell: JTAppleCell,
                  forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.configure(with: cellState)
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.select()
    }
    
    func calendar(_ calendar: JTAppleCalendarView, didDeselectDate date: Date,
                  cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        calendarCell.deselect()
    }
}

extension CalendarViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "CalendarViewController"
    }
    
    static var storyboardIdentifier: String {
        return "Calendar"
    }
}
