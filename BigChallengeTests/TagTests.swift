////
////  TagTests.swift
////  BigChallengeTests
////
////  Created by Gabriel Paul on 23/07/18.
////  Copyright © 2018 Matheus Vaccaro. All rights reserved.
////
//
//import Quick
//import Nimble
//
//@testable
//import BigChallenge
//
///*
// Affected user stories:
// - Create a Tag
// - View a Tag
// - Update a Tag
// - Delete a Tag
// */
//
//class TagTests: QuickSpec {
//
//    override func spec() {
//
//        describe("the TagModel") {
//            var mockPersistence: Persistence!
//            var tagModel: TagModel!
//            var tagCollectionViewModel: TagCollectionViewModel!
//            var newTagViewModel: NewTagViewModel!
//            var initialTags: [Tag]!
//            var tag: Tag!
//
//            beforeEach {
//                mockPersistence = Persistence(configuration: .inMemory)
//                tagModel = TagModel(persistence: mockPersistence)
//                tagCollectionViewModel = TagCollectionViewModel(model: tagModel)
//
//                // Setup some mocked tags
//                let mockTag1 = tagModel.createTag(with: "Mock1")
//                mockTag1.color = 0
//                mockTag1.dueDate = Date()
//                tagModel.save(object: mockTag1)
//                tagModel.save(object: tagModel.createTag(with: "Mock1"))
//                tagModel.save(object: tagModel.createTag(with: "Mock2"))
//                tagModel.save(object: tagModel.createTag(with: "Mock3"))
//            }
//
//            describe("creating a tag") {
//
//                beforeEach {
//                    newTagViewModel = NewTagViewModel(tag: nil, isEditing: false, model: tagModel)
//                    newTagViewModel.tagTitleTextField = "Title"
//                    initialTags = tagModel.tags
//                }
//
//                context("when confirming the creation") {
//                    beforeEach {
//                        newTagViewModel.didTapDoneButton()
//                        // TODO Make this method more testable
//                        tag = Set(initialTags).intersection(tagModel.tags).first
//                    }
//
//                    it("should create a new tag") {
//                        expect(tag).toNot(beNil())
//                    }
//
//                    it("should make the tag viewable") {
//                        expect(tagCollectionViewModel.tags).to(contain(tag))
//                    }
//
//                    it("should store the tag in the model") {
//                        let allTags = tagModel.tags
//
//                        expect(allTags).to(contain(tag))
//                    }
//
//                    it("should persist the tag") {
//                        let newTagModel = TagModel(persistence: mockPersistence)
//                        let allTags = newTagModel.tags
//
//                        expect(allTags).to(contain(tag))
//                    }
//                }
//
//                context("when cancelling the creation") {
//                    beforeEach {
//                        newTagViewModel.didTapCancelButton()
//                    }
//
//                    it("should not affect the model") {
//                        let allTags = tagModel.tags
//
//                        expect(initialTags).to(equal(allTags))
//                    }
//
//                    it("should not persist the tag") {
//                        let newTagModel = TagModel(persistence: mockPersistence)
//                        let allTags = newTagModel.tags
//
//                        // Expect both collections to have the same content
//                        expect(initialTags).to(contain(allTags))
//                        expect(allTags).to(contain(initialTags))
//                    }
//                }
//            }
//
//            describe("updating a tag") {
//                context("saving it") {
//                    it("should update the tag in the model") {
//                        // TODO: Implement update test
//                    }
//                }
//
//                context("not saving it") {
//                    it("should not update the tag in the model") {
//                        // TODO Implement this using the upcoming method tagModel.update(task:)
//                    }
//                }
//            }
//
//            describe("deleting a tag") {
//                context("that is contained in the model") {
//                    it("should remove it from the model") {
//                        //TODO: Implement should remove from the model test
//                    }
//
//                    it("should stop it from persisting") {
//                        //TODO: Implement should stop it from persisting test
//                    }
//                }
//
//                context("that is not contained in the model") {
//                    it("should not affect the model") {
//                        //TODO: Implement should not affect the model test
//                    }
//                }
//            }
//        }
//    }
//}
