//
//  Util.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/24/24.
//

import UIKit

class Utils {
    public static let STATUS_HEIGHT = UIApplication.shared.statusBarFrame.size.height   // 상태바 높이
    
    /**
     # safeAreaTopInset
     - Note: 현재 디바이스의 safeAreaTopInset값 반환
     */
    static func safeAreaTopInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let topPadding = window?.safeAreaInsets.top
            return topPadding ?? Utils.STATUS_HEIGHT
        } else {
            return Utils.STATUS_HEIGHT
        }
    }
    
    /**
     # safeAreaBottomInset
     - Note: 현재 디바이스의 safeAreaBottomInset값 반환
     */
    static func safeAreaBottomInset() -> CGFloat {
        if #available(iOS 11.0, *) {
            let window = UIApplication.shared.keyWindow
            let bottomPadding = window?.safeAreaInsets.bottom
            return bottomPadding ??  0.0
        } else {
            return 0.0
        }
    }
}
