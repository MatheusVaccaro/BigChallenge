//
//  TaskDateInputTests.swift
//  BigChallengeTests
//
//  Created by Max Zorzetti on 31/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Quick
import Nimble

@testable
import BigChallenge

class DateSelectTests: QuickSpec {
    
    override func spec() {
        describe("a DateSelectorViewModel") {
            
            var dateSelectorViewModel: DateSelectorViewModel!
            var mockDateSelectorDelegate: DateSelectorMockDelegate!
            
            beforeEach {
                dateSelectorViewModel = DateSelectorViewModel()
                mockDateSelectorDelegate = DateSelectorMockDelegate()
                dateSelectorViewModel.delegate = mockDateSelectorDelegate
            }
            
            context("when selecting a date") {
                
                beforeEach {
                    let mockDate = DateComponents(year: 2018, month: 09, day: 09)
                    
                    dateSelectorViewModel.selectDate(mockDate)
                }
                
                it("should store day, month and year data") {
                    let dateData = dateSelectorViewModel.date
                    let dayData = dateData?.day
                    let monthData = dateData?.month
                    let yearData = dateData?.year
                    
                    expect(dayData).toNot(beNil())
                    expect(monthData).toNot(beNil())
                    expect(yearData).toNot(beNil())
                }
                
                it("should store valid date data") {
                    let dateData = dateSelectorViewModel.date

                    expect(dateData?.isValidDate).to(beTrue())
                }
                
                it("should notify its delegate about it") {
                    let internalDate = dateSelectorViewModel.date
                    let providedDate = mockDateSelectorDelegate.providedDate
                    
                    expect(providedDate).toNot(beNil())
                    expect(providedDate).to(equal(internalDate))
                }
            }
            
            context("when selecting a time of day") {
                
                beforeEach {
                    let mockTimeOfDay = DateComponents(hour: 09, minute: 09)
                    
                    dateSelectorViewModel.selectTimeOfDay(mockTimeOfDay)
                }
                
                it("should store hour and minute data") {
                    let timeOfDayData = dateSelectorViewModel.timeOfDay
                    
                    let hourData = timeOfDayData?.hour
                    let minuteData = timeOfDayData?.minute
                    
                    expect(hourData).toNot(beNil())
                    expect(minuteData).toNot(beNil())
                }
                
                it("should store valid data") {
                    let timeOfDayData = dateSelectorViewModel.timeOfDay
                    
                    expect(timeOfDayData?.isValidDate).to(beTrue())
                }
                
                it("should notify its delegate about it") {
                    let internalTimeOfDay = dateSelectorViewModel.timeOfDay
                    let providedTimeOfDay = mockDateSelectorDelegate.providedTimeOfDay
                    
                    expect(providedTimeOfDay).toNot(beNil())
                    expect(providedTimeOfDay).to(equal(internalTimeOfDay))
                }
            }
            
            context("when selecting a frequency") {
                
                beforeEach {
                    let mockFrequency = NotificationOptions.Frequency.monthly
                    
                    dateSelectorViewModel.select(frequency: mockFrequency)
                }
                
                it("should store frequency data") {
                    let frequencyData = dateSelectorViewModel.frequency
                    
                    expect(frequencyData).toNot(beNil())
                }
                
                it("should notify its delegate about it") {
                    let providedFrequency = mockDateSelectorDelegate.providedFrequency
                    
                    expect(providedFrequency).toNot(beNil())
                }
            }
            
            context("when selecting the following day (i.e. tomorrow)") {
                
                beforeEach {
                    dateSelectorViewModel.selectTomorrow()
                }
                
                it("should select the day after today") {
                    guard let internalDate = dateSelectorViewModel.date,
                          let selectedDate = Calendar.current.date(from: internalDate) else { fail("DateSelectorViewModel internal date data after selecting tomorrow was nil."); return }
                    
                    let isSelectedDateInTomorrow = Calendar.current.isDateInTomorrow(selectedDate)
                    expect(isSelectedDateInTomorrow).to(beTrue())
                }
            }
            
            context("when selecting next week") {
				
                beforeEach {
                    dateSelectorViewModel.selectNextWeek()
                }
                
                it("should select a date equal to the same weekday of today, but in the next week") {
                    guard let internalDate = dateSelectorViewModel.date,
                          let selectedDate = Calendar.current.date(from: internalDate) else { fail("DateSelectorViewModel internal date data after selecting next month was nil."); return }
                    
                    guard let sameWeekdayOfTodayInNextWeek = Calendar.current.date(byAdding: DateComponents(day: 7), to: Date()) else { fail("Error when creating a date 7 days from now."); return }
                    
                    let isSelectedDateTheSameWeekdayOfTodayButInNextWeek = Calendar.current.isDate(selectedDate, inSameDayAs: sameWeekdayOfTodayInNextWeek)
                    
                    expect(isSelectedDateTheSameWeekdayOfTodayButInNextWeek).to(beTrue())
                }
            }
            
            context("when selecting the next month") {
                
                beforeEach {
                    dateSelectorViewModel.selectNextMonth()
                }
                
                it("should select the date equal to thirty days after today") {
                    guard let internalDate = dateSelectorViewModel.date,
                          let selectedDate = Calendar.current.date(from: internalDate) else { fail("DateSelectorViewModel internal date data after selecting next month was nil."); return }
                    
                    guard let thirtyDaysAfterToday = Calendar.current.date(byAdding: DateComponents(day: 30), to: Date()) else { fail("Error when creating a date thirty days from now."); return }
                    
                    let isSelectedDateEqualToThirtyDaysAfterToday = Calendar.current.isDate(selectedDate, equalTo: thirtyDaysAfterToday, toGranularity: Calendar.Component.day)
                    
                    expect(isSelectedDateEqualToThirtyDaysAfterToday).to(beTrue())
                }
            }
            
            context("when selecting the date selector") {
                
                beforeEach {
                    dateSelectorViewModel.showDateSelector()
                }
                
                it("should display the date selector") {
                    let currentSelector = dateSelectorViewModel.currentSelector
                    
                    expect(currentSelector).to(equal(.date))
                }
            }
            
            context("when selecting the time of day selector") {
                
                beforeEach {
                    dateSelectorViewModel.showDateSelector()
                }
                
                it("should display the time of day selector") {
                    let currentSelector = dateSelectorViewModel.currentSelector
                    
                    expect(currentSelector).to(equal(.timeOfDay))
                }
            }
        }
    }
}

class DateSelectorMockDelegate: DateSelectorViewModelDelegate {

    var providedNotificationOptions: NotificationOptions?
    var providedDate: DateComponents?
    var providedTimeOfDay: DateComponents?
    var providedFrequency: NotificationOptions.Frequency?
    
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didFinishSelecting notificationOptions: NotificationOptions) {
        providedNotificationOptions = notificationOptions
    }
    
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectDate date: DateComponents) {
        providedDate = date
    }
    
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents) {
        providedTimeOfDay = timeOfDay
    }
    
    func dateSelectorViewModel(_ dateSelectorViewModel: DateSelectorViewModelProtocol, didSelect frequency: NotificationOptions.Frequency) {
        providedFrequency = frequency
    }
}
