//
//  TagsCollectionViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class TagCollectionViewController: UIViewController {
    
    class var tagViewControllerID: String {
        return "TagCollectionViewController"
    }

    public var tagsObservable: BehaviorSubject<[Tag]> {
        return viewModel!.tagsObservable
    }
    
    var viewModel: TagCollectionViewModel!
    var clickedTagEvent: BehaviorSubject<Tag>?
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        bindCollectionView()
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
    }
    
    func bindCollectionView() {
        viewModel.tagsObservable
        .bind(to: tagsCollectionView.rx
        .items(cellIdentifier: TagCollectionViewCell.identifier,
               cellType: TagCollectionViewCell.self)) { (row, tag, cell) in
            
                print("updating collection with tag \(tag.title!)")
                
                let tagViewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
                let indexPath = IndexPath(row: row, section: 0)

                cell.configure(with: tagViewModel)
                self.loadSelection(for: cell, tag: tag, at: indexPath)
                tagViewModel.observe(self.viewModel.selectedTagsObservable)
                
                tagViewModel.isSelected.subscribe { event in
                    guard let bool = event.element else { return }
                    cell.isSelected = bool
                    if cell.isSelected == true {
                        self.tagsCollectionView.selectItem(at: indexPath,
                                                           animated: false,
                                                           scrollPosition: UICollectionViewScrollPosition.bottom)
                    } else {
                        self.tagsCollectionView.deselectItem(at: indexPath, animated: true)
                    }
                }.disposed(by: self.disposeBag)
                
        }.disposed(by: disposeBag)
        
        if let tagsCollection = tagsCollectionView as? TagCollectionView {
            tagsCollection.touchedEvent.subscribe { event in
                guard let touch = event.element else { return }
                if self.shouldPresentBigCollection(on: touch) {
                    self.presentBigCollection()
                }
            }.disposed(by: disposeBag)
        }
        
        tagsCollectionView.rx.modelSelected(Tag.self).subscribe { event in // selected x item in collection
            self.viewModel.selectedTagEvent.on(event) // send to viewModel
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Tag.self).subscribe { event in
            self.viewModel.selectedTagEvent.on(event)
        }.disposed(by: disposeBag)
    }
    
    private func select(_ bool: Bool, at index: IndexPath, animated: Bool = false) {
        if bool {
            tagsCollectionView.selectItem(at: index,
                                          animated: animated,
                                          scrollPosition: UICollectionViewScrollPosition.bottom)
        } else {
            tagsCollectionView.deselectItem(at: index,
                                            animated: animated)
        }
    }
    
    func loadSelection(for cell: UICollectionViewCell, tag: Tag, at indexPath: IndexPath) {
        if self.viewModel.selectedTags.contains(tag) {
            cell.isSelected = true
            self.select(true, at: indexPath)
        } else {
            cell.isSelected = false
            self.select(false, at: indexPath)
        }
    }
    
    fileprivate func shouldPresentBigCollection(on touch: UITouch) -> Bool {
        if self.traitCollection.forceTouchCapability == .available {
            let force = touch.force/touch.maximumPossibleForce
            if force >= 0.5 { return true }
        } else if false {
            //HANDLE LONG PRESS
        }
        return false
    }
    
    fileprivate func presentBigCollection() {
        let bigTagVC = BigTagCollectionViewController.instantiate()
        
        bigTagVC.viewModel = self.viewModel
        bigTagVC.modalPresentationStyle = .overCurrentContext
        bigTagVC.modalTransitionStyle = .crossDissolve
        
        present(bigTagVC, animated: true)
    }
}

extension TagCollectionViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return self.tagViewControllerID
    }
    
    static var storyboardIdentifier: String {
        return "TagCollection"
    }
}
