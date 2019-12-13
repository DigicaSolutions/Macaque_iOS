//
//  BoundingBoxLayer.swift
//  Macaque
//
//  Created by Kamil Wasąg on 27/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import UIKit
import QuartzCore.CALayer


/// A layer that draws bounding box and corresponding label in given coordinates
public class BoundingBoxLayer:CALayer {
    private let textLayer:CATextLayer
    private let boxLayer:CAShapeLayer
    
    
    /// Initialise a BoundingBoxLayer with given detection result.
    /// - Parameters:
    ///   - box: Single detected object to be drawn
    ///   - size: size to which bounding box should be adjusted
    public init(withBoundingBoxResult box: DetectionResult, scaleTo size:CGSize? = nil) {
        self.textLayer = CATextLayer()
        self.boxLayer = CAShapeLayer()
        super.init()
        self.setup(rect: box.scaleBoundingBox(toSize: size ?? CGSize(width: 1,height: 1)),  label: "\(box.objectClass)")
    }
    
    
    /// The initializer instantiate BoundingBoxLayer from NSCoder
    /// - Parameter coder: object which used to restore BoundingBoxLayer
    public required init?(coder: NSCoder) {
        self.textLayer = CATextLayer()
        self.boxLayer = CAShapeLayer()
        super.init(coder: coder)
    }
    
    
    /// The initializer does a copy of the given layer. If the layer is not BoundingBoxLayer type, the empty BoundingBoxLayer layer will be initialised.
    /// - Parameter layer: layer to copy
    public override init(layer: Any) {
        guard let oldLayer = layer as? BoundingBoxLayer else {
            self.textLayer = CATextLayer()
            self.boxLayer = CAShapeLayer()
            super.init(layer: CALayer())
            return
        }
        self.textLayer = oldLayer.textLayer
        self.boxLayer = oldLayer.boxLayer
        super.init(layer: oldLayer)
    }
    
    private func setup(rect: CGRect, label:String){
        self.textLayer.fontSize = UIFont.smallSystemFontSize
        self.textLayer.font = UIFont.systemFont(ofSize: UIFont.labelFontSize)
        self.textLayer.string = label
        self.textLayer.foregroundColor = UIColor.red.cgColor
        self.textLayer.frame = CGRect(x: 0,y: 0, width: self.textLayer.preferredFrameSize().width, height: self.textLayer.preferredFrameSize().height)
        let rectToDraw = CGRect(x: rect.origin.x,
                                y: rect.origin.y-self.textLayer.frame.size.height,
                                width: max(rect.size.width, self.textLayer.frame.size.width),
                                height: rect.size.height+self.textLayer.frame.size.height)
        self.frame = rectToDraw
        self.boxLayer.frame = CGRect(x: 0,
                                     y: self.textLayer.frame.maxY,
                                     width: bounds.width,
                                     height: bounds.height-self.textLayer.frame.size.height)
        self.isOpaque = true
        self.drawLine(inRect:self.boxLayer.bounds, lineWidth: 4.0)
        self.addSublayer(self.boxLayer)
        self.addSublayer(self.textLayer)
    }
    
    private func drawLine(inRect rect: CGRect, lineWidth:CGFloat){
        self.boxLayer.path = UIBezierPath(roundedRect: rect,
                                          cornerRadius: lineWidth).cgPath
        self.boxLayer.lineWidth = 2.0
        self.boxLayer.strokeColor = UIColor.red.cgColor
        self.boxLayer.fillColor = UIColor.clear.cgColor
    }
    
    
    
    
    /// The current text that is displayed by the layer. Text will be displayed above bounding box.
    @IBInspectable public var text:String? {
        get {
            self.textLayer.string as? String
        }
        set {
            let oldBoxFrame = self.box.origin
            
            self.textLayer.string = newValue
            self.textLayer.frame = CGRect(x: 0,
                                          y: 0,
                                          width: self.textLayer.preferredFrameSize().width,
                                          height: self.textLayer.preferredFrameSize().height)
            
            var boxLayerFrame = self.boxLayer.frame
            boxLayerFrame.origin.y = self.textLayer.frame.maxY
            self.boxLayer.frame = boxLayerFrame
            var newFrame = self.frame
            newFrame.size.height = self.boxLayer.frame.size.height+self.textLayer.frame.height
            newFrame.origin.y = oldBoxFrame.y-self.textLayer.frame.size.height
            self.frame = newFrame
        }
    }
    
    /// The bounding rectangle, which describes the location of drawn bounding box and size in its superview’s coordinate system. Label is always above this rect.
    @IBInspectable public var box:CGRect {
        get{
            return CGRect(origin: CGPoint(x: self.frame.origin.x,
                                          y: self.frame.origin.y+self.boxLayer.frame.origin.y),
                          size: self.boxLayer.frame.size)
        }
        set{
            self.boxLayer.frame = CGRect(origin: CGPoint(x: 0,
                                                         y: self.textLayer.frame.maxY),
                                         size: newValue.size)
            self.drawLine(inRect: self.boxLayer.bounds, lineWidth: 4.0)
            self.frame = CGRect(origin: CGPoint(x: newValue.origin.x,
                                                y: newValue.origin.y-self.textLayer.frame.size.height),
                                size: CGSize(width: max(newValue.size.width, self.textLayer.frame.size.width),
                                             height: self.textLayer.frame.size.height+newValue.size.height))
        }
    }
}
