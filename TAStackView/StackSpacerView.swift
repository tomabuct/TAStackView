//
//  StackSpacerView.swift
//  TAStackView
//
//  Created by Tom Abraham on 9/25/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackSpacerView : UIView {
  let huggingConstraint : NSLayoutConstraint!
  let spacingConstraint : NSLayoutConstraint!
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoder not supported")
  }
  
  override convenience init() {
    self.init(frame: CGRectNull)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    // always invisible
    hidden = true
    
    // always used in manual Auto Layout context
    setTranslatesAutoresizingMaskIntoConstraints(false)
  }
  
// MARK: Configuration
  
  var orientation : TAUserInterfaceLayoutOrientation = .Horizontal {
    didSet { setNeedsUpdateConstraints() }
  };

  var spacing : Float = DefaultSpacing {
    didSet { setNeedsUpdateConstraints() }
  }
  
  var spacingPriority : UILayoutPriority = DefaultSpacingPriority {
    didSet { setNeedsUpdateConstraints() }
  }
  
// MARK: Layout
  
  override func updateConstraints() {
    removeConstraints(constraints())
    
    let char = orientation.toCharacter()
    let metrics = [ "spacing":  spacing, "sP": spacingPriority ]._bridgeToObjectiveC()
    let views = [ "self": self ]._bridgeToObjectiveC()
    
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("\(char):[self(>=spacing)]",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("\(char):[self(spacing@sP)]",
      options: NSLayoutFormatOptions(0), metrics: metrics, views: views))
    
    super.updateConstraints()
  }
}