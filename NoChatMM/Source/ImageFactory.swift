//
//  ImageFactory.swift
//  NoChatMM
//
//  Created by little2s on 16/5/17.
//  Copyright © 2016年 little2s. All rights reserved.
//

import UIKit

let imageFactory = ImageFactoryMM()

class ImageFactoryMM {
    func createImage(name: String) -> UIImage? {
        return UIImage(named: name, inBundle: NSBundle(forClass: self.dynamicType), compatibleWithTraitCollection: nil)
    }
}
