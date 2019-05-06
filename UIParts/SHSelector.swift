//
//  SHSelector.swift
//  SHObjects
//
//  Created by Hiroyuki Yamamoto on 2019/05/05.
//  Copyright © 2019 Hiroyuki Yamamoto. All rights reserved.
//

import UIKit

protocol SHSelectorDelegate : class {
    func selectedIndex(index: Int)
}

public class SHSelector : UIControl {
    
    var delegate :SHSelectorDelegate? = nil
    
    // -----------------------------------------------------------
    // UI Objects
    // -----------------------------------------------------------
    // Selector Object
    private var valueLabel : UIButton  = UIButton(type: UIButton.ButtonType.system)

    // Popup Select List
    private var btnCancel  : UIButton = UIButton(type: UIButton.ButtonType.system)
    private var btnOK      : UIButton = UIButton(type: UIButton.ButtonType.system)
    private var tableView  : UITableView = UITableView()

    // -----------------------------------------------------------
    // Enum
    // -----------------------------------------------------------
    
    private enum ImgType : Int {
        case Search = 0
        case Cancel = 1
        case Done   = 2
    }
    
    // -----------------------------------------------------------
    // Properties
    // -----------------------------------------------------------
    private var defaultValue : Int?   = nil

    var items : Array<String> = []
    var parent : UIViewController?
    var fontSize: CGFloat = UIFont.systemFontSize
    
    /// Base Color - Selector Text, Popup Button
    var baseColor : UIColor = UIColor(red: 0.0, green: 122/255, blue: 1.0, alpha: 1) {
        didSet {
            valueLabel.tintColor = baseColor
            btnCancel.setImage(buttonImage(type: .Cancel, color: baseColor), for: .normal)
            btnOK.setImage(buttonImage(type: .Done, color: baseColor), for: .normal)
        }
    }
    
    /// Frame Color
    var frameColor : UIColor = UIColor.lightGray {
        didSet {
            valueLabel.layer.borderColor  = frameColor.cgColor
        }
    }

    /// Frame width
    var frameWidth : CGFloat = 1 {
        didSet {
            valueLabel.layer.borderWidth  = 1
        }
    }
    
    /// Selected Row
    var selectedIndex : Int? = nil {
        didSet {
            if let idx = selectedIndex {
                if idx >= items.count {
                    selectedIndex = nil
                }
                
                if idx >= 0 {
                    let _idx = IndexPath(row: idx, section: 0)
                    tableView.selectRow(at: _idx, animated: false, scrollPosition: .none)
                } else {
                    if let _idx = tableView.indexPathForSelectedRow {
                        tableView.deselectRow(at: _idx, animated: false)
                    }
                }
            }
        }
    }
    
    /// Selected Value
    var selectedValue : String {
        get {
            if let idx = tableView.indexPathForSelectedRow {
                return items[idx.item]
            } else {
                return ""
            }
        }
    }
    
    /// Popup header height
    var popupHeaderHeight : CGFloat = 44
    
    /// Popup size for select view
    var popupSize : CGSize = CGSize(width: 200, height: 100) {
        didSet {
            if popupSize.height < 50 {
                popupSize.height = 50
            }
        }
    }
    
    /// Button size in popup view
    var popupButtonSize : CGFloat = 40 {
        didSet {
            let sz = CGSize(width: popupButtonSize, height: popupButtonSize)
            btnCancel.frame.size = sz
            btnOK.frame.size = sz
        }
    }
    
    var searchImageOn : Bool = true {
        didSet {
            if searchImageOn == true {
                valueLabel.setImage(buttonImage(type: .Search, color: UIColor.blue),
                                    for: .normal)
            } else {
                valueLabel.setImage(nil, for: .normal)
            }
            imageAdjust()
        }
    }

    // -----------------------------------------------------------
    // Functions
    // -----------------------------------------------------------
    
    /// Initialize
    public init(frame: CGRect, parent: UIViewController) {
        super.init(frame: frame)
        self.parent = parent
        setupSelector()
        setupPopupView()
    }
    
    public init(parent: UIViewController) {
        super.init(frame: CGRect.zero)
        self.parent = parent
        setupSelector()
        setupPopupView()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.parent = nil
        setupSelector()
        setupPopupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Layout
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateSelectorLayout()
    }
    
    // Setup selector object
    private func setupSelector() {

        valueLabel.layer.borderColor  = frameColor.cgColor
        valueLabel.tintColor = baseColor
        valueLabel.contentHorizontalAlignment = .left
        valueLabel.contentEdgeInsets.left  = 4
        valueLabel.contentEdgeInsets.right = 4
        valueLabel.layer.borderWidth  = frameWidth
        valueLabel.layer.cornerRadius = 10
        valueLabel.addTarget(self,
                             action: #selector(self.actionTapLabel(_:)),
                             for: .touchUpInside)

        self.addSubview(valueLabel)

    }
    
    // Setup popup view
    private func setupPopupView() {
        btnCancel.setImage(buttonImage(type: .Cancel, color: baseColor), for: .normal)
        btnOK.setImage(buttonImage(type: .Done, color: baseColor), for: .normal)

        tableView.dataSource = self
        tableView.delegate   = self
        tableView.allowsSelection = true
        tableView.allowsMultipleSelection = false
        tableView.canCancelContentTouches = true
        
        if let _parent = parent {
            popupSize = CGSize(width: _parent.view.bounds.width * 0.9,
                               height: _parent.view.bounds.height * 0.8)
        }
    }
    
    // update Selector Layout
    private func updateSelectorLayout() {
        valueLabel.frame = CGRect(x: 4, y: 4,
                                  width: self.bounds.width - 8 ,
                                  height: self.bounds.height - 8)
        imageAdjust()
    }
    
    private func imageAdjust() {
        if searchImageOn == true {
            valueLabel.titleEdgeInsets = UIEdgeInsets(top: 0,
                                                      left: -1 * popupButtonSize,
                                                      bottom: 0,
                                                      right: 0)
            valueLabel.imageEdgeInsets = UIEdgeInsets(top: 0,
                                                      left: valueLabel.bounds.width - popupButtonSize - 8,
                                                      bottom: 0,
                                                      right: 0)
        } else {
            valueLabel.titleEdgeInsets = UIEdgeInsets.zero
            valueLabel.imageEdgeInsets = UIEdgeInsets.zero
        }

    }
    
    // Header view of popup view
    private func popupHeaderView() -> UIView {
        let view = UIView()
        let btnSize = max(popupButtonSize, popupHeaderHeight)
        
        view.frame = CGRect(origin: CGPoint(x: 0, y: 0),
                            size: CGSize(width: popupSize.width, height: popupHeaderHeight) )
        
        btnCancel.center = CGPoint(x: btnSize / 2, y: popupHeaderHeight / 2)
        btnOK.center = CGPoint(x: view.frame.width - btnSize / 2, y: popupHeaderHeight / 2)
        
        btnCancel.addTarget(self, action: #selector(self.actionCancel), for: .touchUpInside)
        btnOK.addTarget(self, action: #selector(self.actionDone), for: .touchUpInside)

        view.addSubview(btnCancel)
        view.addSubview(btnOK)
        
        return view
    }
    
    /// Default image of popup view button
    private func buttonImage(type: ImgType, color: UIColor) -> UIImage? {
        let rect      = CGRect(x: 0, y: 0, width: popupButtonSize, height: popupButtonSize)
        let margin    = CGFloat(4)
        let lineWidth = CGFloat(1)
        var img : UIImage?
        
        UIGraphicsBeginImageContext(rect.size)
        
        if let contextImg:CGContext = UIGraphicsGetCurrentContext() {
            let circleSize = popupButtonSize - margin * 2
            let circleFrame = CGRect(x: margin, y: margin, width: circleSize, height: circleSize)
            
            contextImg.setStrokeColor(color.cgColor)
            contextImg.setLineWidth(lineWidth)

            let centerPos = CGPoint(x: rect.width  / 2,
                                    y: rect.height / 2 )
            
            switch type {
            case .Search:
                //
                contextImg.strokeEllipse(in: CGRect(x: margin + 2, y: margin + 2,
                                                    width: circleSize / 2,
                                                    height: circleSize / 2))
                contextImg.move(to: CGPoint(x: margin + 2 + (circleSize / 2) * 0.65 ,
                                            y: margin + 2 + (circleSize / 2)  ) )
                contextImg.addLine(to: CGPoint(x: margin + (circleSize / 2) ,
                                               y: margin + circleSize   ) )
                contextImg.closePath()
                contextImg.strokePath()

                break
                
            case .Cancel:
                //
                let factor    = CGFloat(0.5)
                contextImg.strokeEllipse(in: circleFrame)
                contextImg.move(to: CGPoint(x: centerPos.x - (circleSize / 2) * factor,
                                            y: centerPos.y - (circleSize / 2) * factor) )
                contextImg.addLine(to: CGPoint(x: centerPos.x + (circleSize / 2) * factor,
                                               y: centerPos.y + (circleSize / 2) * factor) )
                contextImg.closePath()
                contextImg.strokePath()
                
                //
                contextImg.move(to: CGPoint(x: centerPos.x + (circleSize / 2) * factor,
                                            y: centerPos.y - (circleSize / 2) * factor) )
                contextImg.addLine(to: CGPoint(x: centerPos.x - (circleSize / 2) * factor,
                                               y: centerPos.y + (circleSize / 2) * factor) )
                contextImg.closePath()
                contextImg.strokePath()
                break

            case .Done:
                let factor1    = CGFloat(0.3)
                let factor2    = CGFloat(0.7)
                let offset     = CGPoint(x: (circleSize / 2) * (factor1 - factor2) / 2,
                                         y: (circleSize / 2) * (factor2 - factor1) / 2)
                //
                contextImg.strokeEllipse(in: circleFrame)
                contextImg.move(to: CGPoint(x: centerPos.x - (circleSize / 2) * factor1 + offset.x,
                                            y: centerPos.y - (circleSize / 2) * factor1 + offset.y)  )
                contextImg.addLine(to: CGPoint(x: centerPos.x + offset.x,
                                               y: centerPos.y + offset.y ) )
                
                //
                contextImg.move(to: CGPoint(x: centerPos.x + offset.x ,
                                            y: centerPos.y + offset.y) )
                contextImg.addLine(to: CGPoint(x: centerPos.x + (circleSize / 2) * factor2 + offset.x,
                                               y: centerPos.y - (circleSize / 2) * factor2 + offset.y) )
                contextImg.closePath()
                contextImg.strokePath()
                break

            }
            
            
            img = UIGraphicsGetImageFromCurrentImageContext()
            
        }
        
        UIGraphicsEndImageContext()
        
        return img
    }
    
    private func updateValueLabel() {
        if let idx = selectedIndex {
            if idx < items.count {
                let text = items[idx]
                valueLabel.setTitle(text, for: .normal)
            }
        }
    }
    
    // -----------------------------------------------------------
    // Functions for Action
    // -----------------------------------------------------------

    /// Tap Selector
    @objc func actionTapLabel(_ sender: UIButton){
        defaultValue = selectedIndex
        if parent == nil {
            return
        }
        
        let contentVC = UIViewController()
        let header = popupHeaderView()
        contentVC.view.addSubview(header)

        tableView.frame = CGRect(x: 0, y: popupHeaderHeight,
                                 width: popupSize.width,
                                 height: popupSize.height - popupHeaderHeight)
        tableView.reloadData()
        contentVC.view.addSubview(tableView)
        
        contentVC.view.backgroundColor = UIColor.lightText
        contentVC.modalPresentationStyle = .popover
        contentVC.preferredContentSize = CGSize(width: popupSize.width, height: popupSize.height)
        contentVC.popoverPresentationController?.sourceView = sender
        contentVC.popoverPresentationController?.sourceRect = sender.bounds
        contentVC.popoverPresentationController?.permittedArrowDirections = .any
        contentVC.popoverPresentationController?.delegate = self
        
        if let idx = selectedIndex {
            let _idx = IndexPath(item: idx, section: 0)
            tableView.selectRow(at: _idx, animated: false, scrollPosition: .middle)
        }
        
        parent?.present(contentVC, animated: true, completion: nil)
    }

    /// Push cancel button
    @objc func actionCancel() {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    /// Push ok button
    @objc func actionDone() {
        selectedIndex = tableView.indexPathForSelectedRow?.item
        updateValueLabel()
        if let _index = selectedIndex {
            self.delegate?.selectedIndex(index: _index)
        }
        parent?.dismiss(animated: true, completion: nil)
    }
}

// -----------------------------------------------------------
// Function for popup view
// -----------------------------------------------------------
extension SHSelector : UITableViewDataSource, UITableViewDelegate {
    // Number of cell
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    // display cell
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        cell.textLabel?.text = items[indexPath.item]
        cell.accessoryType  = .none
        cell.selectionStyle = .none
        if tableView.indexPathForSelectedRow == indexPath {
            cell.accessoryType = .checkmark
        }
        if indexPath.item == defaultValue {
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: fontSize)
        } else {
            cell.textLabel?.font = UIFont.systemFont(ofSize: fontSize)
        }
        return cell
    }
    
    // Select cell
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .checkmark
    }
    
    // Deselect cell
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell =  tableView.cellForRow(at: indexPath)
        cell?.accessoryType = .none
    }
    
}

// -----------------------------------------------------------
// Popover Presentation Controller Delegate
// -----------------------------------------------------------
extension SHSelector :  UIPopoverPresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
