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

class DateInputTests: QuickSpec {
    
    override func spec() {
        describe("a DateSelectorViewModel") {
            
            var dateSelectorViewModel: DateInputViewModel!
            var mockDateSelectorDelegate: DateSelectorMockDelegate!
            
            beforeEach {
                dateSelectorViewModel = DateInputViewModel()
                mockDateSelectorDelegate = DateSelectorMockDelegate()
                dateSelectorViewModel.delegate = mockDateSelectorDelegate
                DateGenerator.shared = DateGenerator(currentDate: Date())
            }
            
            context("when selecting a date") {
                
                beforeEach {
                    let mockDate = DateComponents(year: 2018, month: 09, day: 09)
                    
                    dateSelectorViewModel.selectDate(mockDate)
                }
                
                it("should store day, month and year data") {
                    let dateData = dateSelectorViewModel.date.value
                    let dayData = dateData?.day
                    let monthData = dateData?.month
                    let yearData = dateData?.year
                    
                    expect(dayData).toNot(beNil())
                    expect(monthData).toNot(beNil())
                    expect(yearData).toNot(beNil())
                }
                
                it("should store valid date data") {
                    let dateData = dateSelectorViewModel.date.value

                    expect(dateData?.isValidDate(in: Calendar.current)).to(beTrue())
                }
                
                it("should notify its delegate about it") {
                    let internalDate = dateSelectorViewModel.date.value
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
                    let timeOfDayData = dateSelectorViewModel.timeOfDay.value
                    
                    let hourData = timeOfDayData?.hour
                    let minuteData = timeOfDayData?.minute
                    
                    expect(hourData).toNot(beNil())
                    expect(minuteData).toNot(beNil())
                }
                
                it("should store valid data") {
                    let timeOfDayData = dateSelectorViewModel.timeOfDay.value
                    
                    expect(timeOfDayData?.isValidDate(in: Calendar.current)).to(beTrue())
                }
                
                it("should notify its delegate about it") {
                    let internalTimeOfDay = dateSelectorViewModel.timeOfDay.value
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
                    guard let internalDate = dateSelectorViewModel.date.value,
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
                    guard let internalDate = dateSelectorViewModel.date.value,
                          let selectedDate = Calendar.current.date(from: internalDate) else { fail("DateSelectorViewModel internal date data after selecting next month was nil."); return }
                    
                    guard let sameWeekdayOfTodayInNextWeek = Calendar.current.date(byAdding: DateComponents(day: 7), to: Date.now()) else { fail("Error when creating a date 7 days from now."); return }
                    
                    let isSelectedDateTheSameWeekdayOfTodayButInNextWeek = Calendar.current.isDate(selectedDate, inSameDayAs: sameWeekdayOfTodayInNextWeek)
                    
                    expect(isSelectedDateTheSameWeekdayOfTodayButInNextWeek).to(beTrue())
                }
            }
            
            context("when selecting the next month") {
                
                beforeEach {
                    dateSelectorViewModel.selectNextMonth()
                }
                
                it("should select the date equal to thirty days after today") {
                    guard let internalDate = dateSelectorViewModel.date.value,
                          let selectedDate = Calendar.current.date(from: internalDate) else { fail("DateSelectorViewModel internal date data after selecting next month was nil."); return }
                    
                    guard let thirtyDaysAfterToday = Calendar.current.date(byAdding: DateComponents(day: 30), to: Date.now()) else { fail("Error when creating a date thirty days from now."); return }
                    
                    let isSelectedDateEqualToThirtyDaysAfterToday = Calendar.current.isDate(selectedDate, equalTo: thirtyDaysAfterToday, toGranularity: Calendar.Component.day)
                    
                    expect(isSelectedDateEqualToThirtyDaysAfterToday).to(beTrue())
                }
            }
            
            context("when selecting two hours from now") {
                
                beforeEach {
                    dateSelectorViewModel.selectTwoHoursFromNow()
                }
                
                it("should select the date equal to two hour from now") {
                    guard let internalDate = dateSelectorViewModel.date.value,
                        let internalTime = dateSelectorViewModel.timeOfDay.value,
                        let selectedDate = Calendar.current.combine(date: internalDate, andTimeOfDay: internalTime) else {
                            fail("DateSelectorViewModel internal date data after selecting two hours from now was nil.")
                            return
                    }
                    
                    guard let twoHoursFromNow = Calendar.current.date(byAdding: DateComponents(hour: 2), to: Date.now()) else { fail("Error when creating a date two hours from now."); return }
                    
                    let isSelectedDateEqualToTwoHoursFromNow = Calendar.current.isDate(selectedDate, equalTo: twoHoursFromNow, toGranularity: Calendar.Component.hour)
                    
                    expect(isSelectedDateEqualToTwoHoursFromNow).to(beTrue())
                }
            }
            
            context("when selecting this evening") {
                
                context("and it's earlier than 8 PM") {
                    
                    beforeEach {
                        let earlierThan8PM = Calendar.current.date(bySettingHour: 19, minute: 0, second: 0, of: Date())!
                        DateGenerator.shared = DateGenerator(currentDate: earlierThan8PM)
                        
                        dateSelectorViewModel.selectThisEvening()
                    }
                    
                    it("should select today at 8 PM") {
                        guard let internalDate = dateSelectorViewModel.date.value,
                            let internalTime = dateSelectorViewModel.timeOfDay.value,
                            let selectedDate = Calendar.current.combine(date: internalDate, andTimeOfDay: internalTime) else {
                                fail("DateInputViewModel internal date data after selecting this evening was nil.")
                                return
                        }
                        
                        guard let thisEvening = Calendar.current.date(bySettingHour: 20, minute: 0, second: 0, of: Date.now()) else { fail("Error when creating a date for this evening."); return }
                        
                        expect(selectedDate).to(equal(thisEvening))
                    }
                }
                
                context("and it's after 8 PM") {
                    
                    beforeEach {
                        let after8PM = Calendar.current.date(bySettingHour: 21, minute: 0, second: 0, of: Date())!
                        DateGenerator.shared = DateGenerator(currentDate: after8PM)
                        
                        dateSelectorViewModel.selectThisEvening()
                    }
                    
                    it("should select 1 hour from now") {
                        guard let internalDate = dateSelectorViewModel.date.value,
                            let internalTime = dateSelectorViewModel.timeOfDay.value,
                            let selectedDate = Calendar.current.combine(date: internalDate, andTimeOfDay: internalTime) else {
                                fail("DateInputViewModel internal date data after selecting this evening was nil.")
                                return
                        }
                        
                        guard let oneHourFromNow = Calendar.current.date(byAdding: .hour, value: 1, to: Date.now()) else { fail("Error when creating a date one hour from now."); return }
                        
                        let isSelectedDateEqualToOneHourFromNow = Calendar.current.isDate(selectedDate, equalTo: oneHourFromNow, toGranularity: Calendar.Component.hour)
                        
                        expect(isSelectedDateEqualToOneHourFromNow).to(beTrue())
                    }
                }
            }
            
            context("when selecting next morning") {
                
                context("and it's earlier than 8 AM") {
                    
                    beforeEach {
                        let earlierThan8AM = Calendar.current.date(bySettingHour: 7, minute: 0, second: 0, of: Date())!
                        DateGenerator.shared = DateGenerator(currentDate: earlierThan8AM)
                        
                        dateSelectorViewModel.selectNextMorning()
                    }
                    
                    it("should select today at 8 AM") {
                        guard let internalDate = dateSelectorViewModel.date.value,
                            let internalTime = dateSelectorViewModel.timeOfDay.value,
                            let selectedDate = Calendar.current.combine(date: internalDate, andTimeOfDay: internalTime) else {
                                fail("DateInputViewModel internal date data after selecting next morning was nil.")
                                return
                        }

                        guard let nextMorning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date.now()) else { fail("Error when creating a date for this evening."); return }
                        
                        expect(selectedDate).to(equal(nextMorning))
                    }
                }
                
                context("and it's after 8 AM") {
                    
                    beforeEach {
                        let after8AM = Calendar.current.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
                        DateGenerator.shared = DateGenerator(currentDate: after8AM)
                        
                        dateSelectorViewModel.selectNextMorning()
                    }
                    
                    it("should select tomorrow at 8 AM") {
                        guard let internalDate = dateSelectorViewModel.date.value,
                            let internalTime = dateSelectorViewModel.timeOfDay.value,
                            let selectedDate = Calendar.current.combine(date: internalDate, andTimeOfDay: internalTime) else {
                                fail("DateInputViewModel internal date data after selecting this morning was nil.")
                                return
                        }
                        
                        
                        guard let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date.now()),
                            let tomorrowMorning = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: tomorrow) else {
                                fail("Error when creating the date of tomorrow morning.")
                                return
                        }
                        
                        expect(selectedDate).to(equal(tomorrowMorning))
                    }
                }
            }
        }
    }
}

class DateSelectorMockDelegate: DateInputViewModelDelegate {

    var providedNotificationOptions: NotificationOptions?
    var providedDate: DateComponents?
    var providedTimeOfDay: DateComponents?
    var providedFrequency: NotificationOptions.Frequency?
    
    func dateSelectorViewModel(_ dateSelectorViewModel: DateInputViewModelProtocol, didFinishSelecting notificationOptions: NotificationOptions) {
        providedNotificationOptions = notificationOptions
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectDate date: DateComponents) {
        providedDate = date
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectTimeOfDay timeOfDay: DateComponents) {
        providedTimeOfDay = timeOfDay
    }
    
    func dateInputViewModel(_ dateInputViewModel: DateInputViewModelProtocol, didSelectFrequency frequency: NotificationOptions.Frequency) {
        providedFrequency = frequency
    }
}
