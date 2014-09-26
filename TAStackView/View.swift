//
//  View.swift
//  TAStackView
//
//  Created by Tom Abraham on 7/13/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

private let kDuration = 0.2

class View: UIView {
  let stackView = StackView();
  
  var doubleTapCount = 0

  required init(coder aDecoder: NSCoder) {
    fatalError("NSCoding not supported")
  }

  override init(frame: CGRect) {
    super.init(frame: frame)

    self.backgroundColor = UIColor.brownColor()

    stackView.backgroundColor = UIColor.purpleColor()
    stackView.layer.borderColor = UIColor.orangeColor().CGColor
    stackView.layer.borderWidth = 1.0
    for i in 0..<3 { stackView.addView(crazyRandomView(), inGravity: .Leading) }
    for i in 0..<3 { stackView.addView(crazyRandomView(), inGravity: .Center) }
//    for i in 0..<3 { stackView.addView(crazyRandomView(), inGravity: .Trailing) }

//    stackView.frame = bounds
    stackView.autoresizingMask = UIViewAutoresizing.FlexibleRightMargin | .FlexibleBottomMargin
    stackView.setTranslatesAutoresizingMaskIntoConstraints(true)
    addSubview(stackView);

    _installConstraints()
  }

  func toggleEdgeInsets() {
    layoutIfNeeded()

    stackView.edgeInsets = UIEdgeInsetsEqualToEdgeInsets(stackView.edgeInsets, UIEdgeInsetsZero) ? UIEdgeInsetsMake(20, 10, 20, 10) : UIEdgeInsetsZero

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  func toggleHasEqualSpacing() {
    layoutIfNeeded()

    stackView.hasEqualSpacing = !stackView.hasEqualSpacing

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  func cycleAlignments() {
    layoutIfNeeded();

    var alignment = NSLayoutAttribute.Top

    switch stackView.alignment {
    case .Top: alignment = .CenterY
    case .CenterY: alignment = .Bottom
    case .Bottom: alignment = .Top
    case .Left: alignment = .CenterX
    case .CenterX: alignment = .Right
    case .Right: alignment = .Left
    default: alignment = stackView.orientation == YLUserInterfaceLayoutOrientation.Vertical ? .CenterY : .CenterX
    }

    stackView.alignment = alignment

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  func switchOrientation() {
    layoutIfNeeded();

    var orientation = YLUserInterfaceLayoutOrientation.Horizontal

    switch stackView.orientation {
    case .Horizontal: orientation = .Vertical
    case .Vertical: orientation = .Horizontal
    }

    stackView.orientation = orientation

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  func _installConstraints() {
    let views = [ "stackView": stackView ]

    stackView.setTranslatesAutoresizingMaskIntoConstraints(false)
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-(10)-[stackView]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-(20)-[stackView]", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
  }

  func _tappedView(tapGR : UITapGestureRecognizer) {
    layoutIfNeeded();

    let view = tapGR.view
    self.stackView.setVisibilityPriority(0, forView: view!)

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  func _doubleTappedView(tapGR : UITapGestureRecognizer) {
    layoutIfNeeded()

    stackView.addView(crazyRandomView(), inGravity: doubleTapCount % 3 == 0 ? .Leading : (doubleTapCount % 3 == 1 ? .Center : .Trailing))
    
    doubleTapCount++

    UIView.animateWithDuration(kDuration, animations: { self.layoutIfNeeded() })
  }

  private func crazyRandomView() -> UIView {
    let randomHeight = CGFloat(Int(arc4random() % 90)) + 10;
    let randomWidth = CGFloat(Int(arc4random() % 90)) + 10;
    func randomComponent() -> CGFloat { return CGFloat(Float(arc4random()) / 0x100000000) }

    let view = UIView();
    view.backgroundColor = UIColor(red: randomComponent(), green: randomComponent(), blue: randomComponent(), alpha: 1.0)

    let doubleTapGR = UITapGestureRecognizer(target: self, action: "_doubleTappedView:");
    doubleTapGR.numberOfTapsRequired = 2

    let tapGR = UITapGestureRecognizer(target: self, action: "_tappedView:");
    tapGR.requireGestureRecognizerToFail(doubleTapGR)

    let label = UILabel()
    label.setTranslatesAutoresizingMaskIntoConstraints(false)
    label.text = "Lorem ipsum dolor sit amet, consectetur adipisicing elit"
    label.numberOfLines = 0
    view.addSubview(label)

    view.addGestureRecognizer(tapGR)
    view.addGestureRecognizer(doubleTapGR)

    let views : [String : UIView] = [ "label" : label ]
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[label]|", options: NSLayoutFormatOptions(0), metrics: nil, views: views))

    view.addConstraint(NSLayoutConstraint(item: view, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: randomWidth))
    view.addConstraint(NSLayoutConstraint(item: view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: randomHeight))
    return view;
  }
}
