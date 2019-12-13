//
//  CALayer.swift
//  Macaque
//
//  Created by Kamil Wasąg on 27/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import QuartzCore.CALayer
import UIKit.UIBezierPath

public extension CALayer {
    
    /// Method add BoundingBoxLayer for each of element given in `boxes` parameter.
    ///
    /// - Parameters:
    ///   - boxes: Array of detection results
    ///   - boxAreScaled: if true, bounding boxes coordinates and sizes will be adjusted to the size of the layer
    func draw(boundingBoxes boxes:[DetectionResult], boxAreScaled:Bool = true){
        self.isOpaque = true
        if let sublayers = self.sublayers {
            for case let layer as CAShapeLayer in sublayers {
                CATransaction.begin()
                CATransaction.setCompletionBlock {
                    layer.removeFromSuperlayer()
                }
                let animation = CABasicAnimation(keyPath: "opacity")
                animation.fromValue = 1.0
                animation.toValue = 0.0
                animation.duration = 0.01
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = true
                layer.add(animation, forKey: "Fade")
                CATransaction.commit()
            }
        }
        for box in boxes {
            let layer = CAShapeLayer()
            let rectToDraw = boxAreScaled ? CGRect(x: box.boundingBox.origin.x*self.bounds.size.width,
                                                   y: box.boundingBox.origin.y*self.bounds.size.height,
                                                   width: box.boundingBox.size.width*self.bounds.size.width,
                                                   height: box.boundingBox.size.height*self.bounds.size.height) : box.boundingBox
            layer.path = UIBezierPath(roundedRect: rectToDraw,
                                      cornerRadius: 4.0).cgPath
            layer.lineWidth = 2.0
            layer.isOpaque = true
            layer.strokeColor = UIColor.red.cgColor
            layer.fillColor = UIColor.clear.cgColor
            self.addSublayer(layer)
        }
    }
}
