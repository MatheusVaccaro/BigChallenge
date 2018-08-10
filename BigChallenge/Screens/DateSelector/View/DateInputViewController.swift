//
//  DateSelectorView.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 09/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift

class DateInputViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: DateInputViewModelProtocol?
    var dateSelectorViewModel: DateInputViewModelProtocol?
    private let disposeBag = DisposeBag()

    private(set) var selectedDateLabel: UILabel!
    private(set) var selectedTimeOfDayLabel: UILabel!
    
    @IBOutlet weak var dateShortcutsStackView: UIStackView!
    @IBOutlet weak var tomorrowShortcutButton: UIButton!
    @IBOutlet weak var nextWeekShortcutButton: UIButton!
    @IBOutlet weak var nextMonthShortcutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadSelectedDateLabel()
        loadSelectedTimeOfDayLabel()
        loadShortcutButtons()
    }
    
    private func loadSelectedDateLabel() {
        selectedDateLabel = UILabel()
        selectedDateLabel.layer.masksToBounds = true
        selectedDateLabel.layer.cornerRadius = 4.3
        viewModel?.date.asObservable().subscribe(onNext: { [weak self] in
            guard let dateComponents = $0 else {
                self?.selectedDateLabel.text = "???"
                
                return
            }
            
            let date = Calendar.current.date(from: dateComponents)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E dd MMM"
            self?.selectedDateLabel.text = dateFormatter.string(from: date)
        }).disposed(by: disposeBag)
    }
    
    private func loadSelectedTimeOfDayLabel() {
        selectedTimeOfDayLabel = UILabel()
        selectedTimeOfDayLabel.textColor = .green
        viewModel?.timeOfDay.asObservable().subscribe(onNext: { [weak self] in
            guard let dateComponents = $0 else {
                self?.selectedTimeOfDayLabel.text = "???"
                
                return
            }
            
            let date = Calendar.current.date(from: dateComponents)!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            self?.selectedTimeOfDayLabel.text = dateFormatter.string(from: date)
        }).disposed(by: disposeBag)
    }
    
    private func loadShortcutButtons() {
        viewModel?.tomorrowShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.tomorrowShortcutButton.titleLabel?.text = $0
        }).disposed(by: disposeBag)
        
        viewModel?.nextWeekShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextWeekShortcutButton.titleLabel?.text = $0
        }).disposed(by: disposeBag)
        
        viewModel?.nextMonthShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextMonthShortcutButton.titleLabel?.text = $0
        }).disposed(by: disposeBag)
    }
    
    @IBAction func touchUpInsideTomorrowShortcutButton(_ sender: UIButton) {
        viewModel?.selectTomorrow()
    }
    
    @IBAction func touchUpInsideNextWeekShortcutButton(_ sender: UIButton) {
        viewModel?.selectNextWeek()
    }
    
    @IBAction func touchUpInsideNextMonthShortcutButton(_ sender: UIButton) {
        viewModel?.selectNextMonth()
    }
}

extension DateInputViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "DateInputViewController"
    }
    
    static var storyboardIdentifier: String {
        return "DateInput"
    }
}
