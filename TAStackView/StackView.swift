//
//  YLStackView.swift
//  TAStackView
//
//  Created by Tom Abraham on 7/12/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

@objc(TAStackView) public class StackView : UIView {
  private let containerView = StackContainerView()
  
  public required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  public override init() {
    super.init(frame: CGRectZero)

    containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(containerView)
  }

  public convenience init(views : [UIView]) {
    self.init()

    // the NSStackView spec says so...
    setTranslatesAutoresizingMaskIntoConstraints(false)
    
    for view in views { addView(view, inGravity: .Leading) }
  }
  
// MARK: General
  
  public var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet { containerView.alignment = alignment }
  }

  public var orientation : TAUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      if (oldValue == orientation) { return }

      containerView.orientation = orientation

      alignment = orientation == .Horizontal ? .CenterY : .CenterX;
    }
  }
  
// MARK: Views
  public func addView(view : UIView, inGravity gravity : StackViewGravityArea) {
    containerView.addView(view, inGravity: gravity)
  }
  
  public func insertView(view : UIView, atIndex index: Int, inGravity gravity: StackViewGravityArea) {
    containerView.insertView(view, atIndex: index, inGravity: gravity)
  }
  
  public func setViews(views : [UIView], inGravity gravity : StackViewGravityArea) {
    containerView.setViews(views, inGravity: gravity)
  }
  
  public func removeView(view : UIView) {
    containerView.removeView(view)
  }
  
// TODO: Spacing

  public func setCustomSpacing(spacing: Float, afterView view: UIView) {
    containerView.setCustomSpacing(spacing == TAStackViewSpacingUseDefault ? nil : spacing, afterView: view)
  }
  
  public func customSpacingAfterView(view : UIView) -> Float {
    return containerView.customSpacingAfterView(view) ?? TAStackViewSpacingUseDefault
  }
  
  public var spacing : Float = DefaultSpacing {
    didSet { containerView.spacing = spacing }
  }
  
  public var hasEqualSpacing : Bool = false {
    didSet { containerView.hasEqualSpacing = hasEqualSpacing }
  }
  
  public var edgeInsets : UIEdgeInsets = UIEdgeInsetsZero {
    didSet { setNeedsUpdateConstraints() }
  }
  
// MARK: Priorities

  public func setVisibilityPriority(visibilityPriority : StackViewVisibilityPriority, forView view : UIView) {
    containerView.setVisibilityPriority(visibilityPriority, forView: view)
  }

  public func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return containerView.visibilityPriorityForView(view)
  }
  
  public func setClippingResistancePriority(priority : UILayoutPriority, forAxis axis : UILayoutConstraintAxis) {
    containerView.setClippingResistancePriority(priority, forAxis: axis)
    
    setNeedsUpdateConstraints()
  }
  
  public func clippingResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return containerView.clippingResistancePriorityForAxis(axis)
  }
  
  public func setHuggingPriority(priority : UILayoutPriority, forAxis axis : UILayoutConstraintAxis) {
    containerView.setHuggingPriority(priority, forAxis: axis)
  }
  
  public func huggingPriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return containerView.huggingPriorityForAxis(axis)
  }
  
// MARK: Layout

  override public func updateConstraints() {
    removeConstraints(constraints())

    let views = [ "containerView" : containerView ]._bridgeToObjectiveC()
    let metrics = [
      "l": edgeInsets.left,
      "t": edgeInsets.top,
      
      "b": edgeInsets.bottom,
      "CRp_v": clippingResistancePriorityForAxis(UILayoutConstraintAxis.Vertical),
      
      "r": edgeInsets.right,
      "CRp_h": clippingResistancePriorityForAxis(.Horizontal),
    ]

    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(l)-[containerView]-(r@CRp_h,<=r)-|",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views) as [NSLayoutConstraint])
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(t)-[containerView]-(b@CRp_v,<=b)-|",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views) as [NSLayoutConstraint])

    super.updateConstraints()
  }
}