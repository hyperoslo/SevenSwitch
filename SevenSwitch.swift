//
//  SevenSwitch.swift
//
//  Created by Benjamin Vogelzang on 6/20/14.
//  Copyright (c) 2014 Ben Vogelzang. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import UIKit
import QuartzCore

let uiswitchFrame = CGRect(x: 0, y: 0, width: 51, height: 31)

@IBDesignable @objc public class SevenSwitch: UIControl {
    
    // public
    
    /*
    *   Set (without animation) whether the switch is on or off
    */
    @IBInspectable public var on: Bool {
        get {
            return switchValue
        }
        set {
            switchValue = newValue
            self.setOn(newValue, animated: false)
        }
    }

    /*
    *	Sets the background color that shows when the switch off and actively being touched.
    *   Defaults to light gray.
    */
    @IBInspectable public var activeColor: UIColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the background color when the switch is off.
    *   Defaults to clear color.
    */
    @IBInspectable public var inactiveColor: UIColor = UIColor.clearColor() {
        willSet {
            if !self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *   Sets the background color that shows when the switch is on.
    *   Defaults to green.
    */
    @IBInspectable public var onTintColor: UIColor = UIColor(red: 0.3, green: 0.85, blue: 0.39, alpha: 1) {
        willSet {
            if self.on && !self.tracking {
                backgroundView.backgroundColor = newValue
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    /*
    *   Sets the border color that shows when the switch is off. Defaults to light gray.
    */
    @IBInspectable public var borderColor: UIColor = UIColor(red: 0.78, green: 0.78, blue: 0.8, alpha: 1) {
        willSet {
            if !self.on {
                backgroundView.layer.borderColor = newValue.CGColor
            }
        }
    }
    
    /*
    *	Sets the knob color. Defaults to white.
    */
    @IBInspectable public var thumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            if !userDidSpecifyOnThumbTintColor {
                onThumbTintColor = newValue
            }
            if (!userDidSpecifyOnThumbTintColor || !self.on) && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the knob color that shows when the switch is on. Defaults to white.
    */
    @IBInspectable public var onThumbTintColor: UIColor = UIColor.whiteColor() {
        willSet {
            userDidSpecifyOnThumbTintColor = true
            if self.on && !self.tracking {
                thumbView.backgroundColor = newValue
            }
        }
    }
    
    /*
    *	Sets the text color when the switch is on.
    *   Defaults to gray.
    */
    @IBInspectable public var onTextColor: UIColor = .grayColor() {
        willSet {
            if self.on && !self.tracking {
                textLabel.textColor = newValue
            }
        }
    }
    
    /*
    *	Sets the text color when the switch is off.
    *   Defaults to gray.
    */
    @IBInspectable public var offTextColor: UIColor = .grayColor() {
        willSet {
            if !self.on && !self.tracking {
                textLabel.textColor = newValue
            }
        }
    }
    
    /*
    *	Sets the shadow color of the knob. Defaults to gray.
    */
    @IBInspectable public var shadowColor: UIColor = UIColor.grayColor() {
        willSet {
            thumbView.layer.shadowColor = newValue.CGColor
        }
    }
    
    /*
    *	Sets whether or not the switch edges are rounded.
    *   Set to NO to get a stylish square switch.
    *   Defaults to YES.
    */
    @IBInspectable public var isRounded: Bool = true {
        willSet {
            if newValue {
                backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
                thumbView.layer.cornerRadius = (knobSize.height * 0.5) - 1
            }
            else {
                backgroundView.layer.cornerRadius = 2
                thumbView.layer.cornerRadius = 2
            }
            
            thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        }
    }
    
    /*
    *   Sets the image that shows on the switch thumb.
    */
    @IBInspectable public var thumbImage: UIImage! {
        willSet {
            thumbImageView.image = newValue
        }
    }
    
    /*
    *   Sets the image that shows when the switch is on.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable public var onImage: UIImage! {
        willSet {
            onImageView.image = newValue
        }
    }
    
    /*
    *	Sets the image that shows when the switch is off.
    *   The image is centered in the area not covered by the knob.
    *   Make sure to size your images appropriately.
    */
    @IBInspectable public var offImage: UIImage! {
        willSet {
            offImageView.image = newValue
        }
    }
    
    /*
    *	Sets the text that shows when the switch is on.
    *   The text is centered in the area not covered by the knob.
    */
    public var onLabel: UILabel!
    
    /*
    *	Sets the text that shows when the switch is off.
    *   The text is centered in the area not covered by the knob.
    */
    public var offLabel: UILabel!
    
    /*
    *	For customizations only. Text should be set to knobTest
    *   The size of the knob changes depending on the text size.
    */
    public var textLabel: UILabel!
    
    /*
    *	Set text which appears on top of the knob
    *   The size of the knob changes depending on the text size.
    */
    public var knobText: String! {
        didSet {
            textLabel.text = knobText
            textLabel.sizeToFit()
            knobSize.width = textLabel.frame.size.width + self.frame.height - knobMargin
            layoutSubviews()
        }
    }
    
    /*
    *   Sets the margin between switch bounds and knob
    *   Apple uses 1.5pt as a default value
    */
    public var knobMargin: CGFloat = 1.5 {
        willSet {
            let newWidth = knobSize.width + (knobMargin - newValue) * 2
            let newHeight = knobSize.height + (knobMargin - newValue) * 2
            knobSize = CGSize(width: newWidth, height: newHeight)
        }
    }

    // internal
    public var backgroundView: UIView!
    public var thumbView: UIView!
    internal var onImageView: UIImageView!
    internal var offImageView: UIImageView!
    internal var thumbImageView: UIImageView!
    // private
    private var currentVisualValue: Bool = false
    private var startTrackingValue: Bool = false
    private var didChangeWhileTracking: Bool = false
    private var isAnimating: Bool = false
    private var userDidSpecifyOnThumbTintColor: Bool = false
    private var switchValue: Bool = false
    var knobSize: CGSize = CGSize.zero

    
    /*
    *   Initialization
    */
    public convenience init() {
        self.init(frame: uiswitchFrame)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    override public init(frame: CGRect) {
        let initialFrame = CGRectIsEmpty(frame) ? uiswitchFrame : frame
        super.init(frame: initialFrame)
        
        self.setup()
    }
    
    
    /*
    *   Setup the individual elements of the switch and set default values
    */
    private func setup() {
        
        // margin
        let knobDiameter = self.frame.height - knobMargin * 2
        knobSize = CGSize (width: knobDiameter, height: knobDiameter)
        
        // background
        self.backgroundView = UIView(frame: CGRectMake(0, 0, self.frame.size.width, self.frame.size.height))
        backgroundView.backgroundColor = UIColor.clearColor()
        backgroundView.layer.cornerRadius = self.frame.size.height * 0.5
        backgroundView.layer.borderColor = self.borderColor.CGColor
        backgroundView.layer.borderWidth = 1.0
        backgroundView.userInteractionEnabled = false
        backgroundView.clipsToBounds = true
        self.addSubview(backgroundView)
        
        // on/off images
        self.onImageView = UIImageView(frame: CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        onImageView.alpha = 1.0
        onImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(onImageView)
        
        self.offImageView = UIImageView(frame: CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        offImageView.alpha = 1.0
        offImageView.contentMode = UIViewContentMode.Center
        backgroundView.addSubview(offImageView)
        
        // labels
        self.onLabel = UILabel(frame: CGRectMake(0, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        onLabel.textAlignment = NSTextAlignment.Center
        onLabel.textColor = UIColor.lightGrayColor()
        onLabel.font = UIFont.systemFontOfSize(12)
        backgroundView.addSubview(onLabel)
        
        self.offLabel = UILabel(frame: CGRectMake(self.frame.size.height, 0, self.frame.size.width - self.frame.size.height, self.frame.size.height))
        offLabel.textAlignment = NSTextAlignment.Center
        offLabel.textColor = UIColor.lightGrayColor()
        offLabel.font = UIFont.systemFontOfSize(12)
        backgroundView.addSubview(offLabel)

        textLabel = UILabel()
        textLabel.textColor = offTextColor
        textLabel.font = .systemFontOfSize(12)
        
        // thumb
        self.thumbView = UIView(frame: CGRectMake(knobMargin, knobMargin, knobSize.width, knobSize.height))
        thumbView.backgroundColor = self.thumbTintColor
        thumbView.layer.cornerRadius = (knobSize.height * 0.5) - 1
        thumbView.layer.shadowColor = self.shadowColor.CGColor
        thumbView.layer.shadowRadius = 2.0
        thumbView.layer.shadowOpacity = 0.5
        thumbView.layer.shadowOffset = CGSizeMake(0, 3)
        thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
        thumbView.layer.masksToBounds = false
        thumbView.userInteractionEnabled = false
        self.addSubview(thumbView)
        
        // thumb image
        self.thumbImageView = UIImageView(frame: CGRectMake(0, 0, thumbView.frame.size.width, thumbView.frame.size.height))
        thumbImageView.contentMode = UIViewContentMode.Center
        thumbImageView.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        thumbView.addSubview(thumbImageView)
        
        thumbImageView.addSubview(textLabel)

        self.on = false
    }
    
    override public func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.beginTrackingWithTouch(touch, withEvent: event)
        
        startTrackingValue = self.on
        didChangeWhileTracking = false
        
        let activeKnobWidth = knobSize.width + 5
        isAnimating = true
        
        UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                if self.on {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + self.knobMargin), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                    self.backgroundView.backgroundColor = self.onTintColor
                    self.thumbView.backgroundColor = self.onThumbTintColor
                }
                else {
                    self.thumbView.frame = CGRectMake(self.knobMargin, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                    self.backgroundView.backgroundColor = self.activeColor
                    self.thumbView.backgroundColor = self.thumbTintColor
                }
            }, completion: { finished in
                self.isAnimating = false
        })
        
        return true
    }
    
    override public func continueTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
        super.continueTrackingWithTouch(touch, withEvent: event)

        if !isAnimating {

            // Get touch location
            let lastPoint = touch.locationInView(self)

            // update the switch to the correct visuals depending on if
            // they moved their touch to the right or left side of the switch
            if lastPoint.x > self.bounds.size.width * 0.5 {
                self.showOn(true)
                if !startTrackingValue {
                    didChangeWhileTracking = true
                }
            }
            else {
                self.showOff(true)
                if startTrackingValue {
                    didChangeWhileTracking = true
                }
            }
        }
        return true
    }
    
    override public func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        super.endTrackingWithTouch(touch, withEvent: event)

        let previousValue = self.on

        if didChangeWhileTracking {
            self.setOn(currentVisualValue, animated: true)
        }
        else {
            self.setOn(!self.on, animated: true)
        }
        
        if previousValue != self.on {
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    override public func cancelTrackingWithEvent(event: UIEvent?) {
        super.cancelTrackingWithEvent(event)
        
        // just animate back to the original value
        if self.on {
            self.showOn(true)
        }
        else {
            self.showOff(true)
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        if !isAnimating {
            let frame = self.frame
            
            recalculateKnobSize()
            
            // background
            backgroundView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height)
            backgroundView.layer.cornerRadius = self.isRounded ? frame.size.height * 0.5 : 2
            
            // images
            onImageView.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)
            offImageView.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)
            self.onLabel.frame = CGRectMake(0, 0, frame.size.width - frame.size.height, frame.size.height)
            self.offLabel.frame = CGRectMake(frame.size.height, 0, frame.size.width - frame.size.height, frame.size.height)
            
            // thumb
            let normalKnobWidth = knobSize.width
            if self.on {
                thumbView.frame = CGRectMake(frame.size.width - (normalKnobWidth + knobMargin), knobMargin, normalKnobWidth, knobSize.height)
            }
            else {
                thumbView.frame = CGRectMake(knobMargin, knobMargin, normalKnobWidth, knobSize.height)
            }
            
            thumbView.layer.cornerRadius = self.isRounded ? (knobSize.height * 0.5)  : 2
            thumbView.layer.shadowPath = UIBezierPath(roundedRect: thumbView.bounds, cornerRadius: thumbView.layer.cornerRadius).CGPath
            
            var center = thumbView.center
            center.y = center.y - knobMargin
            center.x = center.x - knobMargin
            textLabel.center = center
        }
    }
    
    func recalculateKnobSize () {
        knobSize.width = textLabel.frame.size.width + self.frame.height - knobMargin
        knobSize.height = self.frame.height - knobMargin * 2
    }
    
    /*
    *   Set the state of the switch to on or off, optionally animating the transition.
    */
    public func setOn(isOn: Bool, animated: Bool) {
        switchValue = isOn
        
        if on {
            self.showOn(animated)
        }
        else {
            self.showOff(animated)
        }
    }
    
    /*
    *   Detects whether the switch is on or off
    *
    *	@return	BOOL YES if switch is on. NO if switch is off
    */
    public func isOn() -> Bool {
        return self.on
    }
    
    /*
    *   update the looks of the switch to be in the on position
    *   optionally make it animated
    */
    private func showOn(animated: Bool) {
        let normalKnobWidth = knobSize.width
        let activeKnobWidth = normalKnobWidth + 5
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                if self.tracking {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + self.knobMargin), self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height)
                }
                else {
                    self.thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + self.knobMargin), self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height)
                    self.textLabel.textColor = self.onTextColor
                }
                
                self.backgroundView.backgroundColor = self.onTintColor
                self.backgroundView.layer.borderColor = self.onTintColor.CGColor
                self.thumbView.backgroundColor = self.onThumbTintColor
                self.onImageView.alpha = 1.0
                self.offImageView.alpha = 0
                self.onLabel.alpha = 1.0
                self.offLabel.alpha = 0
            }, completion: { finished in
                self.isAnimating = false
            })
        }
        else {
            if self.tracking {
                thumbView.frame = CGRectMake(self.bounds.size.width - (activeKnobWidth + knobMargin), thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
            }
            else {
                self.textLabel.textColor = self.onTextColor
                thumbView.frame = CGRectMake(self.bounds.size.width - (normalKnobWidth + knobMargin), thumbView.frame.origin.y, normalKnobWidth, thumbView.frame.size.height)
            }
            
            backgroundView.backgroundColor = self.onTintColor
            backgroundView.layer.borderColor = self.onTintColor.CGColor
            thumbView.backgroundColor = self.onThumbTintColor
            onImageView.alpha = 1.0
            offImageView.alpha = 0
            onLabel.alpha = 1.0
            offLabel.alpha = 0
        }
        
        currentVisualValue = true
    }
    
    /*
    *   update the looks of the switch to be in the off position
    *   optionally make it animated
    */
    private func showOff(animated: Bool) {
        let normalKnobWidth = knobSize.width
        let activeKnobWidth = normalKnobWidth + 5
        
        if animated {
            isAnimating = true
            UIView.animateWithDuration(0.3, delay: 0.0, options: [UIViewAnimationOptions.CurveEaseOut, UIViewAnimationOptions.BeginFromCurrentState], animations: {
                if self.tracking {
                    self.thumbView.frame = CGRectMake(self.knobMargin, self.thumbView.frame.origin.y, activeKnobWidth, self.thumbView.frame.size.height);
                    self.backgroundView.backgroundColor = self.activeColor
                }
                else {
                    self.thumbView.frame = CGRectMake(self.knobMargin, self.thumbView.frame.origin.y, normalKnobWidth, self.thumbView.frame.size.height);
                    self.backgroundView.backgroundColor = self.inactiveColor
                    self.textLabel.textColor = self.offTextColor
                }
                self.backgroundView.layer.borderColor = self.borderColor.CGColor
                self.thumbView.backgroundColor = self.thumbTintColor
                self.onImageView.alpha = 0
                self.offImageView.alpha = 1.0
                self.onLabel.alpha = 0
                self.offLabel.alpha = 1.0
                
            }, completion: { finished in
                self.isAnimating = false
            })
        }
        else {
            if (self.tracking) {
                thumbView.frame = CGRectMake(self.knobMargin, thumbView.frame.origin.y, activeKnobWidth, thumbView.frame.size.height)
                backgroundView.backgroundColor = self.activeColor
            }
            else {
                thumbView.frame = CGRectMake(self.knobMargin, thumbView.frame.origin.y, normalKnobWidth, thumbView.frame.size.height)
                backgroundView.backgroundColor = self.inactiveColor
            }
            textLabel.textColor = offTextColor
            backgroundView.layer.borderColor = self.borderColor.CGColor
            thumbView.backgroundColor = self.thumbTintColor
            onImageView.alpha = 0
            offImageView.alpha = 1.0
            onLabel.alpha = 0
            offLabel.alpha = 1.0
        }
        
        currentVisualValue = false
    }
    
    
}
