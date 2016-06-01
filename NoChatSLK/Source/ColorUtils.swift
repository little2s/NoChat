//
//  ColorUtils.swift
//  NoChatTG
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import Foundation

public func ntg_color(rgb rgb: Int, alpha: CGFloat = 1.0) -> UIColor {
    return UIColor(
        red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
        green: CGFloat((rgb & 0xFF00) >> 8) / 255.0,
        blue: CGFloat((rgb & 0xFF)) / 255.0,
        alpha: alpha
    )
}