# SJRefresh

[![CI Status](http://img.shields.io/travis/Subins Jose/SJRefresh.svg?style=flat)](https://travis-ci.org/Subins Jose/SJRefresh)
[![Version](https://img.shields.io/cocoapods/v/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)
[![License](https://img.shields.io/cocoapods/l/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)
[![Platform](https://img.shields.io/cocoapods/p/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)

SJRefresh is a light weight generic pull to refresh written in Swift 3.

![sample_gif](https://github.com/subinspathilettu/SJRefresh/blob/master/Example/pulltorefresh.gif)

#### Highlights

* Supports custom animation.
* Supports gif.

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### Using CocoaPods:

SJRefresh is available through [CocoaPods](http://cocoapods.org). To integrate SJRefresh into your Xcode project using CocoaPods, specify it in your Podfile:
```swift

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod ’SJRefresh’, ‘1.0.0'
end
```

Then, run the following command:
```swift
$ pod install
```
### Manually:

* Download SJRefresh.
* Drag and drop SJRefresh directory to your project

## Requirements

iOS 9.0+, Swift 3+

## Usage

Here is how you can use SJRefresh. 

* Definite Refresh Animation
```
let options = RefreshViewOptions()
options.gifImage = "Loader"
options.definite = true

tableView.addRefreshView(options: options) { _ in

	//Your code here
	self.tableView.setRefreshPrecentage(60)
	...
	self.tableView.setRefreshPrecentage(100)
}
```

* InDefinite Refresh Animation
```
let options = RefreshViewOptions()
options.gifImage = "Loader"

tableView.addRefreshView(options: options) { _ in

	//Your code here
	self.tableView.stopPullRefresh()
}
```

## Author

Subins Jose, subinsjose@gmail.com

## License

SJRefresh is available under the MIT license. See the LICENSE file for more info.
