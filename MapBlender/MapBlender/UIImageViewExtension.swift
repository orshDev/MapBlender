//
//  UIImageViewExtension.swift
//  MapBlender
//
//  Created by MacOS on 7/29/17.
//  Copyright © 2017 MacOS. All rights reserved.
//

import Foundation
import UIKit

extension UIImage{

    
    func roundedImageWithBorder(width: CGFloat, color: UIColor) -> UIImage? {
        let square = CGSize(width: min(size.width, size.height) + width * 2, height: min(size.width, size.height) + width * 2)
        let imageView = UIImageView(frame: CGRect(origin: CGPoint(x: 0, y: 0), size: square))
        imageView.contentMode = .center
        imageView.image = self
        imageView.layer.cornerRadius = square.width/2
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = width
        imageView.layer.borderColor = color.cgColor
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
//     func cropAsCircleWithBorder(borderColor : UIColor, strokeWidth: CGFloat)
//    {
//        var radius = min(self.bounds.width, self.bounds.height)
//        var drawingRect : CGRect = self.bounds
//        drawingRect.size.width = radius
//        drawingRect.origin.x = (self.bounds.size.width - radius) / 2
//        drawingRect.size.height = radius
//        drawingRect.origin.y = (self.bounds.size.height - radius) / 2
//        
//        radius /= 2
//        
//        var path = UIBezierPath(roundedRect: drawingRect.insetBy(dx: strokeWidth/2, dy: strokeWidth/2), cornerRadius: radius)
//        let border = CAShapeLayer()
//        border.fillColor = UIColor.clear.cgColor
//        border.path = path.cgPath
//        border.strokeColor = borderColor.cgColor
//        border.lineWidth = strokeWidth
//        self.layer.addSublayer(border)
//        
//        path = UIBezierPath(roundedRect: drawingRect, cornerRadius: radius)
//        let mask = CAShapeLayer()
//        mask.path = path.cgPath
//        self.layer.mask = mask
//    }

}
