//
//  Detection4OutputsBoundingBoxesDataProvider.swift
//  Macaque
//
//  Created by Kamil Wasąg on 22/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

/// Input data provider that convert prediction results to bounding boxes.
///
/// Output Data Provider for Object Detectors which have 4 default output tensors (locations, classes, scores and number of detections) and are returning bounding boxes
public class Detection4OutputsBoundingBoxesDataProvider:OutputDataProvider {
    
    ///The property where, for future use, Predictor will assign data received in prediction.
    public var data:[(data:Data, shape:[Int])]?
    
    /// Empty init just to make it public to make it possible to invoke class outside of framework.
    public init(){}
    
    /// The method that convert data stored in `self.data` to DetectionResult.
    ///
    /// Method convert data from prediction to arrays of `Float32` and then create result array of `DetectionResult`.
    /// - Warning: This method will work only with models that as a output result gives locations, classes, scores and number of detections i this order, otherwise will crash
    /// - Parameter threshold: Method will return bounding boxes that have score result over value of given `threshold`. Default value is 0.5.
    ///  Threshold should be in range from 0 to 1, otherwise 0.5 is used as threshold.
    /// - Returns:
    ///     Array with DetectionResults. Values of coordinates from bounding boxes are in range form 0 to 1. Multiply coordinates from result bounding boxes by size of image to get proper rects.
    ///
    ///         let imageSize = image.size
    ///         let results = outputDataProvider.getResults()
    ///         let properBB = CGRectZero
    ///         properBB.origin.x = results[0].origin.x*imageSize.width
    ///         properBB.origin.y = results[0].origin.y*imageSize.height
    ///         properBB.size.width = results[0].size.width*imageSize.width
    ///         properBB.size.height = results[0].size.height*imageSize.height
    ///
    public func getResults(withThreshold threshold:Float = 0.5) throws -> [DetectionResult] {
        guard let dataToParse = self.data else {
            throw DataProviderError.dataIsNotAvailable
        }
        let thresholdToUse =  0...1 ~= threshold ? threshold : 0.5

        let boxesToSort = dataToParse[0].data.withUnsafeBytes{[Float32]($0.bindMemory(to: Float32.self)) }
        let classes = dataToParse[1].data.withUnsafeBytes{[Float32]($0.bindMemory(to: Float32.self))}
        let scores = dataToParse[2].data.withUnsafeBytes{[Float32]($0.bindMemory(to: Float32.self))}
        let count = Int(dataToParse[3].data.withUnsafeBytes{[Float32]($0.bindMemory(to: Float32.self))}.first ?? 0)
        
        var boxes = [DetectionResult]()
        for i in 0..<count where scores[i] >= thresholdToUse{
            var rect: CGRect = CGRect.zero
            rect.origin.y = CGFloat(boxesToSort[4*i])
            rect.origin.x = CGFloat(boxesToSort[4*i+1])
            rect.size.height = CGFloat(boxesToSort[4*i+2]) - rect.origin.y
            rect.size.width = CGFloat(boxesToSort[4*i+3]) - rect.origin.x
            boxes.append(DetectionResult(boundingBox: rect,
                                           objectClass: Int(classes[i]),
                                           score: scores[i]))
            
        }
        return boxes
    }
}
