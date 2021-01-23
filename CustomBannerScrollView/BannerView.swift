//
//  BannerView.swift
//  CustomBannerScrollView
//
//  Created by Andrei Volkau on 10.12.2020.
//

import Foundation
import UIKit

struct BannerViewModel {
    let items: [Item]
    
    struct Item {
        let imageUrl: String
        let timerTimeout: Double
    }
}

protocol BannerViewProtocol: class {
    func didTap(atIndex index: Int)
}


final class BannerView: UIView {
    
    //MARK: - Inner types
    
    private enum ScrollDirection {
        case next
        case prev
    }
    
    final class ItemView: UIView {
        
        let iconImageView = WebImageView()
        
        init() {
            super.init(frame: .zero)
            setupLayout()
        }
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupLayout()
        }
        
        private func setupLayout() {
            addSubview(iconImageView)
            iconImageView.contentMode = .scaleAspectFill
            self.layer.masksToBounds = true
            self.layer.cornerRadius = 8.0
        }
        
        func set(viewModel: BannerViewModel.Item) {
            iconImageView.load(with: viewModel.imageUrl)
        }
        
        override func layoutSubviews() {
            super.layoutSubviews()
            self.iconImageView.frame = self.bounds
        }
    }
    
    //MARK: - Public vars
    
    weak var delegate: BannerViewProtocol?
    
    //MARK: - Private vars
    
    private let horizontalItemOffsetFromSuperView: CGFloat = 8.0
    private let spaceBetweenItems: CGFloat = 8.0
    
    //UI representation
    private let scrollView = UIScrollView()
    private let pageControl = UIPageControl()
    
    private let leftItemView = ItemView()
    private let centerItemView = ItemView()
    private let rightItemView = ItemView()
    private lazy var imageViews = [leftItemView, centerItemView, rightItemView]
    
    //View model
    private var leftItemViewModel: BannerViewModel.Item {
        guard let items = self.viewModel?.items else { fatalError("not ready") }
        let leftIndex = items.index(before: self.currentCenterItemIndex)
        return leftIndex < 0 ? items.last! : items[leftIndex]
    }
    private var centerItemViewModel: BannerViewModel.Item {
        guard let items = self.viewModel?.items else { fatalError("not ready") }
        return items[self.currentCenterItemIndex]
    }
    private var rightItemViewModel: BannerViewModel.Item {
        guard let items = self.viewModel?.items else { fatalError("not ready") }
        let rightIndex = items.index(after: self.currentCenterItemIndex)
        return rightIndex >= items.count ? items.first! : items[rightIndex]
    }
    
    private var viewModel: BannerViewModel? {
        didSet {
            guard let viewModel = viewModel else { return }
            pageControl.numberOfPages = viewModel.items.count
            restartTimer(timeout: viewModel.items[0].timerTimeout)
        }
    }
    
    // additional settings
    private var targetOffset: CGPoint?
    private var currentCenterItemIndex: Int = 0 {
        didSet {
            pageControl.currentPage = currentCenterItemIndex
        }
    }
    private var scrollDirection: ScrollDirection = .next
    private var timer: Timer? = nil
    
    //MARK: - Lifecycle
    
    init() {
        super.init(frame: .zero)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    deinit {
        cancelTimer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = self.bounds
        
        let itemWidth = self.frame.width - horizontalItemOffsetFromSuperView * 2
        let itemHeight: CGFloat = scrollView.frame.height
        
        var startX: CGFloat = 0.0
        imageViews.enumerated().forEach { (index, view) in
            view.frame.origin = CGPoint(x: startX, y: 0.0)
            view.frame.size = CGSize(width: itemWidth, height: itemHeight)
            startX += itemWidth + spaceBetweenItems
        }
        
        let viewsCount = CGFloat(imageViews.count)
        let contentWidth: CGFloat = itemWidth * viewsCount + spaceBetweenItems * (viewsCount - 1.0)
        scrollView.contentSize = CGSize(width: contentWidth, height: self.frame.height)
        pageControl.frame = .init(x: self.frame.minX, y: self.centerItemView.bounds.maxY, width: self.frame.width, height: 20)
    }
    
    //MARK: - Private methods
    
    private func setup() {
        setutSubviews()
        setupScrollView()
        setupPageControl()
        setupGesture()
    }
    
    private func setutSubviews() {
        addSubview(scrollView)
        addSubview(pageControl)
        imageViews.forEach { scrollView.addSubview($0) }
    }
    
    private func setupScrollView() {
        scrollView.decelerationRate = .fast
        scrollView.showsHorizontalScrollIndicator = false
        self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 16, bottom: 0.0, right: 16)
        self.scrollView.delegate = self
    }
    
    private func setupPageControl() {
        pageControl.currentPageIndicatorTintColor = UIColor.commonTintColor
        pageControl.pageIndicatorTintColor = UIColor.commonTintInactiveColor
    }
    
    private func nextItem() {
        self.currentCenterItemIndex += 1
        
        if viewModel?.items.count == currentCenterItemIndex {
            self.currentCenterItemIndex = 0
        }
        updateNext()
        scrollDirection = .next
    }
    
    private func prevItem() {
        self.currentCenterItemIndex -= 1
        if currentCenterItemIndex == -1 {
            self.currentCenterItemIndex = viewModel?.items.indices.last ?? 0
        }
        updatePrev()
        scrollDirection = .prev
    }
    
    func updateNext() {
        self.leftItemView.iconImageView.image = centerItemView.iconImageView.image
        centerItemView.iconImageView.image = rightItemView.iconImageView.image
        self.rightItemView.set(viewModel: rightItemViewModel)
    }
    
    func updatePrev() {
        self.rightItemView.iconImageView.image = centerItemView.iconImageView.image
        centerItemView.iconImageView.image = leftItemView.iconImageView.image
        self.leftItemView.set(viewModel: leftItemViewModel)
    }
    
    private func updateViews() {
        self.leftItemView.set(viewModel: leftItemViewModel)
        self.centerItemView.set(viewModel: centerItemViewModel)
        self.rightItemView.set(viewModel: rightItemViewModel)
    }
    
    private func restartTimer(timeout: Double) {
        timer?.invalidate()
        timer = nil
        timer = Timer.scheduledTimer(timeInterval: timeout, target: self, selector: #selector(nextSlide), userInfo: nil, repeats: true)
    }
    
    private func cancelTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func setupGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        centerItemView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Actions
    
    @objc func nextSlide() {
        self.scrollView.scrollRectToVisible(
            .init(origin: .init(x: rightItemView.frame.minX - spaceBetweenItems, y:  rightItemView.frame.minY), size: rightItemView.frame.size), animated: true)
    }
    
    @objc func didTap() {
        delegate?.didTap(atIndex: currentCenterItemIndex) //else viewModel (depends on our need)
    }
    
    //MARK: - Public methods
    
    func set(viewModel: BannerViewModel?) {
        self.viewModel = viewModel
        updateViews()
        self.scrollView.contentOffset.x = self.centerItemView.frame.minX - horizontalItemOffsetFromSuperView
    }
}

    //MARK: - Extensions

extension BannerView: UIScrollViewDelegate {
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let gap = centerItemView.frame.width / 3
        let targetOffsetRight = targetContentOffset.pointee.x + self.frame.width
        if rightItemView.frame.minX + gap < targetOffsetRight {
            targetContentOffset.pointee.x = rightItemView.frame.midX - self.frame.midX
        } else if (self.leftItemView.frame.maxX - gap) > targetContentOffset.pointee.x {
            targetContentOffset.pointee.x = self.leftItemView.frame.midX - self.frame.midX
        }
        else {
            targetContentOffset.pointee.x = self.centerItemView.frame.midX - self.frame.midX
        }
        targetOffset = targetContentOffset.pointee
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        cancelTimer()
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let viewModel = viewModel else { return }
        restartTimer(timeout: viewModel.items[currentCenterItemIndex].timerTimeout)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let gap = leftItemView.frame.width / 3
        if var targeOffset = targetOffset {
        let targetOffsetRight = targeOffset.x + self.frame.width
          let additionalOffset = self.frame.width - spaceBetweenItems
            if scrollDirection == .next && rightItemView.frame.minX + gap < targetOffsetRight {
                targeOffset.x -= additionalOffset
                scrollView.setContentOffset(targeOffset, animated: true)
            } else if (self.leftItemView.frame.maxX - gap) > targeOffset.x {
                targeOffset.x += additionalOffset
                scrollView.setContentOffset(targeOffset, animated: true)
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard self.leftItemView.frame.width > 0,
              self.centerItemView.frame.width > 0,
              self.rightItemView.frame.width > 0
              else { return }

        let gap: CGFloat = self.centerItemView.frame.width / 3

        let currentRightOffset: CGFloat = scrollView.contentOffset.x + self.frame.width + scrollView.contentInset.left

        if (self.rightItemView.frame.maxX - gap) < currentRightOffset {
            scrollView.contentOffset.x -= self.centerItemView.frame.width + spaceBetweenItems
            self.nextItem()
        } else if (self.leftItemView.frame.minX + gap) > scrollView.contentOffset.x {
            scrollView.contentOffset.x += self.centerItemView.frame.width + spaceBetweenItems
            self.prevItem()
        }
    }
}
