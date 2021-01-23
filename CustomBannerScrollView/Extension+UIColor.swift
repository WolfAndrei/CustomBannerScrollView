//
//  Extension+UIColor.swift
//  CustomBannerScrollView
//
//  Created by Andrei Volkau on 14.12.2020.
//

import UIKit
extension UIColor {
    public convenience init(decimalsRed: Int, green: Int, blue: Int, alpha: CGFloat = 1.0) {
        let newRed = CGFloat(decimalsRed)/255
        let newGreen = CGFloat(green)/255
        let newBlue = CGFloat(blue)/255
        self.init(red: newRed, green: newGreen, blue: newBlue, alpha: alpha)
    }
    
    /// Black
    @nonobjc class var commonTextColor: UIColor {
        return UIColor.black
    }
    
    /// White
    @nonobjc class var commonTextReversedColor: UIColor {
        return UIColor.white
    }
    
    /// 213.0.3.1
    @nonobjc class var commonTintColor: UIColor {
        return UIColor(decimalsRed: 213, green: 0, blue: 3)
    }
    
    /// 238.207.207.1
    @nonobjc class var commonTintInactiveColor: UIColor {
        return UIColor(decimalsRed: 238, green: 207, blue: 207)
    }
}
