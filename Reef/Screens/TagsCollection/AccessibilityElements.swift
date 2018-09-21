//
//  AccessibilityElements.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 21/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import Foundation
import UIKit
import ReefKit

class TagCollectionAccessibilityElement: UIAccessibilityElement {
    
    private let viewModel: TagCollectionAccessibilityViewModel
    
    init(accessibilityContainer container: Any, viewModel: TagCollectionViewModel) {
        self.viewModel = TagCollectionAccessibilityViewModel(viewModel)
        
        super.init(accessibilityContainer: container)
    }
    
    override var accessibilityLabel: String? {
        get {
            return viewModel.accessibilityLabel
        }
        set { }
    }
    
    override var accessibilityValue: String? {
        get {
            return viewModel.accessibilityValue
        }
        set { }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.adjustable
        }
        set { }
    }
    
    override func accessibilityIncrement() {
        _ = scrollCollection(forwards: true)
    }
    
    override func accessibilityDecrement() {
        _ = scrollCollection(forwards: false)
    }
    
    //    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? //TODO: add tag action
    
    private func scrollCollection(forwards: Bool) -> Bool {
        guard let collectionView = (accessibilityContainer as? TagCollectionViewController)?.tagsCollectionView,
              let tag = viewModel.currentTag else {
            return false
        }
        
        if forwards {
            guard
                let index = viewModel.filteredTags.index(of: tag),
                index < viewModel.filteredTags.count - 1
                else {
                return false
            }
                
            collectionView.scrollToItem(
                at: IndexPath(row: index+1, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        } else {
            guard
                let index = viewModel.filteredTags.index(of: tag),
                index > 0
                else {
                    return false
            }
            
            collectionView.scrollToItem(
                at: IndexPath(row: index-1, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
        
        return true
    }
}

class TagCollectionAccessibilityViewModel {
    private let viewModel: TagCollectionViewModel
    var currentTag: Tag?
    
    init(_ viewModel: TagCollectionViewModel) {
        self.viewModel = viewModel
        currentTag = viewModel.tags.first
    }
    
    var filteredTags: [Tag] {
        return viewModel.filteredTags
    }
    
    //TODO
    var accessibilityLabel: String {
        return "accessibilityLabel" // tag picker
    }
    
    var accessibilityValue: String {
        return "accessibilityValue" // selected tags
    }
}
