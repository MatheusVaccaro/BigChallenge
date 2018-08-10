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
    
    @IBOutlet weak var dateInputStatusStackView: UIStackView!
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
        loadDateInputStatusStackView()
        loadShortcutButtons()
    }
    
    private func loadSelectedDateLabel() {
        selectedDateLabel = UILabel()
        selectedDateLabel.layer.masksToBounds = true
        selectedDateLabel.layer.cornerRadius = 4.3
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM"
        
        viewModel?.date.asObservable().subscribe(onNext: { [weak self] in
            
            if let dateComponents = $0,
                let date = Calendar.current.date(from: dateComponents) {
                
                self?.selectedDateLabel.text = dateFormatter.string(from: date)
                
            } else {
                self?.selectedDateLabel.text = "???"
            }
        
        }).disposed(by: disposeBag)
    }
    
    private func loadSelectedTimeOfDayLabel() {
        selectedTimeOfDayLabel = UILabel()
        selectedTimeOfDayLabel.font = UIFont.font(sized: 19.77, weight: .semibold, with: .body)
        selectedTimeOfDayLabel.textColor = UIColor.DateInput.defaultColor
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" //TODO Localize time of day format
        
        viewModel?.timeOfDay.asObservable().subscribe(onNext: { [weak self] in
            
            if let dateComponents = $0,
               let date = Calendar.current.date(from: dateComponents) {
                
                self?.selectedTimeOfDayLabel.text = dateFormatter.string(from: date)
                
            } else {
                self?.selectedTimeOfDayLabel.text = "???"
            }
            
        }).disposed(by: disposeBag)
    }
    
    private func loadDateInputStatusStackView() {
        let dateInputStatusFormat = Strings.DateInputView.dateInputStatus
        
        let dateInputStackDescriptors = dateInputStatusFormat.components(separatedBy: "@").filter { !$0.isEmpty }
        
        for dateInputStackDescriptor in dateInputStackDescriptors {
            
            switch dateInputStackDescriptor {
            case "date":
                dateInputStatusStackView.addArrangedSubview(selectedDateLabel)
                
            case "timeofday":
                dateInputStatusStackView.addArrangedSubview(selectedTimeOfDayLabel)
                
            default:
                let label = UILabel()
                label.text = dateInputStackDescriptor
                dateInputStatusStackView.addArrangedSubview(label)
            }
        }
    }
    
    private func loadShortcutButtons() {
        configure(tomorrowShortcutButton)
        configure(nextWeekShortcutButton)
        configure(nextMonthShortcutButton)
        
        viewModel?.tomorrowShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.tomorrowShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.nextWeekShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextWeekShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.nextMonthShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextMonthShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
    }
    
    private func configure(_ shortcutButton: UIButton) {
        let shortcutButtonFont = UIFont.font(sized: 19.77, weight: .semibold, with: .body)
        shortcutButton.titleLabel?.font = shortcutButtonFont
        shortcutButton.tintColor = UIColor.DateInput.shortcutButtonsColor
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
