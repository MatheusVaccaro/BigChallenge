//
//  CalendarHeaderView.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 12/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import JTAppleCalendar

class CalendarHeaderView: JTAppleCollectionReusableView {
    
    @IBOutlet weak var monthStackView: UIStackView!
    
    func configure(forDateRange dateRange: (start: Date, end: Date)) {
        let labels = monthStackView.arrangedSubviews.compactMap { $0 as? UILabel }
        
        clean(labels)
        
        let monthText: String = {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM"
            
            return dateFormatter.string(from: dateRange.start).localizedUppercase
        }()
        
        let weekday = Calendar.current.component(.weekday, from: dateRange.start)
        labels[weekday - 1].alpha = 1
        labels[weekday - 1].text = monthText
    }
    
    private func clean(_ labels: [UILabel]) {
        for label in labels {
            label.text = ""
            label.textColor = UIColor.DateInput.Calendar.month
        }
    }
}
