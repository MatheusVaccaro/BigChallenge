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
            select()
        } else {
            deselect()
        }
    }
    
    func select() {
        dayLabel.textColor = UIColor.DateInput.defaultColor
    }
    
    func deselect() {
        dayLabel.textColor = .black
    }
}
