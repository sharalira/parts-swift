//
//  SHStepper.swift
//  SHObjects
//
//  Created by Hiroyuki Yamamoto on 2019/05/05.
//  Copyright © 2019 Hiroyuki Yamamoto. All rights reserved.
//

import UIKit

public class SHStepper : UIControl {

    // -----------------------------------------------------------
    // UI Objects
    // -----------------------------------------------------------
    private var leftButton : UIButton = UIButton(type: UIButton.ButtonType.system)
    private var rightButton : UIButton = UIButton(type: UIButton.ButtonType.system)
    private var valueLabel : UILabel = UILabel()

    
    // -----------------------------------------------------------
    // Enum
    // -----------------------------------------------------------

    private enum ImgType : Int {
        case Minus = 0
        case Plus  = 1
    }
    
    // -----------------------------------------------------------
    // Properties
    // -----------------------------------------------------------

    /// Value
    var value: Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue,value))
            valueLabel.text = value.description
            
            if oldValue != value {
                sendActions(for: .valueChanged)
            }
        }
    }
    
    /// Minimum Value
    var minimumValue : Double = 0 {
        didSet {
            value = min(maximumValue, max(minimumValue,value))
        }
    }
    
    /// Maximum Value
    var maximumValue : Double = 1 {
        didSet {
            value = min(maximumValue, max(minimumValue,value))
        }
    }
    
    /// Step value
    var stepValue : Double = 1
    
    /// Normal Color of buttons
    var buttonColorNormal   : UIColor = UIColor.blue {
        didSet {
            leftButton.setImage(buttonImages(type: .Minus,color: buttonColorNormal), for: .normal)
            rightButton.setImage(buttonImages(type: .Plus,color: buttonColorNormal), for: .normal)
        }
    }
    
    /// Button size of left and right buttons
    var buttonSize : CGFloat = 44 {
        didSet {
            setButtonSize()
        }
    }
    
    /// Value text color
    var textColor : UIColor = UIColor.blue {
        didSet{
            valueLabel.textColor = textColor
        }
    }
    
    /// Value text font
    var textFont : UIFont = UIFont.systemFont(ofSize: UIFont.systemFontSize) {
        didSet {
            valueLabel.font = textFont
        }
    }
    
    var viewMargin : UIEdgeInsets = UIEdgeInsets.zero {
        didSet {
            self.setNeedsLayout()
        }
    }

    // -----------------------------------------------------------
    // Functions
    // -----------------------------------------------------------

    /// Initialize
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
    
    private func setup() {
        self.backgroundColor = UIColor.white
        leftButton.setImage(buttonImages(type: .Minus,color: buttonColorNormal), for: .normal)
        leftButton.addTarget(self,
                             action: #selector(self.actionMinus),
                             for: .touchDown)

        rightButton.setImage(buttonImages(type: .Plus, color: buttonColorNormal), for: .normal)
        rightButton.addTarget(self,
                              action: #selector(self.actionPlus),
                              for: .touchDown)

        valueLabel.text = value.description
        valueLabel.textAlignment = .center
        
        addSubview(leftButton)
        addSubview(rightButton)
        addSubview(valueLabel)
    }
    
    private func updateLayout() {
        let spacing  = CGFloat(4)
        let height   = max(0, self.bounds.height - viewMargin.top - viewMargin.bottom)
        let width    = max(0, self.bounds.width  - viewMargin.left - viewMargin.right)
        let lblWidth = max(0, width - buttonSize * 2 - spacing * 2 )
        
        setButtonSize()
        valueLabel.frame.size = CGSize(width: lblWidth, height: height)
        
        leftButton.center  = CGPoint(x: viewMargin.left + buttonSize / 2, y:viewMargin.top + height / 2)
        valueLabel.center  = CGPoint(x: viewMargin.left + width / 2, y: viewMargin.top + height / 2)
        rightButton.center = CGPoint(x: self.bounds.width - viewMargin.right - buttonSize / 2, y: viewMargin.top + height / 2)

    
        updateValue()
    }
    
    /// Set size for left button and right button
    private func setButtonSize() {
        let sz = CGSize(width: buttonSize, height: buttonSize)
        leftButton.frame.size  = sz
        rightButton.frame.size = sz
    }
    
    /// Update Value
    private func updateValue(){
        if value == minimumValue {
            leftButton.isEnabled = false
        } else if value == maximumValue {
            rightButton.isEnabled = false
        } else {
            leftButton.isEnabled = true
            rightButton.isEnabled = true
        }
    }
    
    /// Get default button Image
    private func buttonImages(type: ImgType , color: UIColor) -> UIImage? {
        let rect      = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        let margin    = CGFloat(4)
        let lineWidth = CGFloat(1)
        let factor    = CGFloat(0.5)
        var img : UIImage?
        
        UIGraphicsBeginImageContext(rect.size)
        
        if let contextImg:CGContext = UIGraphicsGetCurrentContext() {
            let circleSize = buttonSize - margin * 2
            let circleFrame = CGRect(x: margin, y: margin, width: circleSize, height: circleSize)
            
            contextImg.setStrokeColor(color.cgColor)
            contextImg.strokeEllipse(in: circleFrame)
            contextImg.setLineWidth(lineWidth)
            
            let centerPos = CGPoint(x: rect.width  / 2,
                                    y: rect.height / 2 )

            switch type {
            case .Minus:
                contextImg.stroke(CGRect(x: centerPos.x - (circleSize / 2) * factor,
                                         y: centerPos.y - lineWidth / 2,
                                         width: circleSize * factor,
                                         height: lineWidth))
            case .Plus:
                contextImg.stroke(CGRect(x: centerPos.x - (circleSize / 2) * factor,
                                         y: centerPos.y - lineWidth / 2,
                                         width: circleSize * factor,
                                         height: lineWidth))

                contextImg.stroke(CGRect(x: centerPos.x - lineWidth / 2,
                                         y: centerPos.y - (circleSize / 2) * factor,
                                         width: lineWidth,
                                         height: circleSize * factor))
            }

            
            img = UIGraphicsGetImageFromCurrentImageContext()
            
        }
        
        UIGraphicsEndImageContext()
        
        return img

    }
    
    /// Change left button image
    func leftButtonImage(image: UIImage, for state: UIControl.State) {
        leftButton.setImage(image, for: state)
    }
    
    /// Change right button image
    func rightButtonImage(image: UIImage, for state: UIControl.State) {
        rightButton.setImage(image, for: state)
    }

    // -----------------------------------------------------------
    // Functions for Action
    // -----------------------------------------------------------
    
    /// Decrement value
    @objc func actionMinus(){
        let _value = self.value - self.stepValue
        self.value = max(minimumValue, _value)
        updateValue()
    }
    
    /// Increment value
    @objc func actionPlus(){
        let _value = self.value + self.stepValue
        self.value = min(maximumValue,_value)
        updateValue()
    }
}
