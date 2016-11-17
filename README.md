# SJRefresh

[![CI Status](https://img.shields.io/travis/subinspathilettu/SJRefresh.svg?style=flat)](https://travis-ci.org/subinspathilettu/SJRefresh)
[![Version](https://img.shields.io/cocoapods/v/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)
[![License](https://img.shields.io/cocoapods/l/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)
[![Platform](https://img.shields.io/cocoapods/p/SJRefresh.svg?style=flat)](http://cocoapods.org/pods/SJRefresh)

SJRefresh is a light weight generic pull to refresh written in Swift 3.

![sample_gif](https://github.com/subinspathilettu/SJRefresh/blob/master/Example/refresh_sample.gif)

#### Highlights

- [x] Supports multiple themes
- [x] Supports custom animation

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

### CocoaPods

[CocoaPods](http://cocoapods.org) is a dependency manager for Cocoa projects. You can install it with the following command:

```bash
$ gem install cocoapods
```

To integrate SJRefresh into your Xcode project using CocoaPods, specify it in your `Podfile`:
```ruby

source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '9.0'
use_frameworks!

target '<Your Target Name>' do
pod ’SJRefresh’, ‘1.0.0'
end
```

Then, run the following command:

```bash
$ pod install
```

### Manually:

* Download SJRefresh
* Drag and drop SJRefresh directory to your project

## Requirements

- Xcode 8+
- iOS 9.0+
- Swift 3.0+

## Communication

- If you **found a bug**, open an issue.
- If you **have a feature request**, open an issue.
- If you **want to contribute**, submit a pull request.

## Usage

Here is how you can use SJRefresh. 

* Import SJRefresh to your class

```swift
import SJRefresh
```
* Specify your theme in AppDelegate.swift

```swift
SJRefresh.shared.setTheme(SJTheme())
```

* Add refresh view to your control,

For in definite refresh animation, add following code
```swift
tableView.addRefreshView(definite: false,
		                 refreshCompletion: { (_) in

	//Your code here
	self.tableView.stopPullRefresh()
})
```
For definite refresh animation, add following code

```swift
tableView.addRefreshView(definite: true,
		                 refreshCompletion: { (_) in

	//Your code here
	self.tableView.setRefreshPrecentage(60)
	...
	self.tableView.setRefreshPrecentage(100)
})
```
## Customize Refresh View

SJRefresh supports themes. So we can provide custom themes that supports [SJRefreshThemeProtocol](https://code.qburst.com/subinsjose/SJRefreshThemeProtocol/blob/master/SJRefreshThemeProtocol.swift).

```swift
SJRefresh.shared.setTheme(<CUSTOM_THEME>)
```
### Create custom Themes

To create a theme, create a class that confirm [SJRefreshThemeProtocol](https://code.qburst.com/subinsjose/SJRefreshThemeProtocol/blob/master/SJRefreshThemeProtocol.swift) 

```swift
extension <YOUR_CLASS>: SJRefreshThemeProtocol {

	public func heightForRefreshView() -> CGFloat {
	
		return <CGFloat>
	}

	public func pullImageForRefreshView() -> UIImage {
	
		return <UIImage>
	}

	public func imagesForRefreshViewLoadingAnimation() -> [UIImage] {

		return <[UIImage]>
	}

	public func backgroundColorForRefreshView() -> UIColor {

		return <UIColor>
	}

	public func backgroundImageForRefreshView() -> UIImage? {
		
		return <UIImage>
	}
}
```

## Author

Subins Jose, subinsjose@gmail.com

## License

SJRefresh is available under the MIT license. See the LICENSE file for more info.
