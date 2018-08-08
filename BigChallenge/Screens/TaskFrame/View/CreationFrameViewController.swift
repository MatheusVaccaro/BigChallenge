//
//  TaskFrameViewController.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 28/07/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol CreationFramePresentable {
    func didTapCancelButton(_ sender: UIButton)
    func didTapMoreOptionsButton(_ sender: UIButton)
    func didTapSaveButton(_ sender: UIButton)
}

protocol TaskFrameDelegate: class {
    func shouldEnableDoneButton(_ bool: Bool)
}

class CreationFrameViewController: UIViewController {

    typealias FrameContent = CreationFramePresentable & UIViewController
    
    // MARK: - Properties
    var viewModel: CreationFrameViewModel!
    private var pageViewController: UIPageViewController?
    private var pages: [UIViewController] = []
    private var currentPageIndex: Int?
    private var pendingPageIndex: Int?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - TaskFrameViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPageViewController()
        disablePageViewControllerBounce()
        doneButton.isEnabled = false
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapCancelButton(_ sender: UIButton) {
        guard let currentPageIndex = currentPageIndex else { return }
        guard let currentPage = pages[currentPageIndex] as? FrameContent else { return }
        currentPage.didTapCancelButton(sender)
    }
    
    @IBAction func didTapMoreOptionsButton(_ sender: UIButton) {
        guard let currentPageIndex = currentPageIndex else { return }
        guard let currentPage = pages[currentPageIndex] as? FrameContent else { return }
        currentPage.didTapMoreOptionsButton(sender)
    }
    
    @IBAction func didTapSaveButton(_ sender: UIButton) {
        guard let currentPageIndex = currentPageIndex else { return }
        guard let currentPage = pages[currentPageIndex] as? FrameContent else { return }
        
        currentPage.didTapSaveButton(sender)
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
    
    func configurePageViewController(with pages: [FrameContent]) {
        self.pages = pages
    }
    
}

// MARK: - UIPageViewControllerDelegate

extension CreationFrameViewController: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            willTransitionTo pendingViewControllers: [UIViewController]) {
        if let viewController = pendingViewControllers.first,
            let pageIndex = pages.firstIndex(of: viewController) {
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

// MARK: - TaskFrameDelegate

extension CreationFrameViewController: TaskFrameDelegate {
    func shouldEnableDoneButton(_ bool: Bool) {
        doneButton.isEnabled = bool
    }
}

// MARK: - StoryboardInstantiable

extension CreationFrameViewController: StoryboardInstantiable {
    static var storyboardIdentifier: String {
        return "TaskFrame"
    }
    
    static var viewControllerID: String {
        return "TaskFrameViewController"
    }
}
