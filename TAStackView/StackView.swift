//
//  YLStackView.swift
//  TAStackView
//
//  Created by Tom Abraham on 7/12/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackView : UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }


  override init() {
    super.init(frame: CGRectZero)

    containerView.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(containerView)
  }

  private let containerView = StackContainerView()

  // TODO: make only privately mutable
  private(set) var views : [UIView] = []

  var edgeInsets : UIEdgeInsets = UIEdgeInsetsZero {
    didSet { setNeedsUpdateConstraints() }
  }

  var spacing : Float = DefaultSpacing {
    didSet { containerView.spacing = spacing }
  }

  var hasEqualSpacing : Bool = false {
    didSet { containerView.hasEqualSpacing = hasEqualSpacing }
  }

  var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet { containerView.alignment = alignment }
  }

  var orientation : YLUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      if (oldValue == orientation) { return }

      containerView.orientation = orientation

      alignment = orientation == .Horizontal ? .CenterY : .CenterX;
    }
  }

  func addView(var view : UIView, inGravity gravity : StackViewGravity) {
    gravityViewForGravity(gravity).addView(view)
  }

  // TODO: insertView:atIndex:inGravity
  // TODO: removeView:

  func setVisibilityPriority(visibilityPriority : StackViewVisibilityPriority, forView view : UIView) {
    gravityViewForGravity(view.gravityArea).setVisibilityPriority(visibilityPriority, forView: view)
  }

  func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return gravityViewForGravity(view.gravityArea).visibilityPriorityForView(view)
  }

  override func updateConstraints() {
    removeConstraints(constraints())

    let views = [ "containerView" : containerView ]._bridgeToObjectiveC()
    let metrics = [
      "l" : edgeInsets.left,
      "r" : edgeInsets.right,
      "t" : edgeInsets.top,
      "b" : edgeInsets.bottom
      ]._bridgeToObjectiveC()

    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(l)-[containerView]-(r)-|",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views) as [NSLayoutConstraint])
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(t)-[containerView]-(b)-|",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views) as [NSLayoutConstraint])

    super.updateConstraints()
  }

  private func gravityViewForGravity(gravity : StackViewGravity) -> StackGravityAreaView {
    switch (gravity) {
    case .Top:
      return containerView.gravityViews.top
    case .Leading:
      return containerView.gravityViews.leading
    case .Center:
      return containerView.gravityViews.center
    case .Trailing:
      return containerView.gravityViews.trailing
    case .Bottom:
      return containerView.gravityViews.bottom
    }
  }
}