//
//  StackContainerView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackContainerView : UIView {
  private var _gravityAreaContainingView = Dictionary<UnsafePointer<Void>, StackViewGravityArea>()

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoder not supported")
  }

  override init() {
    super.init(frame: CGRectZero)

    for gravityAreaView in gravityAreaViewsArray {  addSubview(gravityAreaView) }
    for spacerView in gravityAreaSpacerViewsArray { addSubview(spacerView) }
  }
  
// MARK: General
  
  var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet {
      if (oldValue == alignment) { return }
      
      gravityAreaViewsArray.map({ $0.alignment = self.alignment })
    }
  }
  
  var orientation : TAUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      if (oldValue == orientation) { return }
      
      gravityAreaViewsArray.map({ $0.orientation = self.orientation })
      gravityAreaSpacerViewsArray.map({ $0.orientation = self.orientation })
      
      setNeedsUpdateConstraints()
    }
  }
  
// MARK: Views
  
  var views : [UIView] {
    return gravityAreaViews.head.views + gravityAreaViews.center.views + gravityAreaViews.tail.views
  }

  var detachedViews : [UIView] {
    return gravityAreaViews.head.detachedViews + gravityAreaViews.center.detachedViews + gravityAreaViews.tail.detachedViews
  }

  func viewsInGravity(gravity : StackViewGravityArea) -> [UIView] {
    return gravityAreaViewForGravity(gravity).views
  }
  
  func addView(var view : UIView, inGravity gravity: StackViewGravityArea) {
    setGravityArea(gravity, containingView: view)
    gravityAreaViewForGravity(gravity).addView(view)
    
    setNeedsUpdateConstraints()
  }
  
  func insertView(view: UIView, atIndex index: Int, inGravity gravity: StackViewGravityArea) {
    setGravityArea(gravity, containingView: view)
    gravityAreaViewForGravity(gravity).insertView(view, atIndex: index)

    setNeedsUpdateConstraints()
  }
  
  func setViews(views : [UIView], inGravity gravity : StackViewGravityArea) {
    for view in views { setGravityArea(gravity, containingView: view) }
    gravityAreaViewForGravity(gravity).setViews(views)
    
    setNeedsUpdateConstraints()
  }
  
  func removeView(view : UIView) {
    gravityAreaViewForGravity(gravityAreaContainingView(view)).removeView(view)
    
    setNeedsUpdateConstraints()
  }
  
  private func setGravityArea(gravityArea : StackViewGravityArea, containingView view: UIView) {
    _gravityAreaContainingView[unsafeAddressOf(view)] = gravityArea
  }
  
  private func gravityAreaContainingView(view : UIView) -> StackViewGravityArea {
    return _gravityAreaContainingView[unsafeAddressOf(view)]!
  }
  
  private func gravityAreaViewForGravity(gravity : StackViewGravityArea) -> StackGravityAreaView {
    switch (gravity) {
    case .Top:
      return gravityAreaViews.head
    case .Leading:
      return gravityAreaViews.head
    case .Center:
      return gravityAreaViews.center
    case .Trailing:
      return gravityAreaViews.tail
    case .Bottom:
      return gravityAreaViews.tail
    }
  }
  
// MARK: Gravity Areas

  let gravityAreaViews = (
    head: StackGravityAreaView(),
    center: StackGravityAreaView(),
    tail: StackGravityAreaView()
  )

  let gravityAreaSpacerViews = (
    spacer1: StackSpacerView(),
    spacer2: StackSpacerView()
  )

  private var gravityAreaViewsArray : [StackGravityAreaView] {
    return [ gravityAreaViews.head, gravityAreaViews.center, gravityAreaViews.tail ]
  }

  private var gravityAreaSpacerViewsArray : [StackSpacerView] {
    return [ gravityAreaSpacerViews.spacer1, gravityAreaSpacerViews.spacer2 ]
  }
  
// MARK: Priorities

  private var horizontalClippingResistancePriority = DefaultClippingResistancePriority
  private var verticalClippingResistancePriority = DefaultClippingResistancePriority
  private var horizontalHuggingPriority = DefaultHuggingPriority
  private var verticalHuggingPriority = DefaultHuggingPriority

  
  func setClippingResistancePriority(priority : UILayoutPriority, forAxis axis : UILayoutConstraintAxis) {
    if (axis == .Horizontal) {
      horizontalClippingResistancePriority = priority
    } else {
      verticalClippingResistancePriority = priority
    }
  }
  
  func clippingResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return axis == .Horizontal ? horizontalClippingResistancePriority : verticalClippingResistancePriority
  }
  
  func setHuggingPriority(priority : UILayoutPriority, forAxis axis : UILayoutConstraintAxis) {
    if (axis == .Horizontal) {
      horizontalHuggingPriority = priority
    } else {
      verticalHuggingPriority = priority
    }
  }
  
  func huggingPriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return axis == .Horizontal ? horizontalHuggingPriority : verticalHuggingPriority
  }
  
  func setVisibilityPriority(visibilityPriority : StackViewVisibilityPriority, forView view : UIView) {
    gravityAreaViewForGravity(gravityAreaContainingView(view)).setVisibilityPriority(visibilityPriority, forView: view)
    
    setNeedsUpdateConstraints()
  }
  
  func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return gravityAreaViewForGravity(gravityAreaContainingView(view)).visibilityPriorityForView(view)
  }
  
// MARK: Spacing
  
  func setCustomSpacing(spacing: Float?, afterView view: UIView) {
    gravityAreaViewForGravity(gravityAreaContainingView(view)).setCustomSpacing(spacing, afterView: view)
    
    setNeedsUpdateConstraints()
  }
  
  func customSpacingAfterView(view : UIView) -> Float? {
    return gravityAreaViewForGravity(gravityAreaContainingView(view)).customSpacingAfterView(view)
  }
  
  var spacing : Float = DefaultSpacing {
    didSet {
      gravityAreaViewsArray.map({ $0.spacing = self.spacing })
      
      setNeedsUpdateConstraints()
    }
  }
  
  var hasEqualSpacing : Bool = false {
    didSet { setNeedsUpdateConstraints() }
  }

// MARK: Layout
  
  override func updateConstraints() {
    let axis = orientation.toAxis()

    let head = gravityAreaViews.head
    let center = gravityAreaViews.center
    let tail = gravityAreaViews.tail
        
    let spacer1 = gravityAreaSpacerViews.spacer1
    let spacer2 = gravityAreaSpacerViews.spacer2

    let views = [
      "head": head,
      "spacer1": spacer1,
      "center": center,
      "spacer2": spacer2,
      "tail": tail
    ]

    let char = orientation.toCharacter()

    func _mainConstraintsForAxis() -> [NSLayoutConstraint] {
      var vfls : [String] = []
      
      if (head.shouldShow && center.shouldShow && tail.shouldShow) {       // 111
        vfls = [ "\(char):|[head][spacer1][center][spacer2][tail]|" ]
      } else if (head.shouldShow && center.shouldShow && !tail.shouldShow) { // 110
        vfls = [ "\(char):|[head][spacer1][center][spacer2]|" ]
      } else if (head.shouldShow && !center.shouldShow && tail.shouldShow) { // 101
        vfls = [ "\(char):|[head][spacer1][tail]|" ]
      } else if (head.shouldShow && !center.shouldShow && !tail.shouldShow) {  // 100
        vfls = [ "\(char):|[head][spacer1]|" ]
      } else if (!head.shouldShow && center.shouldShow && tail.shouldShow) { // 011
        vfls = [ "\(char):|[spacer1][center][spacer2][tail]|" ]
      } else if (!head.shouldShow && center.shouldShow && !tail.shouldShow) {  // 010
        vfls = [ "\(char):|[spacer1][center][spacer2]|" ]
      } else if (!head.shouldShow && !center.shouldShow && tail.shouldShow) {  // 001
        vfls = [ "\(char):|[spacer1][tail]|" ]
      } else if (head.shouldShow && center.shouldShow && tail.shouldShow) { // 000
        // TODO
      }
      
      return NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: [:], views: views)
    }
    
    func _updateInterGravityAreaSpacing() {
      let hP = huggingPriorityForAxis(axis)

      spacer1.spacing = head.shouldShow && (center.shouldShow || tail.shouldShow) ? head.spacingAfter : 0
      spacer1.spacingPriority = hP
      
      spacer2.spacing = center.shouldShow && tail.shouldShow ? center.spacingAfter : 0
      spacer2.spacingPriority = hP
    }
    
    func _centerGravityAreaCenteringConstraint() -> NSLayoutConstraint {
      let centeringAttribute : NSLayoutAttribute = orientation == .Horizontal ? .CenterX : .CenterY
      
      let centeringConstraint = NSLayoutConstraint(
        item: center, attribute: centeringAttribute,
        relatedBy: .Equal,
        toItem: self, attribute: centeringAttribute,
        multiplier: 1, constant: 0)
      
      centeringConstraint.priority = CenterGravityAreaCenteringPriority

      return centeringConstraint;
    }
    
    func _constraintsForOtherAxis() -> [NSLayoutConstraint] {
      let otherChar = orientation.other().toCharacter()
      let vfls = [ "\(otherChar):|[head]|", "\(otherChar):|[center]|", "\(otherChar):|[tail]|" ]
      return NSLayoutConstraint.constraintsWithVisualFormats(vfls,
        options: NSLayoutFormatOptions(0), metrics: [:], views: views)
    }

    func _constraintsForEqualSpacing() -> [NSLayoutConstraint] {
      func _constraintEquating(attribute: NSLayoutAttribute, ofView view1: UIView, andView view2: UIView) -> NSLayoutConstraint {
        return NSLayoutConstraint(item: view1, attribute: attribute,
          relatedBy: .Equal,
          toItem: view2, attribute: attribute,
          multiplier: 1.0, constant: 0.0)
      }
      
      let attribute : NSLayoutAttribute = orientation == .Horizontal ? .Width : .Height
      
      var cs : [NSLayoutConstraint] = []

      // spacer2 equals spacer1
      cs.append(_constraintEquating(attribute, ofView: spacer2, andView: spacer1))
      
      // each spacer in each gravity area equals spacer1
      for gravityAreaView in gravityAreaViewsArray {
        for spacer in gravityAreaView.spacers {
          cs.append(_constraintEquating(attribute, ofView: spacer, andView: spacer1))
        }
      }
      
      return cs
    }

    removeConstraints(constraints())
    addConstraints(_mainConstraintsForAxis())
    addConstraint(_centerGravityAreaCenteringConstraint())
    addConstraints(_constraintsForOtherAxis())
    if (hasEqualSpacing) { addConstraints(_constraintsForEqualSpacing()) }

    _updateInterGravityAreaSpacing()

    super.updateConstraints()
  }
}