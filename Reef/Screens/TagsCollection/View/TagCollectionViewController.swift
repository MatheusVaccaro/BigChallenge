//
//  TagsCollectionViewController.swift
//  BigChallenge
//
//  Created by Bruno Fulber Wide on 11/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import Crashlytics
import RxCocoa
import RxSwift
import ReefKit //TODO: remove

class TagCollectionViewController: UIViewController {
    
    class var tagViewControllerID: String {
        return "TagCollectionViewController"
    }

    public var tagsObservable: BehaviorSubject<[Tag]> {
        return viewModel!.tagsObservable
    }
    
    @IBOutlet weak var tagsCollectionView: UICollectionView!
    
    var viewModel: TagCollectionViewModel!
    
    var clickedTagEvent: BehaviorSubject<Tag>?
    private(set) var addTagEvent: PublishSubject<Bool>?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        addTagEvent = PublishSubject<Bool>()
        bindCollectionView()
        tagsCollectionView.allowsMultipleSelection = true
        if let layout = tagsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.estimatedItemSize = CGSize(width: 150, height: 40)
        }
        
        configureAccessibility()
    }
    
    func bindCollectionView() {
        viewModel.tagsObservable
            .map { return self.viewModel.sortMostTasksIn($0) }
            .map { return $0.map { Item(tag: $0) } + [Item(tag: nil)] } // map add button
            .bind(to: tagsCollectionView.rx
            .items(cellIdentifier: TagCollectionViewCell.identifier,
               cellType: TagCollectionViewCell.self)) { (row, item, cell) in
                
                self.configureCell(row: row, item: item, cell: cell)
                
                cell.isAccessibilityElement = true
                
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.itemSelected.subscribe { event in
            let indexPath = event.element!
            UISelectionFeedbackGenerator().selectionChanged()
            
            guard let item =
                self.tagsCollectionView.cellForItem(at: indexPath) as? TagCollectionViewCell else { return }
            guard item.kind == .tag, let tag = item.viewModel?.tag else {
                    self.addTagEvent?.onNext(true); return
            }
            
            if self.viewModel.shouldAskForAuthentication(with: tag) {
                Authentication.authenticate { sucess in
                    if sucess {
                        self.viewModel.select(tag)
                    } else {
                        DispatchQueue.main.async {
                            self.tagsCollectionView.deselectItem(at: indexPath, animated: true)
                        }
                    }
                }
            } else { self.viewModel.select(tag) }
            
        }.disposed(by: disposeBag)
        
        tagsCollectionView.rx.itemDeselected.subscribe { event in
            UISelectionFeedbackGenerator().selectionChanged()
            guard let item =
                self.tagsCollectionView.cellForItem(at: event.element!) as? TagCollectionViewCell,
                let tag = item.viewModel?.tag else { return }
            
            self.viewModel.select(tag)
        }.disposed(by: disposeBag)
    }
    
    func presentActionSheet(for tag: Tag) {
        guard !viewModel.presentingActionSheet else { return }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        viewModel.presentingActionSheet = true
        let actionsheet = UIAlertController(title: tag.title!,
                                            message: nil,
                                            preferredStyle: .actionSheet)
        
        let updateAction = UIAlertAction(title: viewModel.updateActionTitle, style: .default) { _ in
            self.viewModel.update(tag: tag)
            self.viewModel.presentingActionSheet = false
        }
        
        let deleteAction = UIAlertAction(title: viewModel.deleteActionTitle, style: .destructive) { _ in
            self.viewModel.delete(tag: tag)
            self.viewModel.presentingActionSheet = false
        }
        
        let cancelAction = UIAlertAction(title: viewModel.cancelActionTitle, style: .cancel) { _ in
            print("Cancelled")
            self.viewModel.presentingActionSheet = false
        }
        
        actionsheet.addAction(updateAction)
        actionsheet.addAction(deleteAction)
        actionsheet.addAction(cancelAction)
        
        present(actionsheet, animated: true, completion: nil)
    }
    
    private func select(_ bool: Bool, at index: IndexPath, animated: Bool = false) {
        if bool {
            tagsCollectionView.selectItem(at: index,
                                          animated: animated,
                                          scrollPosition: UICollectionViewScrollPosition.bottom)
        } else {
            tagsCollectionView.deselectItem(at: index, animated: animated)
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
    
    fileprivate func configureCell(row: Int, item: Item, cell: TagCollectionViewCell) {
        guard let tag = item.tag else {
            cell.configure()
            return
        }
        
        let tagViewModel = self.viewModel.tagCollectionCellViewModel(for: tag)
        
        tagViewModel.longPressedTag.subscribe { event in
            self.presentActionSheet(for: event.element!)
            Answers.logCustomEvent(withName: "longpressed tag")
        }.disposed(by: self.disposeBag)
        
        let indexPath = IndexPath(row: row, section: 0)
        cell.configure(with: tagViewModel)
        self.loadSelection(for: cell, tag: tag, at: indexPath)
    }
    
    fileprivate func presentBigCollection() {
        let bigTagVC = BigTagCollectionViewController.instantiate()
        
        bigTagVC.viewModel = self.viewModel
        bigTagVC.modalPresentationStyle = .overCurrentContext
        bigTagVC.modalTransitionStyle = .crossDissolve
        
        resignFirstResponder()
        present(bigTagVC, animated: true)
    }
    
    private func configureAccessibility() {
        isAccessibilityElement = true
        tagsCollectionView.isAccessibilityElement = true
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
