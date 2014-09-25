//
//  ViewController.swift
//  TAStackView
//
//  Created by Tom Abraham on 7/12/14.
//  Copyright (c) 2014 Tom Abraham. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  let theView = View(frame: CGRectZero)

  override func loadView() {
    self.view = theView
  }
                            
  override func viewDidLoad() {
    super.viewDidLoad()

    let quadrupleTapGR = UITapGestureRecognizer(target: self, action: "quadrupleTapped:")
    quadrupleTapGR.numberOfTapsRequired = 4
    theView.addGestureRecognizer(quadrupleTapGR)

    let tripleTapGR = UITapGestureRecognizer(target: self, action: "tripleTapped:")
    tripleTapGR.numberOfTapsRequired = 3
    tripleTapGR.requireGestureRecognizerToFail(quadrupleTapGR)
    theView.addGestureRecognizer(tripleTapGR)

    let doubleTapGR = UITapGestureRecognizer(target: self, action: "doubleTapped:")
    doubleTapGR.numberOfTapsRequired = 2
    doubleTapGR.requireGestureRecognizerToFail(tripleTapGR)
    theView.addGestureRecognizer(doubleTapGR)

    let tapGR = UITapGestureRecognizer(target: self, action: "tapped:")
    tapGR.requireGestureRecognizerToFail(doubleTapGR)
    theView.addGestureRecognizer(tapGR)
  }

  func tapped(tapGR : UITapGestureRecognizer!) {
    theView.cycleAlignments()
  }

  func doubleTapped(doubleTapGR : UITapGestureRecognizer!) {
    theView.switchOrientation()
  }

  func tripleTapped(tripleTapGR : UITapGestureRecognizer!) {
    theView.toggleHasEqualSpacing()
  }

  func quadrupleTapped(tripleTapGR : UITapGestureRecognizer!) {
    theView.toggleEdgeInsets()
  }
}

