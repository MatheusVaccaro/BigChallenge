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
    private(set) var addTagEvent: PublishSubject<Bool>?
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addTagEvent = PublishSubject<Bool>()
        // Do any additional setup after loading the view.
        bindCollectionView()
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
    }
    
    struct Item {
        var tag: Tag?
    }
    
    func bindCollectionView() {
        viewModel.tagsObservable
            .map { return $0.map { Item(tag: $0) } + [Item(tag: nil)] }
            .bind(to: tagsCollectionView.rx
            .items(cellIdentifier: TagCollectionViewCell.identifier,
               cellType: TagCollectionViewCell.self)) { (row, item, cell) in
                
                guard let tag = item.tag else {
                    cell.configure()
                    cell.clickedAddTag.subscribe { _ in
                        self.addTagEvent?.onNext(true)
                    }.disposed(by: self.disposeBag)
                    return
                }
                
                let tagViewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
                let indexPath = IndexPath(row: row, section: 0)
                cell.configure(with: tagViewModel)
                self.loadSelection(for: cell, tag: tag, at: indexPath)
        }.disposed(by: disposeBag)
        
        if let tagsCollection = tagsCollectionView as? TagCollectionView {
            tagsCollection.touchedEvent.subscribe { event in
                guard let touch = event.element else { return }
                if self.shouldPresentBigCollection(on: touch) {
                    self.presentBigCollection()
                }
            }.disposed(by: disposeBag)
        }
        
        tagsCollectionView.rx.modelSelected(Item.self).subscribe { event in
            guard let tag = event.element?.tag else { return }
            self.viewModel.selectedTagEvent.onNext(tag)
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.modelDeselected(Item.self).subscribe { event in
            guard let tag = event.element?.tag else { return }
            self.viewModel.selectedTagEvent.onNext(tag)
        }.disposed(by: disposeBag)
    }
    
    private func clickedAddButton() {
        
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
