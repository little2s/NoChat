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
    var onHeightChange: ((HeightChange) -> Void)? { get set }
    func endInputting(_ animated: Bool)
}

public protocol ChatItemsDecoratorProtocol {
    func decorateItems(_ chatItems: [ChatItemProtocol], inverted: Bool) -> [DecoratedChatItem]
}

public struct DecoratedChatItem {
    public let chatItem: ChatItemProtocol
    public let decorationAttributes: ChatItemDecorationAttributesProtocol?
    public init(chatItem: ChatItemProtocol, decorationAttributes: ChatItemDecorationAttributesProtocol?) {
        self.chatItem = chatItem
        self.decorationAttributes = decorationAttributes
    }
}

open class ChatViewController: UIViewController {
    
    public struct Constants {
        var updatesAnimationDuration = 0.33
        var defaultContentInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 0)
        var defaultScrollIndicatorInsets = UIEdgeInsets.zero
        var preferredMaxMessageCount: Int? = 500 // It not nil, will ask data source to reduce number of messages when limit is reached. @see ChatDataSourceDelegateProtocol
        var preferredMaxMessageCountAdjustment: Int = 400 // When the above happens, will ask to adjust with this value. It may be wise for this to be smaller to reduce number of adjustments
        var autoloadingFractionalThreshold: CGFloat = 0.05 // in [0, 1]
    }
    
    open var constants = Constants()
    open var defaultInputContainerHeight: CGFloat = 45
    
    open fileprivate(set) var wallpaperView: UIImageView!
    open fileprivate(set) var chatItemsContainer: UIView!
    open fileprivate(set) var collectionView: UICollectionView!
    var decoratedChatItems = [DecoratedChatItem]()
    open var chatDataSource: ChatDataSourceProtocol? {
        didSet {
            self.chatDataSource?.delegate = self
            self.enqueueModelUpdate(context: .reload)
        }
    }
    
    deinit {
        self.collectionView.delegate = nil
        self.collectionView.dataSource = nil
    }
    
    open override func loadView() {
        view = UIView()
        view.backgroundColor = UIColor.white
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        addWallpaperView()
        addScrollProxyView()
        addChatItemsView()
        addChatInputView()
        addConstraints()
        
        automaticallyAdjustsScrollViewInsets = false // Use `chatItemsContainer` & layoutGuide
    }
    
    fileprivate func addWallpaperView() {
        wallpaperView = UIImageView(frame: CGRect.zero)
        wallpaperView.translatesAutoresizingMaskIntoConstraints = false
        wallpaperView.contentMode = .scaleAspectFill
        wallpaperView.clipsToBounds = true
        view.addSubview(wallpaperView)
    }
    
    // Detect touches in status bar
    // http://stackoverflow.com/questions/3753097/how-to-detect-touches-in-status-bar
    open fileprivate(set) var scrollProxy: UIScrollView!
    fileprivate func addScrollProxyView() {
        scrollProxy = UIScrollView()
        scrollProxy.translatesAutoresizingMaskIntoConstraints = false
        scrollProxy.contentSize = CGSize(width: 600, height: 1000)
        scrollProxy.contentOffset = CGPoint(x: 0, y: 1)
        scrollProxy.scrollsToTop = true
        scrollProxy.isScrollEnabled = true
        scrollProxy.showsVerticalScrollIndicator = false
        scrollProxy.showsHorizontalScrollIndicator = false
        scrollProxy.backgroundColor = UIColor.clear
        scrollProxy.delegate = self
        view.addSubview(scrollProxy)
    }
    
    fileprivate func addChatItemsView() {
        chatItemsContainer = UIView(frame: CGRect.zero)
        chatItemsContainer.translatesAutoresizingMaskIntoConstraints = false
        chatItemsContainer.backgroundColor = UIColor.clear
        chatItemsContainer.addGestureRecognizer(tapBlankRecognizer)
        view.addSubview(chatItemsContainer)
        
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: createCollectionViewLayout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.contentInset = constants.defaultContentInsets
        collectionView.scrollIndicatorInsets = constants.defaultScrollIndicatorInsets
        collectionView.alwaysBounceVertical = true
        collectionView.backgroundColor = UIColor.clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.allowsSelection = false
        collectionView.scrollsToTop = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.transform = inverted ? CGAffineTransform(a: 1, b: 0, c: 0, d: -1, tx: 0, ty: 0) : CGAffineTransform.identity
        chatItemsContainer.addSubview(self.collectionView)
        
        registerCells()
    }
    
    fileprivate func registerCells() {
        presenterBuildersByType = createPresenterBuilders()
        
        for presenterBuilder in presenterBuildersByType.flatMap({ $0.1 }) {
            presenterBuilder.presenterType.registerCells(collectionView)
        }
        
        DummyChatItemPresenter.registerCells(collectionView)
    }
    
    open weak var chatInputViewController: UIViewController?
    fileprivate var inputContainerHeightConstraint: NSLayoutConstraint!
    fileprivate func addChatInputView() {
        inputContainer = UIView(frame: CGRect.zero)
        inputContainer.translatesAutoresizingMaskIntoConstraints = false
        inputContainer.backgroundColor = UIColor.clear
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
        inputContainer.addSubview(inputView!)
        
        self.chatInputViewController = chatInputViewController
    }
    
    fileprivate func addConstraints() {
        wallpaperView.setContentHuggingPriority(UILayoutPriority(240), for: .horizontal)
        wallpaperView.setContentHuggingPriority(UILayoutPriority(240), for: .vertical)
        wallpaperView.setContentCompressionResistancePriority(UILayoutPriority(240), for: .horizontal)
        wallpaperView.setContentCompressionResistancePriority(UILayoutPriority(240), for: .vertical)
        
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: wallpaperView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: scrollProxy, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: topLayoutGuide, attribute: .bottom, relatedBy: .equal, toItem: chatItemsContainer, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: chatItemsContainer, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .top, relatedBy: .equal, toItem: chatItemsContainer, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: chatItemsContainer, attribute: .trailing, multiplier: 1, constant: 0))
        
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .top, relatedBy: .equal, toItem: collectionView, attribute: .top, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .leading, relatedBy: .equal, toItem: collectionView, attribute: .leading, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .bottom, relatedBy: .equal, toItem: collectionView, attribute: .bottom, multiplier: 1, constant: 0))
        chatItemsContainer.addConstraint(NSLayoutConstraint(item: chatItemsContainer, attribute: .trailing, relatedBy: .equal, toItem: collectionView, attribute: .trailing, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .top, relatedBy: .equal, toItem: chatItemsContainer, attribute: .bottom, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .leading, relatedBy: .equal, toItem: inputContainer, attribute: .leading, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .trailing, relatedBy: .equal, toItem: inputContainer, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: inputContainer, attribute: .bottom, multiplier: 1, constant: 0))
        inputContainerHeightConstraint = NSLayoutConstraint(item: inputContainer, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: defaultInputContainerHeight)
        inputContainer.addConstraint(inputContainerHeightConstraint)
        
        guard let inputView = chatInputViewController?.view else { return }
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .top, relatedBy: .equal, toItem: inputView, attribute: .top, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .bottom, relatedBy: .equal, toItem: inputView, attribute: .bottom, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .leading, relatedBy: .equal, toItem: inputView, attribute: .leading, multiplier: 1, constant: 0))
        inputContainer.addConstraint(NSLayoutConstraint(item: inputContainer, attribute: .trailing, relatedBy: .equal, toItem: inputView, attribute: .trailing, multiplier: 1, constant: 0))
        
    }
    
    open var isFirstLayout: Bool = true
    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isFirstLayout {
            updateQueue.start()
            isFirstLayout = false
        }
    }
    
    func rectAtIndexPath(_ indexPath: IndexPath?) -> CGRect? {
        if let indexPath = indexPath {
            return collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame
        }
        return nil
    }
    
    var autoLoadingEnabled: Bool = false
    var inputContainer: UIView!
    var presenterBuildersByType = [ChatItemType: [ChatItemPresenterBuilderProtocol]]()

    
    let presentersByChatItem = NSMapTable<AnyObject, AnyObject>(keyOptions: .weakMemory, valueOptions: .weakMemory)
    
    let presentersByCell = NSMapTable<UICollectionViewCell, AnyObject>(keyOptions: .weakMemory, valueOptions: .weakMemory)
    var updateQueue: SerialTaskQueueProtocol = SerialTaskQueue()
    
    open func createPresenterBuilders() -> [ChatItemType: [ChatItemPresenterBuilderProtocol]] {
        assert(false, "Override in subclass")
        return [ChatItemType: [ChatItemPresenterBuilderProtocol]]()
    }
    
    open func createChatInputViewController() -> UIViewController {
        assert(false, "Override in subclass")
        return UIViewController()
    }
    
    /**
     - You can use a decorator to:
     - Provide the ChatCollectionViewLayout with margins between messages
     - Provide to your pressenters additional attributes to help them configure their cells (for instance if a bubble should show a tail)
     - You can also add new items (for instance time markers or failed cells)
     */
    open var chatItemsDecorator: ChatItemsDecoratorProtocol?
    
    open var createCollectionViewLayout: UICollectionViewLayout {
        let layout = ChatCollectionViewLayout()
        layout.delegate = self
        return layout
    }
    
    var layoutModel = ChatCollectionViewLayoutModel.createModel(0, itemsLayoutData: [])
    
    open var inverted: Bool = true
    
    open lazy var tapBlankRecognizer: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapBlank(_:)))
        return tap
    }()
    
    open func handleTapBlank(_ recognizer: UITapGestureRecognizer) {
        (chatInputViewController as? ChatInputControllerProtocol)?.endInputting(true)
    }
    
    open func relayoutForChatInputViewHeightChange(_ change: HeightChange) {
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
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        let shouldScrollToBottom = isScrolledAtBottom()
        let referenceIndexPath = collectionView.indexPathsForVisibleItems.first
        let oldRect = rectAtIndexPath(referenceIndexPath)
        coordinator.animate(alongsideTransition: { (context) -> Void in
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
    public func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
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
