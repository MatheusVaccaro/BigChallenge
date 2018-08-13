//
//  CalendarCell.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import JTAppleCalendar

class CalendarCell: JTAppleCell {
    
    @IBOutlet weak var dayLabel: UILabel!
    
    func configure(with cellState: CellState) {
        let day = Calendar.current.component(.day, from: cellState.date)
        dayLabel.text = "\(day)"
        
        if isSelected {
            select(basedOn: cellState)
        } else {
        	deselect(basedOn: cellState)
        }
    }
    
    func select(basedOn cellState: CellState? = nil) {
        dayLabel.textColor = UIColor.DateInput.Calendar.selectedDate
    }
    
    func deselect(basedOn cellState: CellState? = nil) {
        if let cellState = cellState, cellState.dateBelongsTo != .thisMonth {
            dayLabel.textColor = UIColor.DateInput.Calendar.dateOffCurrentMonth
        } else {
            dayLabel.textColor = UIColor.DateInput.Calendar.deselectedDate
        }
    }
}
