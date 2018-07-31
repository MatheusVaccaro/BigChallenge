//
//  File.swift
//  BigChallengeTests
//
//  Created by Gabriel Paul on 27/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Quick
import Nimble

@testable
import BigChallenge

/*
 Affected user stories:
 - Notifications
 */

class NotificationTests: QuickSpec {
    
    override func spec() {
        
        describe("the NotificationManager") {
            
            beforeEach {
                
            }
            
            describe("create a notification with a date") {
                
                beforeEach {
                    
                }
                
                context("when setting up") {
                    beforeEach {
                        
                    }
                    
                    it("should trigger a notification at given date") {
                        
                    }
                    
                    it("should store the notification in the model") {
                        
                    }
                    
                    it("should persist notification in the model") {
                        
                    }
                }
                
                context("when turning off") {
                    beforeEach {
                        
                    }
                    
                    it("should not trigger a notification at the time") {
                        
                    }
                    
                    it("should not have a date stored in the model") {
                        
                    }
                }
            }
            
            describe("create a notification with a location") {
                
                context("when setting in 'When I Arrive' mode ") {
                    beforeEach {
                        
                    }
                    
                    it("should trigger a notification when I enter the range") {
                        
                    }
                    
                    it("should not trigger a notification while i'm off the range") {
                        
                    }
                    
                    it("should store the notification in the model") {
                        
                    }
                    
                    it("should persist the notification") {
                        
                    }
                }
                
                context("when setting in 'When I Leave' mode ") {
                    beforeEach {
                        
                    }
                    
                    it("should trigger a notification when I leave the range") {
                        
                    }
                    
                    it("should not trigger a notification while i'm inside the range") {
                        
                    }
                    
                    it("should store the notification in the model") {
                        
                    }
                    
                    it("should persist the notification") {
                        
                    }
                }
                
                context("when turning off") {
                    beforeEach {
                        
                    }
                    
                    it("should not trigger a notification") {
                        
                    }
                    
                    it("should not have a location stored in the model") {
                        
                    }
                }
            }
        }
    }
}
