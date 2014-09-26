//
//  StackGravityAreaView.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

@objc protocol StackGravityAreaViewDelegate {
  func stackGravityAreaView(gravityAreaView: StackGravityAreaView, spacingAfterView: UIView) -> Float;
}

class StackGravityAreaView : UIView {
  private(set) var views : [UIView] = []

  private(set) var spacers : [StackSpacerView] = []
  
  weak var delegate : StackGravityAreaViewDelegate?
  
  var isEmpty : Bool { return views.isEmpty }

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

    let spacer = StackSpacerView(frame: CGRectZero)
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
        }

        if (i == views.count - 1) {
          vfls += [ "\(char):[view]|" ]
        } else {
          map["nextView"] = views[i + 1];
          vfls += [ "\(char):[view][spacer][nextView]" ];
        }

        // VFL for otherAxis
        vfls += [ "\(otherChar):|-(>=0)-[view]", "\(otherChar):[view]-(>=0)-|" ]

        cs += NSLayoutConstraint.constraintsWithVisualFormats(vfls, options: NSLayoutFormatOptions(0), metrics: metrics, views: map)
      }
      return cs
    }

    func _alignmentConstraints() -> [NSLayoutConstraint] {
      let views = _viewsInPlay()

      return views.map({ (view : UIView) -> NSLayoutConstraint in
        NSLayoutConstraint(
          item: self, attribute: self.alignment,
          relatedBy: .Equal,
          toItem: view, attribute: self.alignment,
          multiplier: 1.0, constant: 0.0
        )
      })
    }
    
    func _updateInterViewSpacingConstraints() {
      if (views.count == 0) { return }
      
      for i : Int in 0 ..< views.count - 1 {
        let view = views[i]
        spacers[i].spacing = delegate?.stackGravityAreaView(self, spacingAfterView: view) ?? 8.0
        spacers[i].spacingPriority = max(750, huggingPriorityForAxis(orientation.toAxis()))
        spacers[i].orientation = orientation
      }
    }

    for (i, view) in enumerate(views) {
      let hidden = view.visibilityPriorityInStackView != 1000
      
      view.hidden = hidden
      spacers[i].hidden = hidden
    }

    self.removeConstraints(constraints())
    self.addConstraints(_mainConstraints())
    self.addConstraints(_alignmentConstraints())
    _updateInterViewSpacingConstraints()
    
    super.updateConstraints()
  }
}