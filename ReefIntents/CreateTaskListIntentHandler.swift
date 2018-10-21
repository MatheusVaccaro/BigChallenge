//
//  CreateTaskListIntentHandler.swift
//  
//
//  Created by Bruno Fulber Wide on 19/10/18.
//

import Intents
import ReefKit

class CreateTaskListIntentHandler: NSObject, INCreateTaskListIntentHandling {
    func handle(intent: INCreateTaskListIntent, completion: @escaping (INCreateTaskListIntentResponse) -> Void) {
        let reef = ReefKit()
        
        if let title = intent.title?.spokenPhrase {
            let attributes: [TagAttributes : Any] = [ .title : title ]
            
            let tag = reef.createTag(with: attributes)
            reef.save(tag)
            
            completion(.init(code: .success, userActivity: nil))
        } else {
            completion(.init(code: .failure, userActivity: nil))
        }
    }
}
