//
//  IntentHandler.swift
//  ReefIntents
//
//  Created by Bruno Fulber Wide on 18/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Intents

class IntentHandler: INExtension {
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        if intent is INCreateTaskListIntent {
            return CreateTaskListIntentHandler()
        }
        
        return self
    }
}
