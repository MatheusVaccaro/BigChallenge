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
        
        backgroundCircleLayer.fillColor = UIColor.DateInput.Calendar.deselectedDateBackground.cgColor
    }
    
    func setupBackgroundCircleLayer() {
        let circleRadius = min(contentView.frame.width, contentView.frame.height) / 2
        
        let circleBounds =  CGRect(origin: CGPoint(x: max(0, contentView.frame.width - contentView.frame.height) / 2,
                                                   y: max(0, contentView.frame.height - contentView.frame.width) / 2),
                                   size: CGSize(width: circleRadius * 2, height: circleRadius * 2))
        backgroundCircleLayer.path = UIBezierPath(roundedRect: circleBounds, cornerRadius: circleRadius).cgPath
        backgroundCircleLayer.zPosition = -1000
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupBackgroundCircleLayer()
    }
    
    func configure(with cellState: CellState) {
        let day = Calendar.current.component(.day, from: cellState.date)
        dayLabel.text = "\(day)"
        
        if isSelected {
            select(basedOn: cellState, animated: false)
        } else {
            deselect(basedOn: cellState, animated: false)
        }
    }
    
    func select(basedOn cellState: CellState? = nil, animated: Bool = true) {
        // Change background visuals
        let selectedBackgroundColor = UIColor.DateInput.Calendar.selectedDateBackground
        if animated {
            setBackgroundColor(to: selectedBackgroundColor)
        } else {
            CATransaction.disableAnimationsIn { setBackgroundColor(to: selectedBackgroundColor) }
        }
        
        // Change label visuals
        dayLabel.textColor = UIColor.DateInput.Calendar.selectedDate
    }
    
    func deselect(basedOn cellState: CellState? = nil, animated: Bool = true) {
        // Change background visuals
        let deselectedBackgroundColor = UIColor.DateInput.Calendar.deselectedDateBackground
        if animated {
            setBackgroundColor(to: deselectedBackgroundColor)
        } else {
            CATransaction.disableAnimationsIn { setBackgroundColor(to: deselectedBackgroundColor) }
        }
        
        // Change label visuals
        if let cellState = cellState, cellState.dateBelongsTo != .thisMonth {
            dayLabel.textColor = UIColor.DateInput.Calendar.dateOffCurrentMonth
        } else {
            dayLabel.textColor = UIColor.DateInput.Calendar.deselectedDate
        }
    }
    
    private func setBackgroundColor(to color: UIColor) {
        backgroundCircleLayer.fillColor = color.cgColor
    }
}
