//
//  CreateTaskIntent.swift
//  ReefIntents
//
//  Created by Bruno Fulber Wide on 22/10/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Intents
import ReefKit
import Foundation

class CreateTaskIntent: NSObject, INAddTasksIntentHandling {
    func handle(intent: INAddTasksIntent, completion: @escaping (INAddTasksIntentResponse) -> Void) {
        let reef = ReefKit()
        
        if let speakableStrings = intent.taskTitles {
            for title in speakableStrings.map({ $0.spokenPhrase }) {
                var attributes: [TaskAttributes : Any] = [
                    .title : title
                ]
                
                if let tag = intent.targetTaskList?.title.spokenPhrase {
                    attributes[.tags] = [tag]
                }
                
                reef.save(reef.createTask(with: attributes))
                
                completion(.init(code: .success, userActivity: nil))
            }
        } else {
            completion(.init(code: .failure, userActivity: nil))
        }
    }
}
