//
//  HYShareTableViewCell.swift
//  Quick-Start-iOS (含有UICollectionView的UITableViewCell)
//
//  Created by work on 2016/11/3.
//  Copyright © 2016年 hyyy. All rights reserved.
//

import UIKit

class HYShareTableViewCell: UITableViewCell {

    lazy var collectionView: UICollectionView = {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.itemSize = HYShareCollectionCell.cellSize
        collectionLayout.scrollDirection = .horizontal
        let collection = UICollectionView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 0), collectionViewLayout: collectionLayout)
        collection.delegate = self
        collection.dataSource = self
        collection.register(HYShareCollectionCell.self, forCellWithReuseIdentifier: HYShareCollectionCell.ID)
        collection.backgroundColor = UIColor.white
        collection.showsHorizontalScrollIndicator = false
        return collection
    }()

    var actions: [HYAlertAction]? {
        didSet {
            if actions != nil {
                collectionView.reloadData()
            }
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = UIColor.white
        contentView.addSubview(collectionView)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.textAlignment = .center
        textLabel?.center.x = center.x
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        collectionView.frame = contentView.bounds
    }
}

extension HYShareTableViewCell: UICollectionViewDataSource {
    func collectionView(_: UICollectionView, numberOfItemsInSection _: Int) -> Int {
        return actions?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: HYShareCollectionCell.ID, for: indexPath)
    }
}

extension HYShareTableViewCell: UICollectionViewDelegate {

    func collectionView(_: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.backgroundColor = .white

        let backgroundView = UIView(frame: cell.frame)
        backgroundView.backgroundColor = UIColor(white: 0.9, alpha: 1)
        cell.selectedBackgroundView = backgroundView
        (cell as? HYShareCollectionCell)?.action = actions?[indexPath.row]
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        cell?.router(with: EventName.didSelectItem, userInfo: nil)
        collectionView.deselectItem(at: indexPath, animated: true)
        if let action = actions?[indexPath.row] {
            action.myHandler(action)
        }
    }
}

// MARK: - Class Methods
extension HYShareTableViewCell {

    class var cellHeight: CGFloat {
        return HYConstants.shareItemHeight + HYConstants.shareItemPadding * 2
    }
}
