//
//  StackGravityAreaView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackGravityAreaView : UIView {
  private(set) var views : [UIView] = []

  private(set) var spacers : [UIView] = []

  var hasEqualSpacing : Bool = false {
    didSet { setNeedsUpdateConstraints() }
  }

  var spacing : Float = DefaultSpacing {
    didSet { setNeedsUpdateConstraints() }
  }

  var alignment : NSLayoutAttribute = .CenterY {
    didSet { setNeedsUpdateConstraints() }
  }

  var orientation : YLUserInterfaceLayoutOrientation = .Horizontal {
    didSet { setNeedsUpdateConstraints() }
  }

  func setVisibilityPriority(visibilityPriority : StackViewVisibilityPriority, forView view : UIView) {
    assert(visibilityPriority == 1000 || visibilityPriority == 0, "only support binary visibility priority for now")

    view.visibilityPriorityInStackView = visibilityPriority

    setNeedsUpdateConstraints()
  }

  func visibilityPriorityForView(view : UIView) -> StackViewVisibilityPriority {
    return view.visibilityPriorityInStackView
  }

  func addView(var view : UIView) {
    views += [ view ];
    view.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(view);

    let spacer = UIView(frame: CGRectZero)
    spacer.setTranslatesAutoresizingMaskIntoConstraints(false)
    addSubview(spacer)
    spacers += [ spacer ]

    setVisibilityPriority(1000, forView: view)

    setNeedsUpdateConstraints()
  }

  func compressionResistancePriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 1000//UILayoutPriorityDefaultHigh
  }

  func huggingPriorityForAxis(axis : UILayoutConstraintAxis) -> UILayoutPriority {
    return 250//UILayoutPriorityDefaultLow
  }

  func _viewsInPlay() -> [UIView] {
    return views.filter({ $0.visibilityPriorityInStackView == 1000 })
  }

  override func updateConstraints() {
    hidden = views.isEmpty

    func _mainConstraints() -> [NSLayoutConstraint] {
      let views = _viewsInPlay()

      let axis = orientation.toAxis()
      let otherAxis = orientation.other().toAxis();

      let metrics = [
        "CRp": compressionResistancePriorityForAxis(axis),
        "CRp_other": compressionResistancePriorityForAxis(otherAxis),
        "Hp": huggingPriorityForAxis(axis),
        "Hp_other": huggingPriorityForAxis(otherAxis)
      ]

      let char = orientation.toCharacter()
      let otherChar = orientation.other().toCharacter()

      var cs : [NSLayoutConstraint] = []
      for (i, view) in enumerate(views) {
        var map = [ "view" : view, "spacer" : spacers[i] ]
        var vfls : [String] = []

        // VFL for axis
        if (i == 0) {
          vfls += [ "\(char):|[view]" ];
        } else {
          map["previousView"] = views[i - 1];
          vfls += [ hasEqualSpacing ? "\(char):[previousView][spacer][view]" : "\(char):[previousView][view]" ];
        }

        if (i == views.count - 1) {
          vfls += [ "\(char):[view]-(>=0@CRp)-|", "\(char):[view]-(<=0@Hp)-|" ]
        }

        // VFL for otherAxis
        vfls += [ "\(otherChar):|-(>=0)-[view]", "\(otherChar):[view]-(>=0@CRp_other)-|", "\(otherChar):[view]-(<=0@Hp_other)-|" ]

        cs += NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: metrics, views: map)
      }
      return cs
    }

    func _alignmentConstraints() -> [NSLayoutConstraint] {
      let views = _viewsInPlay()

      var cs : [NSLayoutConstraint] = []

      if (views.count > 0) {
        for i in 1 ..< views.count {
          let view = views[i]
          let previousView = views[i - 1]

          cs += [ NSLayoutConstraint(
            item: view, attribute: alignment,
            relatedBy: .Equal,
            toItem: previousView, attribute: alignment,
            multiplier: 1.0, constant: 0.0
            ) ]
        }

        if (views.count > 0) {
          cs += [ NSLayoutConstraint(
            item: self, attribute: alignment,
            relatedBy: .Equal,
            toItem: views[0], attribute: alignment,
            multiplier: 1.0, constant: 0.0
            ) ]
        }
      }

      return cs
    }

    func _spacerConstraints() -> [NSLayoutConstraint] {
      var cs : [NSLayoutConstraint] = []

      let attribute : NSLayoutAttribute = (orientation == YLUserInterfaceLayoutOrientation.Horizontal) ? .Width : .Height;

      for (i, view) in enumerate(views) {
        if (i == 0) { continue }

        cs += [ NSLayoutConstraint(item: spacers[0], attribute: attribute,
          relatedBy: .Equal,
          toItem: spacers[i], attribute: attribute,
          multiplier: 1, constant: 0) ]
      }

      return cs
    }

    for spacer in spacers { spacer.hidden = !hasEqualSpacing }
    for view in views { view.hidden = view.visibilityPriorityInStackView != 1000 }

    self.removeConstraints(constraints())
    self.addConstraints(_mainConstraints())
    self.addConstraints(_alignmentConstraints())
    if (hasEqualSpacing) { self.addConstraints(_spacerConstraints()) }
    
    super.updateConstraints()
  }
}