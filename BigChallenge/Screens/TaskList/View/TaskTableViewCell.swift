//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

protocol TaskCellDelegate: class {
    func shouldUpdateSize(of cell: TaskTableViewCell)
}

enum CellType {
    case top
    case middle
    case bottom
    case topAndBottom
    case none
}

class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    static let identifier = "taskCell"
    weak var delegate: TaskCellDelegate?
    
    private var viewModel: TaskCellViewModel?
    private var previousRect = CGRect.zero
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()
        layer.frame = checkButton.frame
        layer.startPoint = CGPoint(x: 0, y: 1)
        layer.endPoint = CGPoint(x: 1, y: 0)
        layer.zPosition = -1
        layer.mask = checkButton.imageView?.layer
        return layer
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var checkButton: UIButton!
    @IBOutlet weak var tagsLabel: UILabel!
    
    // MARK: - TableViewCell Lifecycle

    override func awakeFromNib() {
        super.awakeFromNib()
        taskTitleTextView.delegate = self
        checkButton.isSelected = false
        
        layer.addSublayer(gradientLayer)
        layer.shadowRadius = 6.3
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    // MARK: - Functions
    
    func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        
        gradientLayer.colors = viewModel.checkButtonGradient
        taskTitleTextView.text = viewModel.title
        tagsLabel.text = viewModel.tagsDescription
        checkButton.isSelected = viewModel.taskIsCompleted
    }
    
    func layout(with position: CellType) {
        clipsToBounds = true
        
        backgroundColor = UIColor.white
        layer.shadowColor = UIColor.black.cgColor
        
        print("task: \(viewModel?.title ?? "nil"), \(position)")
        
        switch position {
        case .top:
            layer.cornerRadius = 6.3
            layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        case .middle:
            layer.cornerRadius = 0
        case .bottom:
            layer.cornerRadius = 6.3
            layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        case .topAndBottom:
            layer.cornerRadius = 6.3
        case .none:
            backgroundColor = UIColor.clear
            layer.shadowColor = UIColor.clear.cgColor
        }
    }
    
    // MARK: - IBActions
    
    @IBAction func didPressCheckButton(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        viewModel?.changedCheckButton(to: checkButton.isSelected)
    }
}

extension TaskTableViewCell: UITextViewDelegate {
    func textViewDidEndEditing(_ textView: UITextView) {
        guard let text = textView.text else { return }
        viewModel?.shouldChangeTask(title: text)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let lastCharPos = textView.endOfDocument

        let currentRect = textView.caretRect(for: lastCharPos)
        if currentRect.origin.y < previousRect.origin.y {
            delegate?.shouldUpdateSize(of: self)
        }
        previousRect = currentRect
    }
}
