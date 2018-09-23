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

class TagCollectionAccessibilityView: UIView {
    var viewModel: TagCollectionViewModel!
    var collection: TagCollectionView!
    
    private var tagAccessibilityElement: TagCollectionAccessibilityElement?
    override var accessibilityElements: [Any]? {
        get {
            var elements: [Any] = []
            
            let tagElement: TagCollectionAccessibilityElement
            if tagAccessibilityElement != nil {
                tagElement = tagAccessibilityElement!
            } else {
                tagElement = TagCollectionAccessibilityElement(accessibilityContainer: self,
                                                               viewModel: viewModel)
//                tagElement.accessibilityFrame = frame
                tagElement.accessibilityFrameInContainerSpace = frame
                self.tagAccessibilityElement = tagElement
            }
            
            elements = [ tagElement ]
            
            return elements
        }
        
        set { }
    }
}

class TagCollectionAccessibilityElement: UIAccessibilityElement {
    
    private let viewModel: TagCollectionAccessibilityViewModel
    private var collection: TagCollectionView?
    
    init(accessibilityContainer container: Any, viewModel: TagCollectionViewModel) {
        self.viewModel = TagCollectionAccessibilityViewModel(viewModel)
        super.init(accessibilityContainer: container)
        if let collection = (accessibilityContainer as? TagCollectionAccessibilityView)?.collection {
            self.collection = collection
        }
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
    
    private var index = 0
    
    private func scrollCollection(forwards: Bool) -> Bool {
        guard let collectionView = self.collection else {
            return false
        }
        
        if forwards {
//            guard
//                let index = viewModel.filteredTags.index(of: tag),
//                index < viewModel.filteredTags.count - 1
//                else {
//                return false
//            }
            
            collectionView.scrollToItem(
                at: IndexPath(row: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        } else {
//            guard
//                let index = viewModel.filteredTags.index(of: tag),
//                index > 0
//                else {
//                    return false
//            }
            
            collectionView.scrollToItem(
                at: IndexPath(row: index, section: 0),
                at: .centeredHorizontally,
                animated: true
            )
        }
        
        return true
    }
}

class TagCollectionAccessibilityViewModel {
    private let viewModel: TagCollectionViewModel
    
    init(_ viewModel: TagCollectionViewModel) {
        self.viewModel = viewModel
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
