//
//  TableViewCell.swift
//  Reef
//
//  Created by Bruno Fulber Wide on 06/09/18.
//  Copyright © 2018 Matheus Vaccaro. All rights reserved.
//

import UIKit

class IconTableViewCell: UITableViewCell {
    
    static var reuseIdentifier: String? = "IconTableViewCell"

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var titleLabel: UITextView!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cellSwitch: UISwitch!
    @IBOutlet weak var rightButton: UIButton!
    
    @IBOutlet weak var firstTagIcon: UIImageView!
    @IBOutlet weak var firstTagLabel: UILabel!
    @IBOutlet weak var secondTagIcon: UIImageView!
    @IBOutlet weak var secondTagLabel: UILabel!
    
    var tagIcons: [UIImageView] {
        return [firstTagIcon, secondTagIcon]
    }
    
    var tagLabels: [UILabel] {
        return [firstTagLabel, secondTagLabel]
    }
    
    
    var titleFontSize: CGFloat = 18 {
        didSet {
            titleLabel.font = UIFont.font(sized: titleFontSize, weight: .medium, with: .title1, fontName: .barlow)
        }
    }
    var subtitleFontSize: CGFloat = 13 {
        didSet {
            subtitleLabel.font = UIFont.font(sized: subtitleFontSize, weight: .regular, with: .title3)
        }
    }
    
    var viewModel: IconCellPresentable! {
        didSet {
            reloadData()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectionStyle = .none
        
        configureLayout()
        
        titleLabel.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        titleLabel.textContainer.lineFragmentPadding = 0
        
        firstTagIcon.isHidden = true
        firstTagLabel.isHidden = true
        secondTagIcon.isHidden = true
        secondTagLabel.isHidden = true
        
        configureAccessibility()
    }
    
    func configureLayout() {
        backgroundColor = ReefColors.tagsBackground
        icon.tintColor = ReefColors.iconCellIcon
        subtitleLabel.textColor = ReefColors.cellTagLabel
        titleLabel.textColor = ReefColors.taskTitleLabel
    }
    
    @IBAction func switchToggled(_ sender: UISwitch) {
        viewModel.switchActivated(bool: !self.viewModel.isSwitchOn) { granted in
            DispatchQueue.main.sync {
                self.cellSwitch.setOn(granted, animated: true)
            }
        }
    }
    
    @IBAction func righImageDidClick(_ sender: Any) {
        deleteActionHandler()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        titleLabel.font = UIFont.font(sized: titleFontSize, weight: .medium, with: .title1, fontName: .barlow)
        subtitleLabel.font = UIFont.font(sized: subtitleFontSize, weight: .regular, with: .title3)
        
        icon.setNeedsLayout()
        rightButton.setNeedsLayout()
        icon.layoutIfNeeded()
        rightButton.layoutIfNeeded()
    }
    
    private func reloadData() {
        titleLabel.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        icon.image = UIImage(named: viewModel.imageName)!
            .withRenderingMode(.alwaysTemplate)
        
        if viewModel.shouldShowDeleteIcon {
            rightButton.setImage(UIImage(named: "removeButton"), for: .normal)
        } else {
            rightButton.setImage(UIImage(named: "rightArrow"), for: .normal)
        }
        
        if viewModel.isSwitchCell {
            rightButton.isHidden = true
            cellSwitch.setOn(viewModel.isSwitchOn, animated: false)
        } else {
            cellSwitch.isHidden = true
        }
        
        for index in 0...1 {
            if viewModel.tagInfo.indices.contains(index) {
                tagIcons[index].isHidden = false
                tagLabels[index].isHidden = false
                
                let info = viewModel.tagInfo[index]
                
                tagIcons[index].image =
                    UIImage(named: viewModel.imageName)!
                        .withRenderingMode(.alwaysTemplate)
                tagIcons[index].tintColor =
                    UIColor(cgColor:UIColor.tagColors[info.colorIndex].first!)
                tagLabels[index].text = info.text
                tagLabels[index].textColor = ReefColors.cellTagLabel
            } else {
                tagIcons[index].isHidden = true
                tagLabels[index].isHidden = true
            }
        }
    }
    
    // MARK: - Accessibility
    private func configureAccessibility() {
        titleLabel.isAccessibilityElement = false
        subtitleLabel.isAccessibilityElement = false
        icon.isAccessibilityElement = false
        cellSwitch.isAccessibilityElement = false
    }
    
    override var accessibilityValue: String? {
        get {
            return viewModel.voiceOverValue
        }
        set { }
    }
    
    override var accessibilityLabel: String? {
        get {
            return viewModel.title
        }
        set { }
    }
    
    override var accessibilityHint: String? {
        get {
            return viewModel.voiceOverHint
        }
        set { }
    }
    
    override var accessibilityTraits: UIAccessibilityTraits {
        get {
            return UIAccessibilityTraits.allowsDirectInteraction
        }
        set { }
    }
    
    override var accessibilityCustomActions: [UIAccessibilityCustomAction]? {
        get {
            guard viewModel.shouldShowDeleteIcon else { return nil }
            return [
                UIAccessibilityCustomAction(name: Strings.General.deleteActionTitle,
                                            target: self,
                                            selector: #selector(deleteActionHandler))
            ]
        }
        
        set { }
    }
    
    @objc private func deleteActionHandler() {
        viewModel.rightImageClickHandler()
        reloadData()
        UIAccessibility.post(notification: UIAccessibility.Notification.layoutChanged, argument: nil)
    }
}
