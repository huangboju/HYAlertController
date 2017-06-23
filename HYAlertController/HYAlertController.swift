//
//  HYAlertController.swift
//  Quick-Start-iOS
//
//  Created by work on 2016/10/25.
//  Copyright © 2016年 hyyy. All rights reserved.
//

import UIKit

public enum HYAlertControllerStyle: Int {

    case actionSheet

    case shareSheet

    case alert
}

// MARK: - Class
public class HYAlertController: UIViewController {

    var alertStyle = HYAlertControllerStyle.alert

    fileprivate var alertTitle: String?
    fileprivate var alertMessage: String?
    fileprivate var actionArray: [[HYAlertAction]] = []
    fileprivate var cancelAction: HYAlertAction?

    var pickerView: HYPickerView!

    lazy var dimBackgroundView: UIControl = {
        let control = UIControl(frame: CGRect(x: 0,
                                              y: 0,
                                              width: HYConstants.ScreenWidth,
                                              height: HYConstants.ScreenHeight))
        control.backgroundColor = UIColor(white: 0, alpha: HYConstants.dimBackgroundAlpha)
        control.addTarget(self, action: #selector(clickedBgViewHandler), for: .touchDown)
        return control
    }()

    convenience init(title: String?, message: String?, style: HYAlertControllerStyle) {
        self.init()

        alertStyle = style
        alertTitle = title
        alertMessage = message

        // 自定义转场动画
        transitioningDelegate = self
        modalPresentationStyle = .custom
        modalTransitionStyle = .coverVertical

        pickerView = HYPickerView.pickerView(for: alertStyle)
        pickerView.delegate = self
        view.addSubview(pickerView)
    }
}

// MARK: - LifeCycle
extension HYAlertController {
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        view.addSubview(dimBackgroundView)
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let cancelHight = cancelAction != nil ? HYAlertCell.cellHeight + 10 : 0
        let tableHeight = HYAlertCell.cellHeight * CGFloat(actionArray.first?.count ?? 0) + cancelHight
        if alertStyle == .shareSheet {
            let tableHeight = HYShareTableViewCell.cellHeight * CGFloat(actionArray.count) + cancelHight
            let newTableFrame = CGRect(x: 0,
                                       y: HYConstants.ScreenHeight - tableHeight,
                                       width: HYConstants.ScreenWidth,
                                       height: tableHeight)
            pickerView.frame = newTableFrame
        } else if alertStyle == .actionSheet {
            let newTableFrame = CGRect(x: 0,
                                       y: HYConstants.ScreenHeight - tableHeight,
                                       width: HYConstants.ScreenWidth,
                                       height: tableHeight)
            pickerView.frame = newTableFrame
        } else {
            let newTableFrame = CGRect(x: 0,
                                       y: 0,
                                       width: HYConstants.ScreenWidth - HYConstants.alertSpec,
                                       height: tableHeight)
            pickerView.frame = newTableFrame
            pickerView.center = view.center
        }
        pickerView.set(title: alertTitle, message: alertMessage)
    }
}

// MARK: - Public Methods
extension HYAlertController {
    open func add(_ action: HYAlertAction) {
        if action.style == .cancel {
            cancelAction = action
        } else {
            if actionArray.isEmpty {
                actionArray.append([action])
            } else {
                actionArray[0].append(action)
            }
        }
        (pickerView as? DataPresenter)?.refresh(actionArray[0], cancelAction: cancelAction)
    }

    /// 添加必须是元素为HYAlertAction的数组，调用几次该方法，分享显示几行
    open func addShare(_ actions: [HYAlertAction]) {
        actionArray += [actions]

        (pickerView as? HYShareView)?.refresh(actionArray)
    }
}

// MARK: - HYSheetViewDelegate
extension HYAlertController: HYActionDelegate {
    func clickItemHandler() {
        dismiss()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension HYAlertController: UIViewControllerTransitioningDelegate {
    public func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HYAlertPresentSlideUp()
    }

    public func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return HYAlertDismissSlideDown()
    }
}

// MARK: - Events
extension HYAlertController {

    /// 点击背景事件
    @objc fileprivate func clickedBgViewHandler() {
        dismiss()
    }
}

// MARK: - Private Methods
extension HYAlertController {
    // 取消视图显示和控制器加载
    fileprivate func dismiss() {
        actionArray.removeAll()
        cancelAction = nil

        dismiss(animated: true, completion: nil)
    }
}
