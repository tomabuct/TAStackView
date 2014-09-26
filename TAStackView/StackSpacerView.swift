//
//  StackSpacerView.swift
//  TAStackView
//
//  Created by Tom Abraham on 9/25/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class StackSpacerView : UIView {
  override convenience init() {
    self.init(frame: CGRectNull)
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    setTranslatesAutoresizingMaskIntoConstraints(false)
  }
  
  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoder not supported")
  }
  
  var orientation : YLUserInterfaceLayoutOrientation = .Horizontal {
    didSet { setNeedsUpdateConstraints() }
  };

  var spacing : Float = 8.0 {
    didSet { setNeedsUpdateConstraints() }
  }
  
  var spacingPriority : UILayoutPriority = 250 { //UILayoutPriorityDefaultLow {
    didSet { setNeedsUpdateConstraints() }
  }
  
  override func updateConstraints() {
    removeConstraints(constraints())
    
    let char = orientation.toCharacter()
    let vfls = [ "\(char):[self(spacing@sP)]", "\(char):[self(>=spacing)]" ];
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormats(vfls,
      options: NSLayoutFormatOptions(0),
      metrics: [ "spacing":  spacing, "sP": spacingPriority ],
      views: [ "self": self ]))
    
    super.updateConstraints()
  }
}