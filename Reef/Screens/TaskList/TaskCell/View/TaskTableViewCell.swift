//
//  TaskTableViewCell.swift
//  BigChallenge
//
//  Created by Matheus Vaccaro on 25/05/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit
import ReefKit

public class TaskTableViewCell: UITableViewCell {
    
    // MARK: - Properties
    public static let identifier = "taskCell"
    
    private var viewModel: TaskCellViewModel!
    private var previousRect = CGRect.zero
    private lazy var gradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer()

        layer.frame = frame
        layer.startPoint = CGPoint(x: 0, y: 0)
        layer.endPoint = CGPoint(x: 1, y: 1)
        
        return layer
    }()
    
    // MARK: - IBOutlets
    @IBOutlet weak var taskTitleTextView: UITextView!
    @IBOutlet weak var gradientSideBar: UIView!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var locationIconImageView: UIImageView!
    @IBOutlet weak var dateStringView: UIView!
    @IBOutlet weak var dateStringLabel: UILabel!
    @IBOutlet weak var tapView: UIView!
    
    // MARK: - TableViewCell Lifecycle
    override public func awakeFromNib() {
        super.awakeFromNib()
        
        gradientSideBar.layer.addSublayer(gradientLayer)
        gradientSideBar.clipsToBounds = true
        
        taskTitleTextView.textContainerInset =
            UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        taskTitleTextView.textContainer.lineFragmentPadding = 0
        
        dateStringView.layer.cornerRadius = dateStringView.frame.height * 0.1
        dateStringLabel.textColor = ReefColors.cellTagLabel
        
        tagsLabel.textColor = ReefColors.cellTagLabel
        
        selectionStyle = .none
        configureAccessibility()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapGradient))
        tapView.addGestureRecognizer(tapRecognizer)
    }
    
    public override func layoutSubviews() {
        gradientLayer.frame = bounds
    }
    
    // MARK: - Functions
    public func configure(with viewModel: TaskCellViewModel) {
        self.viewModel = viewModel
        tagsLabel.text = viewModel.tagsDescription
        
        if viewModel.shouldShowLocationIcon {
            locationIconImageView.image = UIImage(named: "locationIcon")!
                .withRenderingMode(.alwaysTemplate)
            locationIconImageView.tintColor = ReefColors.cellTagLabel
            locationIconImageView.isHidden = false
        } else {
            locationIconImageView.isHidden = true
        }
        
        if viewModel.shouldShowDateIcon {
            dateStringView.backgroundColor = viewModel.isTaskLate
                ? ReefColors.deleteRed
                : ReefColors.cellIcons
            dateStringLabel.textColor = viewModel.isTaskLate
                ? UIColor.white
                : ReefColors.cellTagLabel
            
            dateStringLabel.text = viewModel.dateString(with: "dd MMM")
            dateStringView.isHidden = false
        } else {
            dateStringView.isHidden = true
            dateStringView.backgroundColor = .clear
            dateStringLabel.text = ""
        }
        
        if viewModel.taskIsCompleted {
            gradientLayer.colors = [ReefColors.cellTagLabel.cgColor, ReefColors.cellTagLabel.cgColor]
            
            let textAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.strikethroughStyle : NSUnderlineStyle.thick.rawValue,
                NSAttributedString.Key.strikethroughColor : ReefColors.cellTagLabel,
                NSAttributedString.Key.foregroundColor : ReefColors.cellTagLabel,
                NSAttributedString.Key.font : UIFont.font(sized: 19, weight: .medium, with: .body)
                ]
            
            let str = NSAttributedString(string: viewModel.title, attributes: textAttributes)
            
            taskTitleTextView.attributedText = str
            
        } else {
            taskTitleTextView.textColor = UIColor.black
            gradientLayer.colors = viewModel.checkButtonGradient
            
            let textAttributes: [NSAttributedString.Key : Any] = [
                NSAttributedString.Key.foregroundColor : ReefColors.taskTitleLabel,
                NSAttributedString.Key.font : UIFont.font(sized: 19, weight: .medium, with: .body)
            ]
            
            let str = NSAttributedString(string: viewModel.title, attributes: textAttributes)
            
            taskTitleTextView.attributedText = str
        }
    }
    
    fileprivate func configureAccessibility() {
        gradientSideBar.accessibilityIgnoresInvertColors = true
    }
    
    @IBAction func didTapGradient(_ sender: UITapGestureRecognizer) {
        viewModel.toggleCompleteTask()
    }
    
}

extension TaskTableViewCell { // MARK: - Accessibility
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        taskTitleTextView.font = UIFont.font(sized: 19, weight: .medium, with: .body)
        dateStringLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
        tagsLabel.font = UIFont.font(sized: 14, weight: .regular, with: .footnote)
        dateStringView.layer.cornerRadius = dateStringView.frame.height * 0.1
        gradientSideBar.setNeedsLayout()
        gradientSideBar.layoutIfNeeded()
    }
    
    public override var accessibilityLabel: String? {
        get {
            return viewModel!.title
        }
        set { }
    }
    
    public override var accessibilityValue: String? {
        get {
            
            var ans = ""
            
            if let tagsDescription = viewModel!.tagsDescription {
                ans.append(tagsDescription)
            }
            
            if let dateDescription = viewModel!.accessibilityDateString {
                ans.append(", \(dateDescription)")
            }
            
            if let locationDescription = viewModel!.locationDescription {
                ans.append(", \(locationDescription)")
            }
            
            return ans
        }
        set { }
    }
    
    public override var accessibilityHint: String? {
        get {
            return viewModel!.voiceOverHint
        }
        set { }
    }
    
    public override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            let completeAction = UIAccessibilityCustomAction(name: viewModel!.completeActionTitle,
                                                         target: self,
                                                         selector: #selector(toggleCompleteAction))
            
            return [completeAction]
        }
        set { }
    }
    
    public override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.allowsDirectInteraction
        }
        set { }
    }
    
    @objc private func toggleCompleteAction() {
        viewModel.toggleCompleteTask()
    }
}
