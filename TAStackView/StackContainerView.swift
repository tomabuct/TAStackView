//
//  StackContainerView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackContainerView : UIView, StackGravityAreaViewDelegate {
  private var _customSpacingAfterView = Dictionary<UnsafePointer<Void>, Float>()
  private var _gravityAreaForView = Dictionary<UnsafePointer<Void>, StackViewGravityArea>()

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoder not supported")
  }

  override init() {
    super.init(frame: CGRectZero)

    for gravityAreaView in gravityAreaViewsArray {
      addSubview(gravityAreaView)
      gravityAreaView.delegate = self
    }
    for spacerView in gravityAreaSpacerViewsArray { addSubview(spacerView) }

    _installConstraints()
  }

  func _installConstraints() {
    for gravityAreaView in gravityAreaViewsArray { gravityAreaView.setTranslatesAutoresizingMaskIntoConstraints(false) }
  }

  let gravityAreaViews = (
    top: StackGravityAreaView(),
    leading: StackGravityAreaView(),
    center: StackGravityAreaView(),
    trailing: StackGravityAreaView(),
    bottom: StackGravityAreaView()
  )

  let gravityAreaSpacerViews = (
    headCenter: StackSpacerView(),
    headTail: StackSpacerView(),
    centerTail: StackSpacerView()
  )

  private var gravityAreaViewsArray : [StackGravityAreaView] {
    return [ gravityAreaViews.top, gravityAreaViews.leading, gravityAreaViews.center, gravityAreaViews.trailing, gravityAreaViews.bottom ]
  }

  private var gravityAreaSpacerViewsArray : [StackSpacerView] {
    return [ gravityAreaSpacerViews.headCenter, gravityAreaSpacerViews.headTail, gravityAreaSpacerViews.centerTail ]
  }
  
  func stackGravityAreaView(gravityAreaView: StackGravityAreaView, spacingAfterView view: UIView) -> Float {
    return spacingAfterView(view)
  }

  var spacing : Float = DefaultSpacing {
    didSet {
      gravityAreaViewsArray.map({ $0.spacing = self.spacing })

      setNeedsUpdateConstraints()
    }
  }

  var hasEqualSpacing : Bool = false {
    didSet {
      gravityAreaViewsArray.map({ $0.hasEqualSpacing = self.hasEqualSpacing })

      setNeedsUpdateConstraints()
    }
  }

  var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet {
      if (oldValue == alignment) { return }

      gravityAreaViewsArray.map({ $0.alignment = self.alignment })
    }
  }

  var orientation : YLUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      if (oldValue == orientation) { return }

      gravityAreaViewsArray.map({ $0.orientation = self.orientation })
      gravityAreaSpacerViewsArray.map({ $0.orientation = self.orientation })

      setNeedsUpdateConstraints()
    }
  }

  func compressionResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 1000//UILayoutPriorityDefaultHigh
  }

  func huggingPriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 250//UILayoutPriorityDefaultLow
  }
  
  func setVisibilityPriority(visibilityPriority : StackViewVisibilityPriority, forView view : UIView) {
    gravityAreaViewForGravity(gravityAreaContainingView(view)).setVisibilityPriority(visibilityPriority, forView: view)
  }
  
  func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return gravityAreaViewForGravity(gravityAreaContainingView(view)).visibilityPriorityForView(view)
  }
  
  func setCustomSpacing(spacing: Float?, afterView view: UIView) {
    _customSpacingAfterView[unsafeAddressOf(view)] = spacing
    
    setNeedsUpdateConstraints()
  }
  
  func gravityAreaContainingView(view : UIView) -> StackViewGravityArea {
    return _gravityAreaForView[unsafeAddressOf(view)]!;
  }
  
  func customSpacingAfterView(view : UIView) -> Float? {
    return _customSpacingAfterView[unsafeAddressOf(view)]
  }
  
  func spacingAfterView(view : UIView) -> Float {
    return customSpacingAfterView(view) ?? spacing
  }
  
  func addView(var view : UIView, inGravity gravity : StackViewGravityArea) {
    _gravityAreaForView[unsafeAddressOf(view)] = gravity
    gravityAreaViewForGravity(gravity).addView(view)
    
    setNeedsUpdateConstraints()
  }

  override func updateConstraints() {
    let axis = orientation.toAxis()

    let head = orientation == .Horizontal ? gravityAreaViews.leading : gravityAreaViews.top
    let center = gravityAreaViews.center
    let tail = orientation == .Horizontal ? gravityAreaViews.trailing : gravityAreaViews.bottom
        
    let headCenterSpacer = gravityAreaSpacerViews.headCenter
    let headTailSpacer = gravityAreaSpacerViews.headTail
    let centerTailSpacer = gravityAreaSpacerViews.centerTail

    let views = [
      "head": head,
      "headCenterSpacer": headCenterSpacer,
      "headTailSpacer": headTailSpacer,
      "center": center,
      "centerTailSpacer": centerTailSpacer,
      "tail": tail
    ]

    let char = orientation.toCharacter()

    func _mainConstraintsForAxis() -> [NSLayoutConstraint] {
      var vfls : [String] = []
      
      if (!head.isEmpty && !center.isEmpty && !tail.isEmpty) {       // 111
        vfls += [ "\(char):|[head][headCenterSpacer][center][centerTailSpacer][tail]|" ]
      } else if (!head.isEmpty && !center.isEmpty && tail.isEmpty) { // 110
        vfls += [ "\(char):|[head][headCenterSpacer][center]|" ]
      } else if (!head.isEmpty && center.isEmpty && !tail.isEmpty) { // 101
        vfls += [ "\(char):|[head][headTailSpacer][tail]|" ]
      } else if (!head.isEmpty && center.isEmpty && tail.isEmpty) {  // 100
        vfls += [ "\(char):|[head]|" ]
      } else if (head.isEmpty && !center.isEmpty && !tail.isEmpty) { // 011
        vfls += [ "\(char):|[center][centerTailSpacer][tail]|" ]
      } else if (head.isEmpty && !center.isEmpty && tail.isEmpty) {  // 010
        vfls += [ "\(char):|[center]|" ]
      } else if (head.isEmpty && center.isEmpty && !tail.isEmpty) {  // 001
        vfls += [ "\(char):|[tail]|" ]
      } else if (!head.isEmpty && !center.isEmpty && !tail.isEmpty) { // 000
        // TODO
      }
      
      return NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: [:], views: views)
    }
    
    func _centerGravityAreaCenteringConstraint() -> NSLayoutConstraint {
      let centeringAttribute : NSLayoutAttribute = orientation == .Horizontal ? .CenterX : .CenterY
      
      let centeringConstraint = NSLayoutConstraint(
        item: center, attribute: centeringAttribute,
        relatedBy: .Equal,
        toItem: self, attribute: centeringAttribute,
        multiplier: 1, constant: 0)
      
      centeringConstraint.priority = 250//UILayoutPriorityDefaultLow

      return centeringConstraint;
    }
    
    func _constraintsForOtherAxis() -> [NSLayoutConstraint] {
      let otherChar = orientation.other().toCharacter()
      let vfls = [ "\(otherChar):|[head]|", "\(otherChar):|[center]|", "\(otherChar):|[tail]|"]
      return NSLayoutConstraint.constraintsWithVisualFormats(vfls,
        options: NSLayoutFormatOptions(0), metrics: [:], views: views)
    }
    
    func _updateInterGravityAreaSpacingConstraints() {
      if (!head.isEmpty && !center.isEmpty) {
        headTailSpacer.spacing = spacingAfterView(head.views.last!)
      }
      
      if (!center.isEmpty && !tail.isEmpty) {
        centerTailSpacer.spacing = spacingAfterView(center.views.last!)
      }
      
      if (!head.isEmpty && center.isEmpty && !tail.isEmpty) {
        headTailSpacer.spacing = spacingAfterView(head.views.last!)
      }
      
      let hP = huggingPriorityForAxis(axis)
      gravityAreaSpacerViewsArray.map({ $0.spacingPriority = hP })
    }

    removeConstraints(constraints())
    addConstraints(_mainConstraintsForAxis())
    addConstraint(_centerGravityAreaCenteringConstraint())
    addConstraints(_constraintsForOtherAxis())
    _updateInterGravityAreaSpacingConstraints()

    super.updateConstraints()
  }
  
  private func gravityAreaViewForGravity(gravity : StackViewGravityArea) -> StackGravityAreaView {
    switch (gravity) {
    case .Top:
      return gravityAreaViews.top
    case .Leading:
      return gravityAreaViews.leading
    case .Center:
      return gravityAreaViews.center
    case .Trailing:
      return gravityAreaViews.trailing
    case .Bottom:
      return gravityAreaViews.bottom
    }
  }
}