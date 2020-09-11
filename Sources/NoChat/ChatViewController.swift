//
//  ChatViewController.swift
//  
//
//  Created by yinglun on 2020/8/9.
//

import UIKit

open class ChatViewController: UIViewController {

    ///
    /// Pay more attention to inverted mode with layouts,
    /// as you see on collectionView:
    ///
    /// +------------+                +------------+
    /// |    ...     |                |  layout 0  |
    /// |  layout 2  |                |  layout 1  |
    /// |  layout 1  |       VS.      |  layout 2  |
    /// |  layout 0  |                |    ...     |
    /// +------------+                +------------+
    ///
    /// inverted is true             inverted is false
    ///
    open var layouts: [AnyItemLayout] = []
    
    private var cellRegisterTable: [String: Bool] = [:]
    
    open var cellWidth: CGFloat {
        assert(Thread.isMainThread)
        return collectionView.bounds.width - collectionView.contentInset.left - collectionView.contentInset.right
    }
    open var safeAreaInsets: UIEdgeInsets { view.safeAreaInsets }
    
    public let containerView = ContainerView()
    public let backgroundView = UIImageView()
    
    public var collectionView: ItemsView
    public var collectionViewLayout = ItemsViewLayout()
    public let scrollProxy = UIScrollView()
    
    public var inputPanel: InputPanel
    open var inputPanelDefaultHeight: CGFloat = 0

    private var isRegisterKeyboardNotifications: Bool = false
    open var halfTransitionKeyboardHeight: CGFloat = 0
    open var keyboardHeight: CGFloat = 0
    open var isRotating: Bool = false
    
    open var isAutoInControllerTransition: Bool = true
    open var isInControllerTransition: Bool = false
    
    private var isFirstLayout: Bool = true
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.collectionView = ItemsView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.inputPanel = InputPanel()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.hidesBottomBarWhenPushed = true
    }
    
    public required init?(coder: NSCoder) {
        self.collectionView = ItemsView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.inputPanel = InputPanel()
        super.init(coder: coder)
        self.hidesBottomBarWhenPushed = true
    }
    
    deinit {
        unregisterKeyboardNotifications()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
        setupScrollProxy()
        setupContainerView()
        setupCollectionView()
        setupInputPanel()
        registerKeyboardNotifications()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        containerView.frame = view.bounds
        if isFirstLayout {
            defer { isFirstLayout = false }
            layoutInputPanel()
            adjustCollectionViewInsets()
        }
    }
    
    open override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isAutoInControllerTransition {
            isInControllerTransition = false
        }
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if isAutoInControllerTransition {
            isInControllerTransition = true
        }
    }
    
    open override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let previousSize = view.frame.size
        if abs(size.width - previousSize.height) < .ulpOfOne, abs(size.height - previousSize.width) < .ulpOfOne {
            isRotating = true
        }
        coordinator.animate(alongsideTransition: nil, completion: { [weak self] _ in
            guard let strongSelf = self else { return }
            if strongSelf.isRotating {
                strongSelf.isRotating = false
            }
        })
    }
    
    private func setupBackgroundView() {
        if #available(iOS 13, *) {
            view.backgroundColor = UIColor.systemBackground
        } else {
            view.backgroundColor = UIColor.white
        }
        backgroundView.frame = view.bounds
        backgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        backgroundView.contentMode = .scaleAspectFill
        backgroundView.clipsToBounds = true
        view.addSubview(backgroundView)
    }
    
    private func setupScrollProxy() {
        scrollProxy.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 8)
        scrollProxy.autoresizingMask = [.flexibleWidth]
        scrollProxy.contentSize = CGSize(width: 1, height: 16)
        scrollProxy.contentOffset = CGPoint(x: 0, y: 8)
        scrollProxy.scrollsToTop = true
        scrollProxy.isScrollEnabled = true
        scrollProxy.showsVerticalScrollIndicator = false
        scrollProxy.showsHorizontalScrollIndicator = false
        scrollProxy.backgroundColor = UIColor.clear
        scrollProxy.delegate = self
        view.addSubview(scrollProxy)
    }
    
    private func setupContainerView() {
        containerView.frame = view.bounds
        containerView.backgroundColor = UIColor.clear
        containerView.clipsToBounds = true
        containerView.sizeHandler = { [weak self] size in
            guard let strongSelf = self else { return }
            if strongSelf.keyboardHeight < .ulpOfOne {
                strongSelf.performSizeChange(with: strongSelf.isRotating ? 0.3 : 0.0, size: size)
            }
        }
        view.addSubview(containerView)
    }
    
    private func setupCollectionView() {
        collectionView.frame = containerView.bounds
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.tapAction = { [weak self] in
            self?.inputPanel.endInputting(animated: true)
        }
        containerView.addSubview(collectionView)
    }
    
    private func setupInputPanel() {
        inputPanel.delegate = self
        view.addSubview(inputPanel)
    }
    
    private func layoutInputPanel() {
        inputPanel.frame = CGRect(x: 0, y: view.bounds.height - safeAreaInsets.bottom - inputPanelDefaultHeight, width: view.bounds.width, height: inputPanelDefaultHeight)
    }
    
    open func registerKeyboardNotifications() {
        if !isRegisterKeyboardNotifications {
            defer { isRegisterKeyboardNotifications = true }
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidChangeFrame), name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        }
    }
    
    open func unregisterKeyboardNotifications() {
        if isRegisterKeyboardNotifications {
            defer { isRegisterKeyboardNotifications = false }
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
        }
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if isInControllerTransition { return }
        
        let collectionViewSize = containerView.frame.size
        
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.3
        let curve = (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 0
        
        let screenKeyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect) ?? .zero
        let keyboradFrame = containerView.convert(screenKeyboardFrame, from: nil)
        
        var keyboardHeight = (keyboradFrame.height <= .ulpOfOne || keyboradFrame.width <= .ulpOfOne) ? 0.0 : collectionViewSize.height - keyboradFrame.origin.y
        
        halfTransitionKeyboardHeight = keyboardHeight
        
        keyboardHeight = max(keyboardHeight, 0.0)
        
        if keyboradFrame.origin.y + keyboradFrame.height < collectionViewSize.height - .ulpOfOne {
            keyboardHeight = 0.0
        }
        
        if abs(self.keyboardHeight - keyboardHeight) < .ulpOfOne, abs(collectionViewSize.width - self.collectionView.frame.width) < .ulpOfOne {
            return
        }
        
        if isRotating, keyboardHeight < .ulpOfOne {
            return
        }
        
        if abs(self.keyboardHeight - keyboardHeight) > .ulpOfOne {
            self.keyboardHeight = keyboardHeight
            
            if abs(collectionViewSize.width - collectionView.frame.width) > .ulpOfOne {
                if Thread.isMainThread {
                    self.performSizeChange(with: 0.3, size: collectionViewSize)
                } else {
                    DispatchQueue.main.async {
                        self.performSizeChange(with: 0.3, size: collectionViewSize)
                    }
                }
            } else {
                inputPanel.adjust(for: view.bounds.size, keyboardHeight: keyboardHeight, duration: duration, animationCurve: curve)
                adjustCollectionView(for: containerView.bounds.size, keyboardHeight: keyboardHeight, inputPanelHeight: inputPanel.frame.height, scrollToBottom: false, duration: duration, animationCurve: curve)
            }
        }
    }
    
    @objc private func keyboardDidChangeFrame(_ notification: Notification) {
        // TODO: for iPad OS
    }
    
    open func adjustCollectionView(for size: CGSize, keyboardHeight: CGFloat, inputPanelHeight: CGFloat, scrollToBottom: Bool, duration: TimeInterval, animationCurve: Int) {
        collectionView.stopScrollIfNeeded()
        
        let contentHeight = collectionView.contentSize.height
        
        let bottomPadding: CGFloat
        if keyboardHeight < .ulpOfOne {
            bottomPadding = safeAreaInsets.bottom + inputPanelHeight
        } else {
            bottomPadding = keyboardHeight + inputPanelHeight
        }
        
        let originalInset = collectionView.contentInset
        var inset = originalInset
        if collectionView.isInverted {
            inset.top = bottomPadding
        } else {
            inset.bottom = bottomPadding
        }
        
        let originalContentOffset = collectionView.contentOffset
        var contentOffset = originalContentOffset
        
        if scrollToBottom {
            if collectionView.isInverted {
                contentOffset.y = -inset.top
            } else {
                contentOffset.y = contentHeight - collectionView.bounds.height + inset.bottom
            }
        } else {
            if collectionView.isInverted {
                contentOffset.y += originalInset.top - inset.top;
            } else {
                contentOffset.y += inset.bottom - originalInset.bottom;
            }
            contentOffset.y = min(contentOffset.y, contentHeight - collectionView.bounds.height + inset.bottom)
            contentOffset.y = max(contentOffset.y, -inset.top);
        }
        
        func subjob() {
            if contentOffset != originalContentOffset {
                self.collectionView.contentOffset = contentOffset
            }
            UIView.performWithoutAnimation {
                self.collectionView.contentInset = inset
            }
        }
        
        if duration > .ulpOfOne {
            UIView.animate(withDuration: duration, delay: 0, options: UIView.AnimationOptions(rawValue: UInt(animationCurve << 16)), animations: {
                subjob()
            }, completion: nil)
        } else {
            subjob()
        }
    }
    
    open func adjustCollectionViewInsets() {
        let safeAreaInsets = self.safeAreaInsets
        let topPadding = safeAreaInsets.top
        let bottomPadding: CGFloat
        if keyboardHeight < .ulpOfOne {
            bottomPadding = safeAreaInsets.bottom + inputPanel.frame.height
        } else {
            bottomPadding = keyboardHeight + inputPanel.frame.height
        }
        let originalInset = collectionView.contentInset
        var inset = originalInset
        if (collectionView.isInverted) {
            inset.bottom = topPadding
            inset.top = bottomPadding
        } else {
            inset.top = topPadding
            inset.bottom = bottomPadding
        }
        inset.left = safeAreaInsets.left
        inset.right = safeAreaInsets.right
        collectionView.contentInset = inset
    }
    
    open func performSizeChange(with duration: TimeInterval, size: CGSize) {
        collectionView.stopScrollIfNeeded()
        
        let keyboardHeight = self.keyboardHeight
        
        inputPanel.change(to: size, keyboardHeight: keyboardHeight, duration: duration)
        
        collectionView.frame = containerView.bounds
        
        adjustCollectionViewInsets()
        
        collectionView.collectionViewLayout.invalidateLayout()
        
        for (index, layout) in self.layouts.enumerated() {
            var l = layout
            l.calculate(preferredWidth: collectionView.bounds.width)
            self.layouts[index] = l
        }
        collectionView.reloadData()
        collectionView.collectionViewLayout.prepare()
        collectionView.layoutIfNeeded()
        
        // TODO: adjust conentOffset and animation
        collectionView.scrollToBottom(animated: true)
    }
    
    open func statusBarDidTap() {
        let shouldScrollToTop = !collectionView.isScrolledAtTop
        if shouldScrollToTop {
            collectionView.scrollToTop(animated: true)
        }
    }
    
}

// MARK: - UIScrollViewDelegate

extension ChatViewController: UIScrollViewDelegate {
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool {
        assert(scrollView == scrollProxy, "Other scroll views should not set `scrollsToTop` true")
        statusBarDidTap()
        return false
    }
}

// MARK: - UICollectionViewDataSource

extension ChatViewController: UICollectionViewDataSource, UICollectionViewDelegate, ItemsViewLayoutDelegate, ItemCellDelegate {
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return layouts.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let layout = layouts[indexPath.item]
        let cellReuseIdentifier = layout.cellReuseIdentifier
        if cellRegisterTable[cellReuseIdentifier] == nil {
            switch layout.cellRegister {
            case .class(let value):
                collectionView.register(value, forCellWithReuseIdentifier: cellReuseIdentifier)
            case .nib(let value):
                collectionView.register(value, forCellWithReuseIdentifier: cellReuseIdentifier)
            }
            cellRegisterTable[cellReuseIdentifier] = true
        }
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? ItemCell {
            cell.delegate = self
            UIView.performWithoutAnimation {
                cell.layout = layout
                if cell.itemView.transform != collectionView.transform {
                    cell.itemView.transform = collectionView.transform
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// MARK: - InputPanelDelegate

extension ChatViewController: InputPanelDelegate {
    open func inputPanel(_ inputPanel: InputPanel, willChange height: CGFloat, duration: TimeInterval, animationCurve: Int) {
        adjustCollectionView(for: containerView.bounds.size, keyboardHeight: keyboardHeight, inputPanelHeight: height, scrollToBottom: false, duration: duration, animationCurve: animationCurve)
    }
}
