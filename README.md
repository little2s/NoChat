<img src="https://github.com/little2s/NoChat/raw/master/Examples/NoChat-Example/NoChat-Example/Assets.xcassets/AppIcon.appiconset/Icon-60%402x.png" width="100" height="100" />

[![Languages](https://img.shields.io/badge/languages-ObjC%20%7C%20Swift-orange.svg)](https://github.com/little2s/NoChat)

# NoChat
NoChat is a lightweight chat UI framework which has no particular faces. 
The projects in [Examples](https://github.com/little2s/NoChat/tree/master/Examples) directory 
show you how to use this framework to implement a text game with user interface like 
Telegram or WeChat very easily. You can custom your own with NoChat :].       

<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Screenshots/screenshot-0x00.png" width="250" height="444" />
&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Screenshots/screenshot-0x01.png" width="250" height="444" />

## Features
- Inverted mode
- Adaptive user interface
- Custom chat items and input panel
- Simple MVC pattern
- Supports both Objective-C and Swift

## Requirements
- iOS 8.0+
- Xcode 8.2.1 or above

## Install
NoChat supports multiple methods for install.

### CocoaPods
Include the following in your `Podfile`:    
``` ruby
target 'TargetName' do
    pod 'NoChat', '~> 0.3'
end
```

### Carthage
Include the following in your `Cartfile`: 
```
github "little2s/NoChat" ~> 0.3
```

### Manually
Download and drop `/NoChat/NoChat` folder in your project.  

## Architecture

### Model
- `<NOCChatItem>`

### Views
- `NOCChatContainerView`
- `NOCChatInputPanel`
- `NOCChatCollectionView`
- `NOCChatCollectionViewLayout`
- `NOCChatItemCell`
- `<NOCChatItemCellLayout>`

### ViewController
- `NOCChatViewController`

## Usage

### Objective-C

Import the framework.
``` objective-c
#import <NoChat/NoChat.h>
```

You can create a subclass of `NOCChatViewController`, and provide the data.
``` objective-c
@interface TGChatViewController : NOCChatViewController
    // ...
@end

@implementation TGChatViewController

    // Overrides these three methods below to provide basic classes.
    + (Class)cellLayoutClassForItemType:(NSString *)type
    {
        // ...
    }

    + (Class)inputPanelClass
    {
        // ...
    }

    - (void)registerChatItemCells
    {
        // ...
    }
        
}
```

Implement your business in this subclass. You may update `layouts` property through
these there methods provide by super class:
- `insertLayouts:atIndexes:animated:`
- `deleteLayoutsAtIndexes:animated:`
- `updateLayoutAtIndex:toLayout:animated:`

And I also suggest you custom the view controller of chat with the protocols provide by NoChat.
I mean you can write your own `ChatViewController` without `NOCChatViewController`.
Source code is mind, not just code, I think.

### Swift

Import the framework.
``` swift
import NoChat
```
You can create a subclass of `NOCChatViewController`, and provide the data.
``` swift
class TGChatViewController: NOCChatViewController {

    // Overrides these three methods below to provide basic classes.
    override class func cellLayoutClass(forItemType type: String) -> Swift.AnyClass? {
        // ...
    }
    
    override class func inputPanelClass() -> Swift.AnyClass? {
        // ...
    }
    
    override func registerChatItemCells() {
        // ...
    }
    
}
```
Implement your business in this subclass. The same way as description in Objective-C section above.

## More
See the [Examples](https://github.com/little2s/NoChat/tree/master/Examples) projects inside.

## About
- This framework is inspired by [Chatto](https://github.com/badoo/Chatto) and [Telegram](https://github.com/peter-iakovlev/Telegram). Thanks.
- All reources in example projects are extracted from real app [Telegram](https://itunes.apple.com/us/app/telegram-messenger/id686449807?mt=8) and [WeChat](https://itunes.apple.com/us/app/wechat/id414478124?mt=8). Do not use these resources in your project for business directly.  
- The example use [YYLabel](https://github.com/ibireme/YYText/blob/master/YYText/YYLabel.h) instead of `UILabel` and [HPGrowingTextView](https://github.com/HansPinckaers/GrowingTextView) for writing text input panel. Thanks to these great contributers. And these dependencies are not essential for `NoChat` framework. `NoChat` is just a view layer framework which mainly provide a container just like `UITableViewController`.
- Text game is migration from [Here](https://learnpythonthehardway.org/book/ex43.html).
- If you prefer the pure swift version before 0.3, here is a great fork by [@mbalex99](https://github.com/mbalex99) with swift 3 support: https://github.com/mbalex99/NoChat, thanks for their great work.

## License
Source code is distributed under MIT license.
