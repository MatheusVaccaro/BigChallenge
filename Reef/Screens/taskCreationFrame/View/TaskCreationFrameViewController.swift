//
//  TaskCreationFrameViewController.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 10/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class TaskCreationFrameViewController: UIViewController {

    @IBOutlet weak var taskDetailView: UIView!
    @IBOutlet weak var taskTitleView: UIView!
    
    var taskDetailViewController: MoreOptionsViewController?
    var newTaskViewController: NewTaskViewController!
    
    var viewModel: TaskCreationViewModel!
    
    func present(_ taskDetailViewController: MoreOptionsViewController) {
        self.taskDetailViewController = taskDetailViewController
        
        addChildViewController(taskDetailViewController)
        taskDetailView.addSubview(taskDetailViewController.view)
        
        taskDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            taskDetailViewController.view.rightAnchor.constraint(equalTo: taskDetailView.rightAnchor),
            taskDetailViewController.view.topAnchor.constraint(equalTo: taskDetailView.topAnchor),
            taskDetailViewController.view.leftAnchor.constraint(equalTo: taskDetailView.leftAnchor),
            taskDetailViewController.view.bottomAnchor.constraint(equalTo: taskDetailView.bottomAnchor)
            ])
    }
    
    func loadNewTask() {
        
    }
    
    @IBAction func didTapAddTask(_ sender: Any) {
        viewModel.delegate?.didTapAddTask()
    }
    
    @IBAction func didPanAddTask(_ sender: Any) {
        viewModel.delegate?.didPanAddTask()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension TaskCreationFrameViewController: StoryboardInstantiable {
    static var viewControllerID: String {
        return "taskCreationFrame"
    }
    
    static var storyboardIdentifier: String {
        return "TaskCreation"
    }
}