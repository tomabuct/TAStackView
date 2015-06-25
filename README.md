TAStackView
===========

### _Deprecated_

_This was written before [`UIStackView`](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/) was introduced in iOS 9. Please use it, or [`OAStackView`](https://github.com/oarrabi/OAStackView) if you need to support iOS 8._

### NSStackView for iOS

`TAStackView` is an almost[1] fully API-compatible [`NSStackView`](https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSStackView_Class/Chapters/Reference.html) port to Cocoa Touch (think: `UIStackView`!) that's written in Swift.

[1] *Currently only supports visibility priorities of `NSStackViewVisibilityPriorityMustHold` (visible) and `NSStackViewVisibilityPriorityNotVisible` (hidden)*. See [the NSStackView documentation](https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSStackView_Class/Chapters/Reference.html#jumpTo_24) for more information.

### Features

*see [`NSStackView`](https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSStackView_Class/Chapters/Reference.html) documentation*

### Requirements

- iOS 7.0+
- Xcode 6.0

### Communication

- If you'd like to **ask a general question**, e-mail me.
- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

### Installation

1. Add TAStackView as a [submodule](http://git-scm.com/docs/git-submodule) by opening the Terminal, `cd`-ing into your top-level project directory, and entering the command `git submodule add https://github.com/tomabuct/TAStackView.git`
2. Open the `TAStackView` folder, and drag `TAStackView.xcodeproj` into the file navigator of your Xcode project.
3. In Xcode, navigate to the target configuration window by clicking on the blue project icon, and selecting the application target under the "Targets" heading in the sidebar.
4. In the tab bar at the top of that window, open the "Build Phases" panel.
5. Expand the "Link Binary with Libraries" group, and add `TAStackView.framework`.

### Usage

*see [`NSStackView`](https://developer.apple.com/library/mac/documentation/AppKit/Reference/NSStackView_Class/Chapters/Reference.html) documentation*


### Creator

[Tom Abraham](http://github.com/tomabuct) ([@tomabuct](https://twitter.com/tomabuct))

### License

TAStackView is released under the MIT license. See LICENSE.md for details.
