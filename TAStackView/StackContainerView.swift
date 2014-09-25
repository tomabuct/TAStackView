//
//  StackContainerView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackContainerView : UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoder not supported")
  }

  override init() {
    super.init(frame: CGRectZero)

    for gravityView in gravityViewsArray { addSubview(gravityView) }
    for spacerView in gravityAreaSpacerViewsArray { addSubview(spacerView) }

    _installConstraints()
  }

  func _installConstraints() {
    for gravityView in gravityViewsArray { gravityView.setTranslatesAutoresizingMaskIntoConstraints(false) }
  }

  let gravityViews = (
    top: StackGravityAreaView(),
    leading: StackGravityAreaView(),
    center: StackGravityAreaView(),
    trailing: StackGravityAreaView(),
    bottom: StackGravityAreaView()
  )

  let gravityAreaSpacerViews = (
    headCenter: UIView(),
    headTail: UIView(),
    centerTail: UIView()
  )

  private var gravityViewsArray : [StackGravityAreaView] {
    return [ gravityViews.top, gravityViews.leading, gravityViews.center, gravityViews.trailing, gravityViews.bottom ]
  }

  private var gravityAreaSpacerViewsArray : [UIView] {
    return [ gravityAreaSpacerViews.headCenter, gravityAreaSpacerViews.headTail, gravityAreaSpacerViews.centerTail ]
  }

  var spacing : Float = DefaultSpacing {
    didSet {
      gravityViewsArray.map({ $0.spacing = self.spacing })

      setNeedsUpdateConstraints()
    }
  }

  var hasEqualSpacing : Bool = false {
    didSet {
      gravityViewsArray.map({ $0.hasEqualSpacing = self.hasEqualSpacing })

      setNeedsUpdateConstraints()
    }
  }

  var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet {
      if (oldValue == alignment) { return }

      gravityViewsArray.map({ $0.alignment = self.alignment })
    }
  }

  var orientation : YLUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      if (oldValue == orientation) { return }

      gravityViewsArray.map({ $0.orientation = self.orientation })

      setNeedsUpdateConstraints()
    }
  }

  func compressionResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 1000//UILayoutPriorityDefaultHigh
  }

  func huggingPriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 250//UILayoutPriorityDefaultLow
  }

  override func updateConstraints() {
    removeConstraints(constraints())

    let axis = orientation.toAxis()

    let head = orientation == .Horizontal ? gravityViews.leading : gravityViews.top
    let headCenterSpacer = gravityAreaSpacerViews.headCenter
    let headTailSpacer = gravityAreaSpacerViews.headTail
    let center = gravityViews.center
    let centerTailSpacer = gravityAreaSpacerViews.centerTail
    let tail = orientation == .Horizontal ? gravityViews.trailing : gravityViews.bottom

    let metrics = [ "hP": huggingPriorityForAxis(axis), "spacing" : spacing ]
    let views = [
      "head": head,
      "headCenterSpacer": headCenterSpacer,
      "headTailSpacer": headTailSpacer,
      "center": center,
      "centerTailSpacer": centerTailSpacer,
      "tail": tail
    ]

    let char = orientation.toCharacter()
    let otherChar = orientation.other().toCharacter()

    var vfls : [String] = []

    if (!head.hidden && !center.hidden && !tail.hidden) {       // 111
      vfls += [ "\(char):|[head][headCenterSpacer][center][centerTailSpacer][tail]|" ]
    } else if (!head.hidden && !center.hidden && tail.hidden) { // 110
      vfls += [ "\(char):|[head][headCenterSpacer][center]|" ]
    } else if (!head.hidden && center.hidden && !tail.hidden) { // 101
      vfls += [ "\(char):|[head][headTailSpacer][tail]|" ]
    } else if (!head.hidden && center.hidden && tail.hidden) {  // 100
      vfls += [ "\(char):|[head]|" ]
    } else if (head.hidden && !center.hidden && !tail.hidden) { // 011
      vfls += [ "\(char):|[center][centerTailSpacer][tail]|" ]
    } else if (head.hidden && !center.hidden && tail.hidden) {  // 010
      vfls += [ "\(char):|[center]|" ]
    } else if (head.hidden && center.hidden && !tail.hidden) {  // 001
      vfls += [ "\(char):|[tail]|" ]
    } else if (!head.hidden && !center.hidden && tail.hidden) { // 000
      // TODO
    }

    // constraints for axis
    if (hasEqualSpacing) {
      // TODO
    } else {
      vfls += [ "\(char):[headCenterSpacer(spacing@hP)]", "\(char):[centerTailSpacer(spacing@hP)]" ]
    }

    let centeringAttribute : NSLayoutAttribute = orientation == .Horizontal ? .CenterX : .CenterY
    addConstraint(NSLayoutConstraint(
      item: center, attribute: centeringAttribute,
      relatedBy: .Equal,
      toItem: self, attribute: centeringAttribute,
      multiplier: 1, constant: 0))

    // constraints for other axis
    vfls += [ "\(otherChar):|[head]|", "\(otherChar):|[center]|", "\(otherChar):|[tail]|"]

    addConstraints(NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: metrics, views: views))

    super.updateConstraints()
  }
}