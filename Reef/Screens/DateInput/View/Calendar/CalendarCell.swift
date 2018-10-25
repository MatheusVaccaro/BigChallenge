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
    
    private static var todayFont = UIFont.font(sized: 18, weight: .bold, with: .body).monospaced()
    private static var defaultFont = UIFont.font(sized: 18, weight: .regular, with: .body).monospaced()
    
    @IBOutlet weak var dayLabel: UILabel!
    @IBOutlet weak var roundedView: UIView!
    private(set) var backgroundCircleLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.layer.masksToBounds = false
        dayLabel.layer.masksToBounds = false
        dayLabel.font = CalendarCell.defaultFont
        dayLabel.adjustsFontSizeToFitWidth = true
        
        backgroundCircleLayer = CAShapeLayer()
        contentView.layer.addSublayer(backgroundCircleLayer)
        
        backgroundCircleLayer.fillColor = UIColor.deselectedDateBackground.cgColor
    }
    
    func setupBackgroundCircleLayer() {
        let sizeMod: CGFloat = 0.9
        let circleRadius = min(contentView.frame.width, contentView.frame.height) / 2 * sizeMod
        
        let circleBounds =  CGRect(origin: CGPoint(x: contentView.frame.midX - circleRadius,
                                                   y: contentView.frame.midY - circleRadius),
                                   size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
        backgroundCircleLayer.path = UIBezierPath(roundedRect: circleBounds, cornerRadius: circleRadius).cgPath
        backgroundCircleLayer.zPosition = -1000
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // TODO: Figure out how to scale down single-digit days on large DynamicType
        setupBackgroundCircleLayer()
    }
    
    func configure(with cellState: CellState, for calendar: JTAppleCalendarView) {
        let day = Calendar.current.component(.day, from: cellState.date)
        dayLabel.text = "\(day)"
        
        // Configure selectable visuals
        let isSelectable = calendar.calendarDelegate?.calendar(calendar, shouldSelectDate: cellState.date,
                                                               cell: self, cellState: cellState) ?? true
        guard isSelectable else {
            deselect(basedOn: cellState, animated: false)
            dayLabel.textColor = .unselectableDate
            dayLabel.font = CalendarCell.defaultFont
            return
        }
        
        // Configure "today" visuals
        if Calendar.current.isDateInToday(cellState.date) {
            dayLabel.font = CalendarCell.todayFont
        } else {
            dayLabel.font = CalendarCell.defaultFont
        }
        
        // Configure selection visuals
        if cellState.isSelected {
            select(basedOn: cellState, animated: false)
        } else {
            deselect(basedOn: cellState, animated: false)
        }
    }
    
    func select(basedOn cellState: CellState? = nil, animated: Bool = true) {
        // Change background visuals
        let selectedBackgroundColor = UIColor.selectedDateBackground
        
        if animated {
            setBackgroundColor(to: selectedBackgroundColor)
        } else {
            CATransaction.disableAnimations { setBackgroundColor(to: selectedBackgroundColor) }
        }
        
        // Change label visuals
        dayLabel.textColor = .selectedDate
    }
    
    func deselect(basedOn cellState: CellState? = nil, animated: Bool = true) {
        // Change background visuals
        let deselectedBackgroundColor = UIColor.deselectedDateBackground
        if animated {
            setBackgroundColor(to: deselectedBackgroundColor)
        } else {
            CATransaction.disableAnimations { setBackgroundColor(to: deselectedBackgroundColor) }
        }
        
        // Change label visuals
        if let cellState = cellState, cellState.dateBelongsTo != .thisMonth {
            dayLabel.textColor = .dateOffCurrentMonth
        } else {
            dayLabel.textColor = .largeTitle
        }
    }
    
    private func setBackgroundColor(to color: UIColor) {
        backgroundCircleLayer.fillColor = color.cgColor
    }
    
    static func reloadFonts() {
        CalendarCell.todayFont = UIFont.font(sized: 18, weight: .bold, with: .body).monospaced()
        CalendarCell.defaultFont = UIFont.font(sized: 18, weight: .regular, with: .body).monospaced()
    }
}
