//
//  DetectionResult.swift
//  Macaque
//
//  Created by Kamil Wasąg on 25/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry


/// Struct that holds result of detection
public struct DetectionResult{
    /// Rect with bounding box of detected object.
    /// - Warning:
    ///     Detectors return bounding box in range from 0 to 1.
    ///     To get actual size on image multiply coordinates by size of image
    public let boundingBox:CGRect
    /// Class of detected object.
    ///
    /// Number from 0 to `n` where `n` is total number of classes that can be detected by model.
    public let objectClass:Int
    /// Number from 0 to 1 that tells how certain model was about this prediction
    public let score:Float
    
    /// Method that adjust predicted bounding box to given size.
    ///
    /// SSD models returns coordinates normalised in range from  0 to 1.
    /// Method returning CGRect representation of the BoundBox, with absolute coordinates calculated
    /// with use of provided size.
    /// - Parameter size: size to which normalised coordinates should be adjusted
    /// - Returns: Rect with absolute coordinates calculated for given size
    public func scaleBoundingBox(toSize size:CGSize) -> CGRect {
        return CGRect(x: self.boundingBox.origin.x*size.width,
                      y: self.boundingBox.origin.y*size.height,
                      width: self.boundingBox.size.width*size.width,
                      height: self.boundingBox.size.height*size.height)
    }
}
