//
//  StackViewUtils.swift
//  TAStackView
//
//  Created by Tom Abraham on 8/10/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

typealias StackViewVisibilityPriority = Float

let DefaultSpacing : Float = 8.0
let DefaultAlignment : NSLayoutAttribute = .CenterY
let DefaultOrientation : YLUserInterfaceLayoutOrientation = .Horizontal

var kVisibilityPriorityInStackViewKey = "kVisibilityPriorityInStackViewKey"
var kStackViewGravityKey = "kStackViewGravityKey"

extension UIView {
  var visibilityPriorityInStackView : StackViewVisibilityPriority {
    get {
      return objc_getAssociatedObject(self, &kVisibilityPriorityInStackViewKey) as Float
    }
    set {
      objc_setAssociatedObject(self, &kVisibilityPriorityInStackViewKey, newValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
    }
  }

//  var gravityArea : StackViewGravity {
//    get {
//      return StackViewGravity(rawValue: objc_getAssociatedObject(self, &kStackViewGravityKey) as Int)!
//    }
//
//    set {
//      objc_setAssociatedObject(self, &kStackViewGravityKey, newValue.rawValue, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN_NONATOMIC))
//    }
//  }
}

extension NSLayoutConstraint {
  class func constraintsWithVisualFormats(
    vfls : [String],
    options : NSLayoutFormatOptions,
    metrics : Dictionary<String, Float>,
    views : Dictionary<String, UIView>
  ) -> [NSLayoutConstraint] {
    let views = views._bridgeToObjectiveC()
    let metrics = metrics._bridgeToObjectiveC()

    var cs : [NSLayoutConstraint] = []
    for vfl in vfls {
      cs += constraintsWithVisualFormat(vfl, options: options, metrics: metrics, views: views) as [NSLayoutConstraint]
    }
    return cs
  }
}

enum YLUserInterfaceLayoutOrientation {
  case Horizontal
  case Vertical

  func toCharacter() -> Character {
    return self == .Horizontal ? "H" : "V"
  }

  func other() -> YLUserInterfaceLayoutOrientation {
    return self == .Horizontal ? .Vertical : .Horizontal;
  }

  func toAxis() -> UILayoutConstraintAxis {
    return self == .Horizontal ? .Horizontal : .Vertical;
  }
}

enum StackViewGravityArea: Int {
  case Top
  case Leading
  case Center
  case Bottom
  case Trailing
}

let TAStackViewSpacingUseDefault = FLT_MAX