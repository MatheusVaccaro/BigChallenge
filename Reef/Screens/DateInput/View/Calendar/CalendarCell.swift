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
    @IBOutlet weak var roundedView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        roundedView.layer.cornerRadius = roundedView.bounds.width/2
    }
    
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
        dayLabel.textColor = UIColor.white
        roundedView.backgroundColor = UIColor.black
    }
    
    func deselect(basedOn cellState: CellState? = nil) {
        backgroundColor = UIColor.clear
        roundedView.backgroundColor = UIColor.clear
        if let cellState = cellState, cellState.dateBelongsTo != .thisMonth {
            dayLabel.textColor = UIColor.DateInput.Calendar.dateOffCurrentMonth
        } else {
            dayLabel.textColor = UIColor.DateInput.Calendar.deselectedDate
        }
    }
}
