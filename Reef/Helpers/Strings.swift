//
//  localizationKeys.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 25/06/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

//swiftlint:disable nesting
//swiftlint:disable type_name
//swiftlint:disable line_length

import Foundation

struct Strings {
    
    struct HomeScreen {
        struct EmptyState {
            static let title =
                NSLocalizedString("emptyStateTitle", comment: "title of empty state on taskList")
            static let subtitle =
                NSLocalizedString("emptyStateSubtitle", comment: "subtitle of empty state on taskList")
            static let or =
                NSLocalizedString("emptyStateOr", comment: "'or'")
            static let importFromReminders =
                NSLocalizedString("importFromReminders", comment: "button that imports tasks from reminders")
        }
    }
    
    struct Task {
        
        struct CreationScreen {
            static let taskTitlePlaceholder =
                NSLocalizedString("newTaskTitle", comment: "placeholder title for a new task")
            static let taskDescriptionPlaceholder =
                NSLocalizedString("newTaskDescriptionPlaceholder", comment: "placeholder title for a new task description")
        }
        
        struct ListScreen {
            static let recommendedHeaderTitle =
                NSLocalizedString("recommendedHeaderTitle", comment: "header title for 'recommended' section ")
            
            static let section2HeaderTitle =
                NSLocalizedString("section2HeaderTitle", comment: "header title for 'also tagged:' section ")
        }
    }
    
    struct Tag {
        
        static let privateTagUnlockReason =
            NSLocalizedString("faceIDPermisson", comment: "prompt when requesting faceID to unlock private tag")
        
        struct CreationScreen {
            static let tagTitlePlaceholder =
                NSLocalizedString("newTagTitlePlaceHolder", comment: "placeholder title for a new tag")
            static let tagDescriptionPlaceholder =
                NSLocalizedString("newTagDescriptionPlaceholder", comment: "placeholder title for a new tag description")
        }
        
        struct CollectionScreen {
            static let title = NSLocalizedString("collectionScreenTitle", comment: "screen title when on \"all tags\" screen")
            static let updateActionTitle = NSLocalizedString("updateActionTitle", comment: "update button title on edit action sheet")
            static let deleteActionTitle = NSLocalizedString("deleteActionTitle", comment: "delete button title on edit action sheet")
            static let cancelActionTitle = NSLocalizedString("cancelActionTitle", comment: "cancel button title on edit action sheet")
        }
    }
    
    struct DateInputView {
        static let dateInputStatus = NSLocalizedString("dateInputStatusDateInput",
                                                       comment: "text displaying the current selected date and time of day")
        
        static let selectedDateFormat = NSLocalizedString("selectedDateFormatStatusDateInput",
                                                          comment: "format for displaying the currently selected date")
        
        static let tomorrowShortcut = NSLocalizedString("tomorrowShortcutDateInput",
                                                        comment: "text for tomorrow shortcut button")
        
        static let nextWeekShortcut = NSLocalizedString("nextWeekShortcutDateInput",
                                                        comment: "text for next week shortcut button")
        
        static let nextMonthShortcut = NSLocalizedString("nextMonthShortcutDateInput",
                                                        comment: "text for next month shortcut button")
        
        static let twoHoursFromNowShortcut = NSLocalizedString("twoHoursFromNowShortcutDateInput",
                                                         comment: "text for two hours for now shortcut button")
        
        static let thisEveningShortcut = NSLocalizedString("thisEveningShortcutDateInput",
                                                         comment: "text for this evening shortcut button")
        
        static let nextMorningShortcut = NSLocalizedString("nextMorningShortcutDateInput",
                                                         comment: "text for next morning shortcut button")
    }
    
    struct LocationInputView {
        static let arrivingString = NSLocalizedString("arrivingLocationInputView",
                                                      comment: "string for selecting arriving location")
        
        static let leavingString = NSLocalizedString("leavingLocationInputView",
                                                     comment: "String for selecting leaving location")
        
        static let searchBarPlaceholder = NSLocalizedString("searchBarPlaceholder", comment: "placeHolder for searchBar that searches locations")
        
        static let defaultPlaceName = NSLocalizedString("defaultPlaceName", comment: "default place when reading location name in voiceOver")
        
        struct VoiceOver {
            static let mapLabel = NSLocalizedString("mapViewAccessibilitylabel",
                                                    comment: "description of map to voiceOver users")
            
            static let mapValue = NSLocalizedString("%@ meters from %@",
                                                    comment: "accessibility value on map for voiceOver users")
            
            static let mapValueEmpty = NSLocalizedString("mapValueEmpty",
                                                    comment: "accessibility value on map for voiceOver users when empty")
            
            static let searchbarHint = NSLocalizedString("searchBarHint",
                                                         comment: "accessibility hint on searchBar for voiceOver users")
            
            static let locationCellHint = NSLocalizedString("MapViewAccessibilityHint",
                                                    comment: "hint of cell that displays a location to voiceOver users")
        }
    }
    
    struct NotesInputView {
        
        static let textViewPlaceholder =
            NSLocalizedString("notesInputPlaceholder", comment: "placeholder for notes input text view")
        
    }
    
    struct Notification {
        static let placeholderTitle =
            NSLocalizedString("notificationTitle", comment: "placeholder for notification title")
        static let complete =
            NSLocalizedString("completeTask", comment: "placeholder for complete task from notification")
        static let postponeOneHour =
            NSLocalizedString("postponeOneHour", comment: "placeholder for postpone one hour the notification from a task")
        static let postponeOneDay =
            NSLocalizedString("postponeOneDay", comment: "placeholder for postpone one day the notification from a task")
    }
    
    struct MoreOptionsScreen {
        
        struct LocationCell {
            static let title = NSLocalizedString("locationHeaderTitle", comment: "title for location cell on task details menu")
            
            static let subtitle = NSLocalizedString("locationHeaderSubtitle", comment: "subtitle for location cell on task details menu")
            
            static let voiceOverHint = NSLocalizedString("locationVoiceOverHint", comment: "(VoiceOver) hint for location cell on task details menu")
        }
        
        struct TimeCell {
            static let title = NSLocalizedString("timeHeaderTitle", comment: "title for date cell on task details menu")
            
            static let subtitle = NSLocalizedString("timeHeaderSubtitle", comment: "subtitle for date cell on task details menu")
            
            static let voiceOverHint = NSLocalizedString("dateVoiceOverHint", comment: "(VoiceOver) hint for date cell on task details menu")
        }
        
        struct NotesCell {
            static let title = NSLocalizedString("notesHeaderTitle", comment: "title for notes header")
            
            static let subtitle = NSLocalizedString("notesHeaderSubtitle", comment: "subtitle for notes header")
            static let voiceOverHint = NSLocalizedString("notesVoiceOverHint", comment: "(VoiceOver) hint for notes cell on task details menu")
        }
        
    }
}
