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
    
    struct Task {
        
        struct CreationScreen {
            static let taskTitlePlaceholder =
                NSLocalizedString("newTaskTitlePlaceholder", comment: "placeholder title for a new task")
        }
        
        struct ListScreen {
            static let recommendedHeaderTitle =
                NSLocalizedString("recommendedHeaderTitle", comment: "header title for 'recommended' section ")
            
            static let section2HeaderTitle =
                NSLocalizedString("section2HeaderTitle", comment: "header title for 'also tagged:' section ")
        }
    }
    
    struct Tag {
        
        struct CreationScreen {
            static let tagTitlePlaceholder =
                NSLocalizedString("newTagTitlePlaceHolder", comment: "placeholder title for a new tag")
            static let tagDescriptionPlaceholder =
                NSLocalizedString("newTagDescriptionPlaceholder", comment: "placeholder title for a new tag description")
        }
        
        struct CollectionScreen {
            static let title = NSLocalizedString("collectionScreenTitle", comment: "screen title when on \"all tags\" screen")
            static let alertControllerTitle = NSLocalizedString("alertControllerTitle", comment: "title for alert sheet used to edit tag")
            static let alertControllerMessage = NSLocalizedString("alertControllerMessage", comment: "message of alert sheet used to edit tag")
            static let deleteActionTitle = NSLocalizedString("deleteActionTitle", comment: "delete button title on edit action sheet")
            static let cancelActionTitle = NSLocalizedString("cancelActionTitle", comment: "cancel button title on edit action sheet")
        }
    }
    
    struct LocationInputView {
        static let arrivingString = NSLocalizedString("arrivingLocationInputView",
                                                      comment: "string for selecting arriving location")
        
        static let leavingString = NSLocalizedString("leavingLocationInputView",
                                                     comment: "String for selecting leaving location")
        
        static let searchBarPlaceholder = NSLocalizedString("searchBarPlaceholder", comment: "placeHolder for searchBar that searches locations")
        
        static let defaultPlaceName = NSLocalizedString("defaultPlaceName", comment: "default place when reading location name in voiceOver")
        
        static let accessibilitylabelMap = NSLocalizedString("mapViewAccessibilitylabel",
                                                             comment: "description of map to voiceOver users")
        
        static let accessibilityValueEmptyMap = NSLocalizedString("mapViewAccessibilityValueEmpty",
                                                                  comment: "description of empty value of map for voiceOver users")
        
        static let accessibilityValueMap = NSLocalizedString("%d meters from %s",
                                                             comment: "accessibility value on map for voiceOver users")
        
        static let accessibilityHintSearchBar = NSLocalizedString("SearchBarHint",
                                                                  comment: "accessibility hint on searchBar for voiceOver users")
    }
    
    struct Notification {
        static let placeholderTitle =
            NSLocalizedString("notificationTitle", comment: "placeholder for notification title")
    }
}
