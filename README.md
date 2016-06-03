<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Assets/icon.png" width="100" height="100" />

# NoChat
NoChat is a Swift lightweight chat framework base on [Chatto](https://github.com/badoo/Chatto).    
Along with NoChat, there are three companion frameworks: NoChatTG, NoChatMM, NoChatSLK.    
These companion frameworks are just different user interface, you can custom your own with NoChat :].        

<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Screenshots/screenshot-0.png" width="250" height="444" />
&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Screenshots/screenshot-1.png" width="250" height="444" />
&nbsp;&nbsp;
<img src="https://raw.githubusercontent.com/little2s/NoChat/master/Screenshots/screenshot-2.png" width="250" height="444" />

## Features
- Calculation of collection view changes and layout in background
- Supports pagination in both directions and autoloading
- Message count contention for fast pagination and rotation with thousands of messsages
- Supports custom message bubble and toolbar
- Invert mode

## Requirements
- iOS 8.0+
- Xcode 7.3 or above

## Install
### CocoaPods

Include the following in your `Podfile`:    

``` ruby
pod 'NoChat'
```
    
## Usage

Import the framework you want to use

``` swift
import NoChat
```

You can create a subclass of `ChatViewController`, and provide the data.

``` swift

class TGChatViewController: ChatViewController {

    // ...
    
    override func viewDidLoad() {
        inverted = true
        super.viewDidLoad()
    }

    
    // Setup chat items
    override func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        return [
            DateItem.itemType : [
                DateItemPresenterBuider()
            ],
            MessageType.Text.rawValue : [
                MessagePresenterBuilder<TextBubbleView, TGTextMessageViewModelBuilder>(
                    viewModelBuilder: TGTextMessageViewModelBuilder(),
                    layoutCache: messageLayoutCache
                )
            ]
        ]
    }
    
    // Setup chat input views
    override func createChatInputViewController() -> UIViewController {
        let inputController = NoChatTG.ChatInputViewController()

        // ...
        
        return inputController
    }

    // ...
    
}

```

And I also suggest you custom the view controller of chat with the protocols provide by NoChat.
I mean you can write your own `ChatViewController` without `NoChat.ChatViewController`.
Source code is mind, not just code, I think.

## Architechture
The architechture of the chat UI looks like this:
![Mind](https://raw.githubusercontent.com/little2s/NoChat/master/Assets/mind.png)

## More
See the Demo project inside.

## About the name
Why call it `NoChat`?
Because the boss let us write many apps with chat UI,
sorry I really don't want to write chat UI anymore 😢


## License
Source code is distributed under MIT license.
