//
//  TaskFrameViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 28/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import RxSwift
import NotificationCenter

protocol CreationFramePresentable {
    func didTapMoreOptionsButton(_ sender: UIButton)
}

class CreationFrameViewController: UIViewController {

    typealias FrameContent = CreationFramePresentable & UIViewController
    
    // MARK: - Properties
    
    var viewModel: CreationFrameViewModelProtocol!
    private var pageViewController: UIPageViewController?
    private var pages: [UIViewController] = []
    private var currentPageIndex: Int?
    private var pendingPageIndex: Int?
    private let disposeBag = DisposeBag()
    private var isShowingKeyboard = false
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Constraints
    
    @IBOutlet weak var buttonsBookshelfTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var doneButtonBottomConstraint: NSLayoutConstraint!
    
    // MARK: - TaskFrameViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        setupPageViewController()
        disablePageViewControllerBounce()
        subscribeToEnableDoneButton()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CreationFrameViewController.keyboardWillShow),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(CreationFrameViewController.keyboardWillHide),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        viewModel.didTapCancelButton()
    }
    
    @IBAction func didTapMoreOptionsButton(_ sender: UIButton) {
        guard let currentPageIndex = currentPageIndex else { return }
        guard let currentPage = pages[currentPageIndex] as? FrameContent else { return }
        currentPage.didTapMoreOptionsButton(sender)
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        viewModel.didTapSaveButton()
    }
    
    // MARK: - Functions

    private func setupPageViewController() {
        let pageViewController = UIPageViewController(transitionStyle: .scroll,
                                                      navigationOrientation: .horizontal,
                                                      options: nil)
        pageViewController.delegate = self
        pageViewController.dataSource = self
        self.pageViewController = pageViewController
        
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(pageViewController.view)
        
        NSLayoutConstraint.activate([
            pageViewController.view
                .leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            pageViewController.view
                .trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            pageViewController.view
                .topAnchor.constraint(equalTo: containerView.topAnchor),
            pageViewController.view
                .bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
            ])
        
        guard let initialViewController = pages.first else { return }
        currentPageIndex = 0
        pageViewController.setViewControllers([initialViewController],
                                               direction: .forward,
                                               animated: true,
                                               completion: nil)
        
        pageViewController.didMove(toParentViewController: self)
    }
    
    private func disablePageViewControllerBounce() {
        guard let pageViewController = pageViewController else { return }
        for subview in pageViewController.view.subviews {
            if let scrollView = subview as? UIScrollView {
                scrollView.delegate = self
                break
            }
        }
    }
    
    private func subscribeToEnableDoneButton() {
        viewModel.doneButtonObservable.subscribe {
            self.doneButton.isEnabled = $0.element!
            }.disposed(by: disposeBag)
    }
    
    func configurePageViewController(with pages: [FrameContent]) {
        self.pages = pages
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if !isShowingKeyboard {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                isShowingKeyboard = true
                UIView.animate(withDuration: 1) {
                    self.buttonsBookshelfTopConstraint.constant -= keyboardSize.height
                    self.doneButtonBottomConstraint.constant += keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if isShowingKeyboard {
            isShowingKeyboard = false
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
                UIView.animate(withDuration: 1) {
                    self.buttonsBookshelfTopConstraint.constant += keyboardSize.height
                    self.doneButtonBottomConstraint.constant -= keyboardSize.height
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
}

// MARK: - UIPageViewControllerDelegate

extension CreationFrameViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first,
            let pageIndex = pages.index(of: viewController) {
            pendingPageIndex = pageIndex
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        if completed {
            currentPageIndex = pendingPageIndex
        }
    }
}

// MARK: - UIPageViewControllerDataSource

extension CreationFrameViewController: UIPageViewControllerDataSource {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.index(of: viewController) else { return nil }
        let previousIndex = pageIndex - 1
        guard previousIndex >= 0 else { return nil }
        guard pages.count > previousIndex else { return nil }
        return pages[previousIndex]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let pageIndex = pages.index(of: viewController) else { return nil }
        let nextIndex = pageIndex + 1
        guard nextIndex < pages.count else { return nil }
        guard pages.count > nextIndex else { return nil }
        return pages[nextIndex]
    }
}

// MARK: - UIScrollViewDelegate

extension CreationFrameViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if currentPageIndex == 0 && scrollView.contentOffset.x < scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentPageIndex == pages.count - 1 && scrollView.contentOffset.x > scrollView.bounds.size.width {
            scrollView.contentOffset = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint,
                                   targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if currentPageIndex == 0 && scrollView.contentOffset.x <= scrollView.bounds.size.width {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        } else if currentPageIndex == pages.count - 1 && scrollView.contentOffset.x >= scrollView.bounds.size.width {
            targetContentOffset.pointee = CGPoint(x: scrollView.bounds.size.width, y: 0)
        }
    }
}

// MARK: - StoryboardInstantiable

extension CreationFrameViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "CreationFrame"
    }
    
    static var viewControllerID: String {
        return "CreationFrameViewController"
    }
}