//
//  ViewController.swift
//  InfiniteCarousel
//
//  Created by JeongminKim on 2023/07/05.
//

import UIKit
import SnapKit

class CollectionViewCell: UICollectionViewCell {
    static let identifier = "CollectionViewCell"
    
    private lazy var cellImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        cellImageView.image = nil
    }
    
    private func setLayout() {
        contentView.addSubview(cellImageView)
        cellImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func config(name: String) {
        cellImageView.image = UIImage(systemName: name)
    }
}

class ViewController: UIViewController {
    
    var items = [
        "snowflake",
        "key.fill",
        "fanblades.fill",
        "car.fill"
    ]
    
    enum Metric {
        static let collectionViewHeight = 350.0
        static let cellWidth = UIScreen.main.bounds.width
    }
    
    private lazy var carouselCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: Metric.cellWidth, height: Metric.collectionViewHeight)
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.isScrollEnabled = true
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(
            CollectionViewCell.self,
            forCellWithReuseIdentifier: CollectionViewCell.identifier
        )
        return collectionView
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl(frame: .zero)
        pageControl.currentPageIndicatorTintColor = .systemGreen
        pageControl.pageIndicatorTintColor = .red
        pageControl.backgroundStyle = .minimal
        pageControl.numberOfPages = 4
        pageControl.isUserInteractionEnabled = false
        return pageControl
    }()

    var timer: Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // as is: 1 2 3
        // to be: 3 1 2 3 1
        items.insert(items[items.count - 1], at: 0)
        items.append(items[1])
        
        view.addSubview(carouselCollectionView)
        view.addSubview(pageControl)
        
        carouselCollectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(Metric.collectionViewHeight)
        }
        
        pageControl.snp.makeConstraints {
            $0.bottom.equalTo(carouselCollectionView.snp.bottom).offset(-10)
            $0.centerX.equalToSuperview()
        }
        
        activateTimer()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        carouselCollectionView.setContentOffset(
            .init(
                x: Metric.cellWidth,
                y: carouselCollectionView.contentOffset.y
            ),
            animated: false
        )
    }

    private func invalidateTimer() {
        timer?.invalidate()
    }
    
    private func activateTimer() {
        timer = Timer.scheduledTimer(
            timeInterval: 2,
            target: self,
            selector: #selector(timerCallBack),
            userInfo: nil,
            repeats: true
        )
    }
    
    @objc func timerCallBack() {
        let visibleItem = carouselCollectionView.indexPathsForVisibleItems[0].item
        let nextItem = visibleItem + 1
        let initialItemCounts = items.count - 2
        
        carouselCollectionView.scrollToItem(
            at: IndexPath(item: nextItem, section: 0),
            at: .centeredHorizontally,
            animated: true
        )
        
        if visibleItem == initialItemCounts {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.carouselCollectionView.scrollToItem(
                    at: IndexPath(item: 1, section: 0),
                    at: .centeredHorizontally,
                    animated: false
                )
            }
        }
        pageControl.currentPage = visibleItem % initialItemCounts
    }
}

extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: CollectionViewCell.identifier,
            for: indexPath
        ) as? CollectionViewCell else {
            return UICollectionViewCell()
        }
        let name = items[indexPath.item]
        cell.config(name: name)
        return cell
    }
}

extension ViewController: UICollectionViewDelegate {
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        invalidateTimer()
        activateTimer()
        var page = Int(scrollView.contentOffset.x / scrollView.frame.maxX) - 1
        if page == items.count - 2 {
            page = 0
        }
        if page == -1 {
            page = items.count - 3
        }
        pageControl.currentPage = page
        
        let count = items.count
        
        if scrollView.contentOffset.x == 0 {
            scrollView.setContentOffset(
                .init(
                    x: Metric.cellWidth * Double(count - 2),
                    y: scrollView.contentOffset.y
                ),
                animated: false
            )
        }
        if scrollView.contentOffset.x == Double(count - 1) * Metric.cellWidth {
            scrollView.setContentOffset(
                .init(
                    x: Metric.cellWidth,
                    y: scrollView.contentOffset.y
                ),
                animated: false
            )
        }
    }
}
