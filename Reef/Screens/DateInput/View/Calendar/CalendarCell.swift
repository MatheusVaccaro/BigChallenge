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
    private(set) var backgroundCircleLayer: CAShapeLayer!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundCircleLayer = CAShapeLayer()
        contentView.layer.addSublayer(backgroundCircleLayer)
    }
    
    func setupBackgroundCircleLayer() {
        let circleRadius = min(contentView.frame.width, contentView.frame.height) / 2
        
        let circleBounds =  CGRect(origin: CGPoint(x: max(0, contentView.frame.width - contentView.frame.height) / 2,
                                                   y: max(0, contentView.frame.height - contentView.frame.width) / 2),
                                   size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
        backgroundCircleLayer.path = UIBezierPath(roundedRect: circleBounds, cornerRadius: circleRadius).cgPath
        backgroundCircleLayer.zPosition = -1000
        backgroundCircleLayer.fillColor = UIColor.DateInput.Calendar.deselectedDateBackground.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBackgroundCircleLayer()
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
        dayLabel.textColor = UIColor.DateInput.Calendar.selectedDate
        backgroundCircleLayer.fillColor = UIColor.DateInput.Calendar.selectedDateBackground.cgColor
    }
    
    func deselect(basedOn cellState: CellState? = nil) {
        backgroundCircleLayer.fillColor = UIColor.DateInput.Calendar.deselectedDateBackground.cgColor
        if let cellState = cellState, cellState.dateBelongsTo != .thisMonth {
            dayLabel.textColor = UIColor.DateInput.Calendar.dateOffCurrentMonth
        } else {
            dayLabel.textColor = UIColor.DateInput.Calendar.deselectedDate
        }
    }
}
