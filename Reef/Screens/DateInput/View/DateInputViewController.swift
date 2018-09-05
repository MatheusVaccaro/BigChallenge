//
//  DateSelectorView.swift
//  BigChallenge
//
//  Created by Max Zorzetti on 09/08/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import JTAppleCalendar
import RxSwift
import RxCocoa

class DateInputViewController: UIViewController {
    
    // MARK: - Properties
    
    var viewModel: DateInputViewModelProtocol?
    var dateSelectorViewModel: DateInputViewModelProtocol?
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var dateInputStatusStackView: UIStackView!
    private(set) var selectedDateLabel: ToggleableLabel!
    private(set) var selectedTimeOfDayLabel: ToggleableLabel!
    
    private(set) var currentSelector: BehaviorSubject<DateSelector>!
    @IBOutlet weak var selectorView: UIView!
    
    @IBOutlet weak var calendarContainerView: UIView!
    private var calendarViewController: CalendarViewController!
    private var calendar: JTAppleCalendarView { return calendarViewController.calendar }
    
    @IBOutlet weak var timeOfDaySelector: UIDatePicker!
    
    @IBOutlet weak var dateShortcutsStackView: UIStackView!
    @IBOutlet weak var tomorrowShortcutButton: UIButton!
    @IBOutlet weak var nextWeekShortcutButton: UIButton!
    @IBOutlet weak var nextMonthShortcutButton: UIButton!
    
    @IBOutlet weak var timeOfDayShortcutsStackView: UIStackView!
    @IBOutlet weak var twoHoursFromNowButton: UIButton!
    @IBOutlet weak var thisEveningButton: UIButton!
    @IBOutlet weak var nextMorningButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        currentSelector = BehaviorSubject<DateSelector>(value: .date)
        
        loadSelectedDateLabel()
        loadSelectedTimeOfDayLabel()
        loadDateInputStatusStackView()
        
        loadDateSelectorView()
        loadTimeOfDaySelectorView()
        
        loadShortcutButtons()
        
        currentSelector.subscribe(onNext: { [weak self] in
            self?.displaySelector(ofType: $0)
        }).disposed(by: disposeBag)
        
        print("+++ INIT DateInputViewController")
    }
    
    deinit {
        print("--- DEINIT DateInputViewController")
    }
    
    private func displaySelector(ofType selector: DateSelector) {
        switch selector {
        case .date:
            calendarContainerView.isHidden = false
            dateShortcutsStackView.isHidden = false
            timeOfDaySelector.isHidden = true
            timeOfDayShortcutsStackView.isHidden = true
            
        case .timeOfDay:
            calendarContainerView.isHidden = true
            dateShortcutsStackView.isHidden = true
			timeOfDaySelector.isHidden = false
            timeOfDayShortcutsStackView.isHidden = false
        }
    }
    
    private func loadDateSelectorView() {
        calendarViewController = CalendarViewController.instantiate()
        calendarViewController.delegate = self
        addChildViewController(calendarViewController)
        
        calendarContainerView.addSubview(calendarViewController.view)
        
        let calendarView = calendarViewController.view!
		let constraints = [
            calendarView.rightAnchor.constraint(equalTo: calendarContainerView.rightAnchor),
        	calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
        	calendarView.leftAnchor.constraint(equalTo: calendarContainerView.leftAnchor),
        	calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)]
        NSLayoutConstraint.activate(constraints)
        
        viewModel?.date.asObservable()
            .map { dateComponent in
            	Calendar.current.date(from: dateComponent)
        	}
            .subscribe(onNext: { [weak self] in
                if let date = $0 {
                    self?.calendar.scrollToHeaderForDate(date, withAnimation: true) {
                        self?.calendar.selectDates([date], triggerSelectionDelegate: false)
                    }
                    
                } else {
                    self?.calendar.selectDates([], triggerSelectionDelegate: false)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func loadTimeOfDaySelectorView() {
        timeOfDaySelector.addTarget(self, action: #selector(handleTimeOfDaySelectorChange(_:)), for: .valueChanged)
        
        viewModel?.timeOfDay.asObservable()
            .map { dateComponent in
            	Calendar.current.date(from: dateComponent)
        	}
            .subscribe(onNext: { [weak self] in
                if let date = $0 {
                    self?.timeOfDaySelector.setDate(date, animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    @objc func handleTimeOfDaySelectorChange(_ datePicker: UIDatePicker) {
        let pickedDate = datePicker.date
        let dateComponents = Calendar.current.dateComponents([.hour, .minute], from: pickedDate)
        
        viewModel?.selectTimeOfDay(dateComponents)
    }
    
    private func loadSelectedDateLabel() {
        selectedDateLabel = ToggleableLabel()
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(touchUpInsideSelectedDateLabel))
        selectedDateLabel.addGestureRecognizer(tapRecognizer)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Strings.DateInputView.selectedDateFormat
        
        viewModel?.date.asObservable()
            .subscribe(onNext: { [weak self] in
                if let dateComponents = $0,
                   let date = Calendar.current.date(from: dateComponents) {
                    
                    let selectedDateText = dateFormatter.string(from: date)
                    self?.selectedDateLabel.text = " \(selectedDateText) "
                    
                } else {
                    self?.selectedDateLabel.text = " ??? "
                }
            })
            .disposed(by: disposeBag)
        
        currentSelector
            .subscribe(onNext: { [weak self] in
            	self?.selectedDateLabel.isToggled = ($0 == .date)
        	})
            .disposed(by: disposeBag)
    }
    
    @objc func touchUpInsideSelectedDateLabel() {
        currentSelector.onNext(.date)
    }
    
    private func loadSelectedTimeOfDayLabel() {
        selectedTimeOfDayLabel = ToggleableLabel()
        
        let tapRecognizer = UITapGestureRecognizer(target: self,
                                                   action: #selector(touchUpInsideSelectedTimeOfDayButton))
        selectedTimeOfDayLabel.addGestureRecognizer(tapRecognizer)
        
        viewModel?.timeOfDay.asObservable()
            .subscribe(onNext: { [weak self] in
                if let dateComponents = $0,
                   let date = Calendar.current.date(from: dateComponents) {
                    
                    let selectedTimeOfDayText = DateFormatter.localizedString(from: date,
                                                                              dateStyle: .none, timeStyle: .short)
                    self?.selectedTimeOfDayLabel.text = " \(selectedTimeOfDayText) "
                    
                } else {
                    self?.selectedTimeOfDayLabel.text = " ??? "
                }
        	})
            .disposed(by: disposeBag)
        
        currentSelector
            .subscribe(onNext: { [weak self] in
            	self?.selectedTimeOfDayLabel.isToggled = ($0 == .timeOfDay)
        	})
            .disposed(by: disposeBag)
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
                dateInputStatusStackView.addArrangedSubview(selectedDateLabel)
                
            case "timeofday":
                dateInputStatusStackView.addArrangedSubview(selectedTimeOfDayLabel)
                
            default:
                let label = UILabel()
                label.text = dateInputStackDescriptor
                dateInputStatusStackView.addArrangedSubview(label)
            }
        }
        
        let spacerView = UIView()
        spacerView.setContentHuggingPriority(.defaultLow, for: .horizontal)
        spacerView.backgroundColor = .clear
        dateInputStatusStackView.addArrangedSubview(spacerView)
    }
    
    private func loadShortcutButtons() {
        configure([tomorrowShortcutButton, nextWeekShortcutButton, nextMonthShortcutButton])
        // RXSwift binding
        viewModel?.tomorrowShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.tomorrowShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.nextWeekShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextWeekShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
        
        viewModel?.nextMonthShortcutText.asObservable().subscribe(onNext: { [weak self] in
            self?.nextMonthShortcutButton.setTitle($0, for: .normal)
        }).disposed(by: disposeBag)
        
        configure([twoHoursFromNowButton, thisEveningButton, nextMorningButton])
        // RXCocoa binding - looks way cleaner!
        viewModel?.twoHoursFromNowShortcutText.asObserver()
            .bind(to: twoHoursFromNowButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel?.thisEveningShortcutText.asObserver()
        	.bind(to: thisEveningButton.rx.title(for: .normal))
            .disposed(by: disposeBag)
        
        viewModel?.nextMorningShortcutText.asObserver()
        	.bind(to: nextMorningButton.rx.title(for: .normal))
        	.disposed(by: disposeBag)
    }
    
    private func configure(_ shortcutButtons: [UIButton]) {
        shortcutButtons.forEach { self.configure($0) }
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
    
    @IBAction func touchUpInsideTwoHoursFromNowShortcutButton(_ sender: UIButton) {
        viewModel?.selectTwoHoursFromNow()
    }
    
    @IBAction func touchUpInsideThisEveningShortcutButton(_ sender: UIButton) {
        viewModel?.selectThisEvening()
    }
    
    @IBAction func touchUpInsideNextMorningShortcutButton(_ sender: UIButton) {
        viewModel?.selectNextMorning()
    }
    
    enum DateSelector {
    	case date
        case timeOfDay
    }
}

extension DateInputViewController: CalendarDelegate {
    
    func calendar(_ calendar: JTAppleCalendarView, didSelectDate date: Date, cell: JTAppleCell?, cellState: CellState) {
        guard let calendarCell = cell as? CalendarCell else { return }
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        viewModel?.selectDate(dateComponents)
        
        calendarCell.select()
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
