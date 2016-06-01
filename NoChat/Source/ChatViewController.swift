//
//  ChatViewController.swift
//  NoChat
//
//  Created by little2s on 16/5/9.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

public struct HeightChange {
    let oldHeight: CGFloat
    let newHeight: CGFloat
    
    public init(oldHeight: CGFloat, newHeight: CGFloat) {
        self.oldHeight = oldHeight
        self.newHeight = newHeight
    }
}

public protocol ChatInputControllerProtocol {
    var onHeightChange: (HeightChange -> Void)? { get set }
    func endInputting(animated: Bool)
}

public protocol ChatItemsDecoratorProtocol {
    func decorateItems(chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem]
}

public struct DecoratedChatItem {
    public let chatItem: ChatItemProtocol
    public let decorationAttributes: ChatItemDecorationAttributesProtocol?
    public init(chatItem: ChatItemProtocol, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        self.chatItem = chatItem
        self.decorationAttributes = decorationAttributes
    }
}

public class ChatViewController: UIViewController {
    
    public struct Constants {
        var updatesAnimationDuration = 0.33
        var defaultContentInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        var defaultScrollIndicatorInsets = UIEdgeInsetsZero
        var preferredMaxMessageCount: Int? = 500 // It not nil, will ask data source to reduce number of messages when limit is reached. @see ChatDataSourceDelegateProtocol
        var preferredMaxMessageCountAdjustment: Int = 400 // When the above happens, will ask to adjust with this value. It may be wise for this to be smaller to reduce number of adjustments
        var autoloadingFractionalThreshold: CGFloat = 0.05 // in [0, 1]
    }
    
    public var constants = Constants()
    public var defaultInputContainerHeight: CGFloat = 45
    
    public private(set) var wallpaperView: UIImageView!
    public private(set) var chatItemsContainer: UIView!
    public private(set) var collectionView: UICollectionView!
    var decoratedChatItems = [DecoratedChatItem]()
    public var chatDataSource: ChatDataSourceProtocol? {
        didSet {
            self.chatDataSource?.delegate = self
            self.enqueueModelUpdate(context: .Reload)
        }
    }
    
    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    public override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.whiteColor()
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        addWallpaperView()
        addScrollProxyView()
        addChatItemsView()
        addChatInputView()
        addConstraints()
        
        automaticallyAdjustsScrollViewInsets = false // Use `chatItemsContainer` & layoutGuide
    }
    
    private func addWallpaperView() {
        wallpaperView = UIImageView(frame: CGRect.zero)
        wallpaperView.translatesAutoresizingMaskIntoConstraints = false
        wallpaperView.contentMode = .ScaleAspectFill
        wallpaperView.clipsToBounds = true
        view.addSubview(wallpaperView)
    }
    
    // Detect touches in status bar
    // http://stackoverflow.com/questions/3753097/how-to-detect-touches-in-status-bar
    private var scrollProxy: UIScrollView!
    private func addScrollProxyView() {
        scrollProxy = UIScrollView()
        scrollProxy.translatesAutoresizingMaskIntoConstraints = false
        scrollProxy.contentSize = CGSize(width: 600, height: 1000)
        scrollProxy.contentOffset = CGPoint(x: 0, y: 1)
        scrollProxy.scrollsToTop = true
        scrollProxy.scrollEnabled = true
        scrollProxy.showsVerticalScrollIndicator = false
        scrollProxy.showsHorizontalScrollIndicator = false
        scrollProxy.backgroundColor = UIColor.clearColor()
        scrollProxy.delegate = self
        view.addSubview(scrollProxy)
    }
    
    private func addChatItemsView() {
        chatItemsContainer = UIView(frame: CGRect.zero)
        chatItemsContainer.translatesAutoresizingMaskIntoConstraints = false
        chatItemsContainer.backgroundColor = UIColor.clearColor()
        chatItemsContainer.addGestureRecognizer(tapBlankRecognizer)
        view.addSubview(chatItemsContainer)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createCollectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = constants.defaultContentInsets
        collectionView.scrollIndicatorInsets = constants.defaultScrollIndicatorInsets
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.transform = inverted ? CGAffineTransformMake(1, 0, 0, -1, 0, 0) : CGAffineTransformIdentity
        chatItemsContainer.addSubview(self.collectionView)
        
        registerCells()
    }
    
    private func registerCells() {
        presenterBuildersByType = createPresenterBuilders()
        
        for presenterBuilder in presenterBuildersByType.flatMap({ $0.1 }) {
            presenterBuilder.presenterType.registerCells(collectionView)
        }
        
        DummyChatItemPresenter.registerCells(collectionView)
    }
    
    public weak var chatInputViewController: UIViewController?
    private var inputContainerHeightConstraint: NSLayoutConstraint!
    private func addChatInputView() {
        inputContainer = UIView(frame: CGRect.zero)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor.clearColor()
        view.addSubview(inputContainer)
        
        let chatInputViewController = createChatInputViewController()
        
        if var inputController = chatInputViewController as? ChatInputControllerProtocol {
            inputController.onHeightChange = { [weak self] change in
                self?.relayoutForChatInputViewHeightChange(change)
            }
        }
        
        let inputView = chatInputViewController.view
        inputView?.translatesAutoresizingMaskIntoConstraints = false
        
        addChildViewController(chatInputViewController)
        inputContainer.addSubview(inputView)
        
        self.chatInputViewController = chatInputViewController
    }
    
    private func addConstraints() {
        wallpaperView.setContentHuggingPriority(UILayoutPriority(240), forAxis: .Horizontal)
        wallpaperView.setContentHuggingPriority(UILayoutPriority(240), forAxis: .Vertical)
        wallpaperView.setContentCompressionResistancePriority(UILayoutPriority(240), forAxis: .Horizontal)
        wallpaperView.setContentCompressionResistancePriority(UILayoutPriority(240), forAxis: .Vertical)
        
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .Top, relatedBy: .Equal, toItem: view, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .Leading, relatedBy: .Equal, toItem: view, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .Bottom, relatedBy: .Equal, toItem: view, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .Trailing, relatedBy: .Equal, toItem: view, attribute: .Trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topLayoutGuide, attribute: .Bottom, relatedBy: .Equal, toItem: chatItemsContainer, attribute: .Top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: chatItemsContainer, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Top, relatedBy: .Equal, toItem: chatItemsContainer, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: chatItemsContainer, attribute: .Trailing, multiplier: 1, constant: 0))
        
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .Top, relatedBy: .Equal, toItem: collectionView, attribute: .Top, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .Leading, relatedBy: .Equal, toItem: collectionView, attribute: .Leading, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .Bottom, relatedBy: .Equal, toItem: collectionView, attribute: .Bottom, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .Trailing, relatedBy: .Equal, toItem: collectionView, attribute: .Trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Top, relatedBy: .Equal, toItem: chatItemsContainer, attribute: .Bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Leading, relatedBy: .Equal, toItem: inputContainer, attribute: .Leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .Trailing, relatedBy: .Equal, toItem: inputContainer, attribute: .Trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: bottomLayoutGuide, attribute: .Top, relatedBy: .Equal, toItem: inputContainer, attribute: .Bottom, multiplier: 1, constant: 0))
        inputContainerHeightConstraint = NSLayoutConstraint(item: inputContainer, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .Height, multiplier: 1, constant: defaultInputContainerHeight)
        inputContainer.addConstraint(inputContainerHeightConstraint)
        
        guard let inputView = chatInputViewController?.view else { return }
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Top, relatedBy: .Equal, toItem: inputView, attribute: .Top, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Bottom, relatedBy: .Equal, toItem: inputView, attribute: .Bottom, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Leading, relatedBy: .Equal, toItem: inputView, attribute: .Leading, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .Trailing, relatedBy: .Equal, toItem: inputView, attribute: .Trailing, multiplier: 1, constant: 0))
        
    }
    
    public var isFirstLayout: Bool = true
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            updateQueue.start()
            isFirstLayout = false
        }
    }
    
    func rectAtIndexPath(indexPath: NSIndexPath?) -> CGRect? {
        if let indexPath = indexPath {
            return collectionView.collectionViewLayout.layoutAttributesForItemAtIndexPath(indexPath)?.frame
        }
        return nil
    }
    
    var autoLoadingEnabled: Bool = false
    var inputContainer: UIView!
    var presenterBuildersByType = [ChatItemType: [ChatItemPresenterBuilderProtocol]]()
    var presenters = [ChatItemPresenterProtocol]()
    let presentersByChatItem = NSMapTable(keyOptions: .WeakMemory, valueOptions: .StrongMemory)
    let presentersByCell = NSMapTable(keyOptions: .WeakMemory, valueOptions: .WeakMemory)
    var updateQueue: SerialTaskQueueProtocol = SerialTaskQueue()
    
    public func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        assert(false, "Override in subclass")
        return [ChatItemType: [ChatItemPresenterBuilderProtocol]]()
    }
    
    public func createChatInputViewController() -> UIViewController {
        assert(false, "Override in subclass")
        return UIViewController()
    }
    
    /**
     - You can use a decorator to:
     - Provide the ChatCollectionViewLayout with margins between messages
     - Provide to your pressenters additional attributes to help them configure their cells (for instance if a bubble should show a tail)
     - You can also add new items (for instance time markers or failed cells)
     */
    public var chatItemsDecorator: ChatItemsDecoratorProtocol?
    
    public var createCollectionViewLayout: UICollectionViewLayout {
        let layout = ChatCollectionViewLayout()
        layout.delegate = self
        return layout
    }
    
    var layoutModel = ChatCollectionViewLayoutModel.createModel(0, itemsLayoutData: [])
    
    public var inverted: Bool = true
    
    public lazy var tapBlankRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapBlank(_:)))
        return tap
    }()
    
    public func handleTapBlank(recognizer: UITapGestureRecognizer) {
        (chatInputViewController as? ChatInputControllerProtocol)?.endInputting(true)
    }
    
    public func relayoutForChatInputViewHeightChange(change: HeightChange) {
        let dH = change.newHeight - change.oldHeight
        
        if fabs(dH) > 1 {
            let minContainerHeight = defaultInputContainerHeight
            inputContainerHeightConstraint.constant = max(minContainerHeight, change.newHeight)
            
            if !inverted {
                let topPadding = collectionView.contentInset.top
                let bottomPadding = collectionView.contentInset.bottom
                
                let dY = collectionView.contentOffset.y + dH
                
                let minY = 0 - topPadding
                let maxY = minY + collectionView.contentSize.height + topPadding + bottomPadding
                
                collectionView.contentOffset.y = max(minY, min(maxY, dY))
            }
            
            view.layoutIfNeeded()
            
        }
    }
}

extension ChatViewController { // Rotation
    
    public override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        let shouldScrollToBottom = isScrolledAtBottom()
        let referenceIndexPath = collectionView.indexPathsForVisibleItems().first
        let oldRect = rectAtIndexPath(referenceIndexPath)
        coordinator.animateAlongsideTransition({ (context) -> Void in
            if shouldScrollToBottom {
                self.scrollToBottom(animated: false)
            } else {
                let newRect = self.rectAtIndexPath(referenceIndexPath)
                self.scrollToPreservePosition(oldRefRect: oldRect, newRefRect: newRect)
            }
        }, completion: nil)
    }
}

extension ChatViewController: UIScrollViewDelegate { // Handler tap status bar
    public func scrollViewShouldScrollToTop(scrollView: UIScrollView) -> Bool {
        precondition(scrollView === scrollProxy, "Other scroll views should not set `scrollsToTop` true")
        
        if inverted {
            let shouldScrollToBottom = !isScrolledAtBottom()
            if shouldScrollToBottom {
                scrollToBottom(animated: true)
            }
            return false
        } else {
            let shouldScrollToTop = !isScrolledAtTop()
            if shouldScrollToTop {
                scrollToTop(animated: true)
            }
        }
        
        return false
    }
}
