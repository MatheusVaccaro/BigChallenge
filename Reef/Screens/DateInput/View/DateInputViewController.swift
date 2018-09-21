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
    
    var viewModel: DateInputViewModelProtocol!
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var selectedCalendarDateDayLabel: UILabel!
    @IBOutlet weak var selectedCalendarDateDayLabelWidth: NSLayoutConstraint!
    @IBOutlet weak var selectedCalendarDateDayLabelHeight: NSLayoutConstraint!
    @IBOutlet weak var selectedCalendarDateMonthLabel: UILabel!
    private(set) var selectedTimeOfDayLabel: ToggleableLabel!
    
    @IBOutlet weak var prepositionLabel: UILabel!
    
    private(set) var currentSelector: BehaviorSubject<DateSelector>!
    
    @IBOutlet weak var calendarContainerView: UIView!
    private var calendarViewController: CalendarViewController!
    private var calendar: JTAppleCalendarView { return calendarViewController.calendar }
    
    @IBOutlet weak var timeOfDaySelector: UIDatePicker!
    
    @IBOutlet weak var dateShortcutsStackView: UIStackView!
    @IBOutlet weak var tomorrowShortcutButton: UIButton!
    @IBOutlet weak var nextWeekShortcutButton: UIButton!
    @IBOutlet weak var nextMonthShortcutButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        currentSelector = BehaviorSubject<DateSelector>(value: .date)
        
        configureCalendarDateLabels()
        configurePrepositionLabel()
        loadSelectedTimeOfDayLabel()
        loadDateSelectorView()
        loadTimeOfDaySelectorView()
        loadShortcutButtons()
        
        #if DEBUG
        print("+++ INIT DateInputViewController")
        #endif
    }
    
    #if DEBUG
    deinit {
        print("--- DEINIT DateInputViewController")
    }
    #endif
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        view.setNeedsLayout()
//        disposeBag = DisposeBag()
//        loadSelectedTimeOfDayLabel()
//        loadDateSelectorView()
//        loadTimeOfDaySelectorView()
//        loadShortcutButtons()
    }
    
    private func configureCalendarDateLabels() {
        let calendarDate = viewModel.calendarDate
            .map { calendarDateComponent -> Date in
                guard let date = Calendar.current.date(from: calendarDateComponent) else {
                    throw NSError(domain: "Invalid calendar date component", code: 0, userInfo: nil)
                }
                return date
        	}
        
        // Day Label
        selectedCalendarDateDayLabel.textColor = UIColor.DateInput.defaultColor
        let dayDateFormatter = DateFormatter()
        dayDateFormatter.locale = Locale.current
        dayDateFormatter.dateFormat = "dd"
        calendarDate
            .map { dayDateFormatter.string(from: $0) }
            .bind(to: selectedCalendarDateDayLabel.rx.text)
            .disposed(by: disposeBag)
        
        // Month Label
        selectedCalendarDateMonthLabel.textColor = UIColor.DateInput.defaultColor
        let monthDateFormatter = DateFormatter()
        monthDateFormatter.locale = Locale.current
        monthDateFormatter.dateFormat = "MMMM"
        calendarDate
            .map { monthDateFormatter.string(from: $0).uppercased()	}
        	.bind(to: selectedCalendarDateMonthLabel.rx.text)
        	.disposed(by: disposeBag)
    }
    
    private func configurePrepositionLabel() {
        prepositionLabel.textColor = UIColor.DateInput.defaultColor
    }
    
    private func loadDateSelectorView() {
        calendarViewController = CalendarViewController.instantiate()
        calendarViewController.delegate = self
        addChild(calendarViewController)
        
        calendarContainerView.addSubview(calendarViewController.view)
        
        let calendarView = calendarViewController.view!
		let constraints = [
            calendarView.rightAnchor.constraint(equalTo: calendarContainerView.rightAnchor),
        	calendarView.topAnchor.constraint(equalTo: calendarContainerView.topAnchor),
        	calendarView.leftAnchor.constraint(equalTo: calendarContainerView.leftAnchor),
        	calendarView.bottomAnchor.constraint(equalTo: calendarContainerView.bottomAnchor)]
        NSLayoutConstraint.activate(constraints)
        
        viewModel?.calendarDate.asObservable()
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
            .subscribe(onNext: { [weak self] currentSelector in
            	self?.selectedTimeOfDayLabel.isToggled = (currentSelector == .timeOfDay)
        	})
            .disposed(by: disposeBag)
    }
    
    @objc func touchUpInsideSelectedTimeOfDayButton() {
        currentSelector.onNext(.timeOfDay)
    }
    
    private func loadShortcutButtons() {
//        configure([tomorrowShortcutButton, nextWeekShortcutButton, nextMonthShortcutButton])
//        // RXSwift binding
//        viewModel?.tomorrowShortcutText.asObservable().subscribe(onNext: { [weak self] in
//            self?.tomorrowShortcutButton.setTitle($0, for: .normal)
//        }).disposed(by: disposeBag)
//        
//        viewModel?.nextWeekShortcutText.asObservable().subscribe(onNext: { [weak self] in
//            self?.nextWeekShortcutButton.setTitle($0, for: .normal)
//        }).disposed(by: disposeBag)
//        
//        viewModel?.nextMonthShortcutText.asObservable().subscribe(onNext: { [weak self] in
//            self?.nextMonthShortcutButton.setTitle($0, for: .normal)
//        }).disposed(by: disposeBag)
    }
    
    private func configure(_ shortcutButtons: [UIButton]) {
        shortcutButtons.forEach { self.configure($0) }
    }
    private func configure(_ shortcutButton: UIButton) {
        let shortcutButtonFont = UIFont.font(sized: 18, weight: .medium, with: .body)
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
        viewModel?.selectCalendarDate(dateComponents)
        
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


extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}
