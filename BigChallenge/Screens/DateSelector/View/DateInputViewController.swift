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
    private(set) var selectedDateButton: DateStatusButton!
    private(set) var selectedTimeOfDayButton: DateStatusButton!
    
    private(set) var currentSelector: BehaviorSubject<DateSelector>!
    
    @IBOutlet weak var dateShortcutsStackView: UIStackView!
    @IBOutlet weak var tomorrowShortcutButton: UIButton!
    @IBOutlet weak var nextWeekShortcutButton: UIButton!
    @IBOutlet weak var nextMonthShortcutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSelector = BehaviorSubject<DateSelector>(value: .date)
        
        loadSelectedDateLabel()
        loadSelectedTimeOfDayLabel()
        loadDateInputStatusStackView()
        loadShortcutButtons()
        
        currentSelector.subscribe(onNext: { [weak self] in
            self?.displaySelector(ofType: $0)
        }).disposed(by: disposeBag)
    }
    
    private func displaySelector(ofType selector: DateSelector) {
        switch selector {
        case .date:

            break
            
        case .timeOfDay:

            break
        }
    }
    
    private func loadSelectedDateLabel() {
        selectedDateButton = DateStatusButton()
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(touchUpInsideSelectedDateButton))
        selectedDateButton.addGestureRecognizer(tapRecognizer)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E dd MMM" // TODO Localize date format
        
        viewModel?.date.asObservable().subscribe(onNext: { [weak self] in
            
            if let dateComponents = $0,
                let date = Calendar.current.date(from: dateComponents) {
                
                self?.selectedDateButton.text = dateFormatter.string(from: date)
                
            } else {
                self?.selectedDateButton.text = "???"
            }
        
        }).disposed(by: disposeBag)
        
        currentSelector.subscribe(onNext: { [weak self] in
            self?.selectedDateButton.isToggled = ($0 == .date)
        }).disposed(by: disposeBag)
    }
    
    @objc func touchUpInsideSelectedDateButton() {
        currentSelector.onNext(.date)
    }
    
    private func loadSelectedTimeOfDayLabel() {
        selectedTimeOfDayButton = DateStatusButton()
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(touchUpInsideSelectedTimeOfDayButton))
        selectedTimeOfDayButton.addGestureRecognizer(tapRecognizer)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm" //TODO Localize time of day format
        
        viewModel?.timeOfDay.asObservable().subscribe(onNext: { [weak self] in
            
            if let dateComponents = $0,
               let date = Calendar.current.date(from: dateComponents) {
                
                self?.selectedTimeOfDayButton.text = dateFormatter.string(from: date)
                
            } else {
                self?.selectedTimeOfDayButton.text = "???"
            }
            
        }).disposed(by: disposeBag)
        
        currentSelector.subscribe(onNext: { [weak self] in
            self?.selectedTimeOfDayButton.isToggled = ($0 == .timeOfDay)
        }).disposed(by: disposeBag)
    }
    
    @objc func touchUpInsideSelectedTimeOfDayButton() {
        currentSelector.onNext(.timeOfDay)
    }

    private func loadDateInputStatusStackView() {
        let dateInputStatusFormat = Strings.DateInputView.dateInputStatus
        
        let dateInputStackDescriptors = dateInputStatusFormat.components(separatedBy: "@").filter { !$0.isEmpty }
        
        for dateInputStackDescriptor in dateInputStackDescriptors {
            
            switch dateInputStackDescriptor {
            case "date":
                dateInputStatusStackView.addArrangedSubview(selectedDateButton)
                
            case "timeofday":
                dateInputStatusStackView.addArrangedSubview(selectedTimeOfDayButton)
                
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
    
    enum DateSelector {
    	case date
        case timeOfDay
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
