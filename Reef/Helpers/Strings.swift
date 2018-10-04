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
            
            struct VoiceOver {
                static let label = NSLocalizedString("create task voice over label", comment: "")
                static let hint = NSLocalizedString("create task voice over hint", comment: "")
                static let ShowDetailsAction = NSLocalizedString("show details action", comment: "")
                static let CreateTaskAction = NSLocalizedString("create task action", comment: "")
            }
        }
        
        struct ListScreen {
            static let locationHeader =
                NSLocalizedString("locationHeader", comment: "header title for recommended by 'location' section")
            
            static let lateHeader =
                NSLocalizedString("lateHeader", comment: "header title for recommended by 'late' section")
            
            static let upNextHeader =
                NSLocalizedString("upNextHeader", comment: "header title for recommended by 'up next' section")
            
            static let recentHeader =
                NSLocalizedString("recentHeader", comment: "header title for recommended by 'recent' section")
            
            static let otherTasksHeader =
                NSLocalizedString("otherTasksHeader", comment: "header title for 'other tags' section ")
        }
        
        struct Cell {
            struct VoiceOver {
                static let hintCompleted = NSLocalizedString("taskCellCompletedVoiceOverHint", comment: "(VoiceOver) hint for task cell on task list ('double tap to set incomplete')")
                static let hintIncomplete = NSLocalizedString("taskCellIncompleteVoiceOverHint", comment: "(VoiceOver) hint for task cell on task list ('double tap to complete')")
                static let locationDescription = NSLocalizedString("set to %@ locations", comment: "(voiceOver) description when task in cell contains a location (says the number of locations it is set to)")
                static let dateDescription = NSLocalizedString("next reminder set to %@", comment: "(VoiceOver) description when task in cell contains a date reminder (says the next date set)")
            }
        }
    }
    
    struct Tag {
        
        struct Private {
            static let unlockReason =
                NSLocalizedString("touchIDPermisson", comment: "prompt when requesting touchID to unlock private tag")
            
            struct Cell {
                static let title = NSLocalizedString("private tag option cell title", comment: "")
                static let subtitle = NSLocalizedString("private tag option cell subtitle", comment: "")
                struct VoiceOver {
                    static let hint = NSLocalizedString("private tag option voice over hint", comment: "")
                }
            }
        }
        
        struct CreationScreen {
            static let tagTitlePlaceholder =
                NSLocalizedString("newTagTitlePlaceHolder", comment: "placeholder title for a new tag")
            static let tagDescriptionPlaceholder =
                NSLocalizedString("newTagDescriptionPlaceholder", comment: "placeholder title for a new tag description")
        }
        
        struct CollectionScreen {
            struct VoiceOver {
                struct AddTag {
                    static let label = NSLocalizedString("add tag accessibility label", comment: "'add a new task'")
                    static let hint = NSLocalizedString("add tag accessibility hint", comment: "'double tap to add task'")
                }
                struct Tag {
                    static let hint = NSLocalizedString("tag accessibility hint", comment: "'double tap to select'")
                    static let valueSelected = NSLocalizedString("tag accessibility value selected", comment: "'selected'")
                    static let valueDeselected = NSLocalizedString("tag accessibility value not selected", comment: "'not selected'")
                }
            }
        }
    }
    
    struct DateInputView {
        static let dateInputStatus = NSLocalizedString("dateInputStatusDateInput",
                                                       comment: "text displaying the current selected date and time of day")
        
        static let selectedDateFormat = NSLocalizedString("selectedDateFormatStatusDateInput",
                                                          comment: "format for displaying the currently selected date")
        
        static let preposition =
            NSLocalizedString("dateInputPreposition",
                              comment: "Preposition that connects calendar date to time of day.")
        
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
        
        struct Cell {
            static let title = NSLocalizedString("timeHeaderTitle", comment: "title for date cell on task details menu")
            
            static let subtitle = NSLocalizedString("timeHeaderSubtitle", comment: "subtitle for date cell on task details menu")
            
            static let voiceOverHint = NSLocalizedString("dateCellVoiceOverHint", comment: "(VoiceOver) hint for date cell on task details menu")
        }
        
        struct VoiceOver {
            static let hint = NSLocalizedString("calendar VoiceOver Hint", comment: "hint when using the calendar date picker")
            static let label = NSLocalizedString("calendar VoiceOver Label", comment: "label of calendar date picker")
        }
    }
    
    struct LocationInputView {
        static let arrivingString = NSLocalizedString("arrivingLocationInputView",
                                                      comment: "string for selecting arriving location")
        
        static let leavingString = NSLocalizedString("leavingLocationInputView",
                                                     comment: "String for selecting leaving location")
        
        static let searchBarPlaceholder = NSLocalizedString("searchBarPlaceholder", comment: "placeHolder for searchBar that searches locations")
        
        static let defaultPlaceName = NSLocalizedString("defaultPlaceName", comment: "default place when reading location name in voiceOver")
        
        static let locationCellHint = NSLocalizedString("select location cell hint", comment: "'double tap to select this location'")
        
        struct Cell {
            static let title = NSLocalizedString("locationHeaderTitle", comment: "title for location cell on task details menu")
            
            static let subtitle = NSLocalizedString("locationHeaderSubtitle", comment: "subtitle for location cell on task details menu")
        }
        
        struct VoiceOver {
            static let mapLabel = NSLocalizedString("mapViewAccessibilitylabel",
                                                    comment: "description of map to voiceOver users")
            
            static let mapValue = NSLocalizedString("%@ meters from %@",
                                                    comment: "accessibility value on map for voiceOver users")
            
            static let mapValueEmpty = NSLocalizedString("mapValueEmpty",
                                                    comment: "accessibility value on map for voiceOver users when empty")
            
            static let searchbarHint = NSLocalizedString("searchBarHint",
                                                         comment: "accessibility hint on searchBar for voiceOver users")
        }
    }
    
    struct NotesInputView {
        static let textViewPlaceholder =
            NSLocalizedString("notesInputPlaceholder", comment: "placeholder for notes input text view")
        
        struct Cell {
            static let title = NSLocalizedString("notesHeaderTitle", comment: "title for notes header")
            
            static let subtitle = NSLocalizedString("notesHeaderSubtitle", comment: "subtitle for notes header")
            static let voiceOverHint = NSLocalizedString("notesVoiceOverHint", comment: "(VoiceOver) hint for notes cell on task details menu")
        }
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
    
    struct General {
        static let editActionTitle = NSLocalizedString("updateActionTitle", comment: "edit button title")
        static let deleteActionTitle = NSLocalizedString("deleteActionTitle", comment: "delete button title")
        static let cancelActionTitle = NSLocalizedString("cancelActionTitle", comment: "cancel button title")
        static let on = NSLocalizedString("on", comment: "meaning some switch is turned on")
        static let off = NSLocalizedString("off", comment: "meaning some switch is turned off")
    }
}
