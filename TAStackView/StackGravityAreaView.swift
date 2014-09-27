//
//  StackGravityAreaView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackGravityAreaView : UIView {
  required init(coder aDecoder: NSCoder) {
    fatalError("doesn't support NSCoder")
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    layer.borderColor = UIColor.redColor().CGColor
    layer.borderWidth = 0.5

    // always used in manual Auto Layout context
    setTranslatesAutoresizingMaskIntoConstraints(false)
  }
  
  override convenience init() {
    self.init(frame: CGRectNull)
  }
  
// MARK: General
  private var allViews : [UIView] = []
  
  func addView(var view : UIView) {
    allViews += [ view ];
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(view);
    
    let spacer = StackSpacerView(frame: CGRectZero)
    spacer.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(spacer)
    spacers += [ spacer ]
    
    setNeedsUpdateConstraints()
  }
  
  // TODO: add support for non-binary visibility priorities
  var viewsInPlay : [UIView] { return allViews.filter({ self.visibilityPriorityForView($0) == .MustHold }) }
  
  var alignment : NSLayoutAttribute = DefaultAlignment {
    didSet { setNeedsUpdateConstraints() }
  }
  
  var orientation : TAUserInterfaceLayoutOrientation = DefaultOrientation {
    didSet {
      spacers.map({$0.orientation = self.orientation})
      
      setNeedsUpdateConstraints()
    }
  }
  
  var shouldShow : Bool { return !viewsInPlay.isEmpty }
  
// MARK: Spacing
  private var _customSpacingAfterView = Dictionary<UnsafePointer<Void>, Float>()

  private(set) var spacers : [StackSpacerView] = []
  
  var spacingAfter : Float { assert(!viewsInPlay.isEmpty); return spacingAfterView(viewsInPlay.last!) }
  
  func setCustomSpacing(spacing: Float?, afterView view: UIView) {
    _customSpacingAfterView[unsafeAddressOf(view)] = spacing
    
    setNeedsUpdateConstraints()
  }
  
  func customSpacingAfterView(view : UIView) -> Float? {
    return _customSpacingAfterView[unsafeAddressOf(view)]
  }
  
  private func spacingAfterView(view : UIView) -> Float {
    return customSpacingAfterView(view) ?? spacing
  }

  var spacing : Float = DefaultSpacing {
    didSet { setNeedsUpdateConstraints() }
  }
  
  var hasEqualSpacing : Bool = false {
    didSet { setNeedsUpdateConstraints() }
  }

// MARK: Priorities
  private var _visibilityPriorityForView = Dictionary<UnsafePointer<Void>, StackViewVisibilityPriority>()
  
  private var horizontalClippingResistancePriority = DefaultClippingResistancePriority
  private var verticalClippingResistancePriority = DefaultClippingResistancePriority
  private var horizontalHuggingPriority = DefaultHuggingPriority
  private var verticalHuggingPriority = DefaultHuggingPriority
  
  func clippingResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return axis == .Horizontal ? horizontalClippingResistancePriority : verticalClippingResistancePriority
  }
  
  func setClippingResistancePriority(priority : UILayoutPriority, forAxis axis : UILayoutConstraintAxis) {
    if (axis == .Horizontal) {
      horizontalClippingResistancePriority = priority
    } else {
      verticalClippingResistancePriority = priority
    }
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
    assert(visibilityPriority == .MustHold || visibilityPriority == .NotVisible, "only support binary visibility priority for now")
    
    _visibilityPriorityForView[unsafeAddressOf(view)] = visibilityPriority
    
    setNeedsUpdateConstraints()
  }
  
  func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return _visibilityPriorityForView[unsafeAddressOf(view)] ?? .MustHold
  }

// MARK: Layout

  override func updateConstraints() {
    hidden = viewsInPlay.isEmpty

    func _mainConstraints() -> [NSLayoutConstraint] {
      let otherAxis = orientation.other().toAxis();
      let metrics = [ "Hp_other": huggingPriorityForAxis(otherAxis) ]

      let char = orientation.toCharacter()
      let otherChar = orientation.other().toCharacter()

      var cs : [NSLayoutConstraint] = []
      for (i, view) in enumerate(viewsInPlay) {
        var map = [ "view" : view, "spacer" : spacers[i] ]
        var vfls : [String] = []

        // VFL for axis:
        // e.g. if the stack view was horizontally oriented in LTR (left-to-right) configuration,
        //  1) stack views horizontally, one after the other
        //  2) place spacer between every pair of views
        //  3) pin first view to left, last view to right
        if (i == 0) {
          vfls += [ "\(char):|[view]" ];
        }

        if (i == viewsInPlay.count - 1) {
          vfls += [ "\(char):[view]|" ]
        } else {
          map["nextView"] = viewsInPlay[i + 1];
          vfls += [ "\(char):[view][spacer][nextView]" ];
        }

        // VFL for otherAxis:
        // e.g. if the stack view was horizontally oriented,
        //  1) make sure all views fit vertically
        //  2) make sure stack view hugs each view vertically with the vertical hugging priority
        vfls += [ "\(otherChar):|-(>=0,0@Hp_other)-[view]", "\(otherChar):[view]-(>=0,0@Hp_other)-|" ]

        cs += NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: metrics, views: map)
      }
      return cs
    }

    func _alignmentConstraints() -> [NSLayoutConstraint] {
      return viewsInPlay.map({ (view : UIView) -> NSLayoutConstraint in
        NSLayoutConstraint(
          item: self, attribute: self.alignment,
          relatedBy: .Equal,
          toItem: view, attribute: self.alignment,
          multiplier: 1.0, constant: 0.0
        )
      })
    }
    
    func _updateInterViewSpacing() {
      if (allViews.count == 0) { return }
      
      for i in 0 ..< allViews.count - 1 {
        let view = allViews[i]
        let spacer = spacers[i]
        
        let hP = huggingPriorityForAxis(orientation.toAxis())
        
        spacer.spacing = spacingAfterView(view)
        spacer.spacingPriority = hasEqualSpacing ? hP : max(LayoutPriorityDefaultHigh, hP)
        spacer.orientation = orientation
      }
    }
    
    func _updateViewVisibility() {
      allViews.map({ $0.hidden = self.visibilityPriorityForView($0) != .MustHold })
    }

    self.removeConstraints(constraints())
    self.addConstraints(_mainConstraints())
    self.addConstraints(_alignmentConstraints())
    
    _updateInterViewSpacing()
    _updateViewVisibility()
    
    super.updateConstraints()
  }
}