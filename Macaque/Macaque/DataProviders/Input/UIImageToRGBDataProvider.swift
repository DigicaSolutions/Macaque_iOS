//
//  UIImageToRGBDataProvider.swift
//  Macaque
//
//  Created by Kamil Wasąg on 21/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import UIKit
import TensorFlowLite

///Errors that can be thrown during performing operations in UIImageToRGBDataProvider
public enum UIImageToRGBDataProviderError:Error {
    /// Error thrown when UIImageToRGBDataProvider could not get bytes from image.
    case cantGetImageRawData
}

/// Input Data Provider converting UIImage to Data
///
/// The object of this class takes UIImage as input from user and
/// provides a single output of RGB Data of the type given in generic type to the Predictor.
///
///     let inputDataProvider = UIImageToRGBDataProvider<UInt8>()
///     //now data will be mapped to UInt8
public class UIImageToRGBDataProvider<T>:InputDataProvider {

    /// Image used in prediction.
    ///
    /// This image will be converted by method `data(forShapes shapes: [[Int]]) throws -> [Data] ` to format that can be used in prediction.
    /// - Warning:
    ///     Data from this property are used in `Predictor.predict()` or `data(forShapes shapes: [[Int]]) throws -> [Data]` methods.
    ///     If `nil`, mentioned methods throws error.
    public var image:UIImage?
    /// Empty init just to make it public to make it possible to invoke class outside of framework.
    public init(){ }
    
    /// The method that converts the image into data for prediction.
    ///
    /// At the beginning, the method will take the image from `self.image` and resize it to size given by Predictor (this size is taken from model input).
    /// Then `n` first channels of the image will be returned (number of channels is taken from model input).
    /// For e.g. if the model supports only 2 channels (last value in shapes parameter) then if the image is in RGBA colorspace, channels R and G will be returned.
    /// Before return data is also mapped to type given in type given as Generalised parameter during class initialization.
    ///
    /// - Parameter shapes:
    ///     shape of input of model. It is used to resize UIImage and select supported channels.
    /// - Returns:
    ///     One element Array with Data transferred from UIImage to data
    /// - Throws:
    ///     1. DataProviderError.dataIsNotAvailable -> if `self.image` is nil
    ///     2. ImageError.cantGetImageRawData -> if can't retrieve `cgImage` property form image
    ///     3. UIImageToRGBDataProviderError.unsupportedNumbersOfChanels -> if the number of channels required by model input is greater than the number of channels available in the image
    ///     4. DataProviderError.unsupportedData -> if type of given `T` is not supported
    public func data(forShapes shapes: [[Int]]) throws -> [Data] {
        if shapes[0][3] <= 1 {
            return [Data]()
        }
        guard let _ = self.image else{
            throw DataProviderError.dataIsNotAvailable
        }
        let shape = shapes[0]
        let inputTensorSize = CGSize(width: shape[1], height: shape[2])

        guard let cgImage = self.image?.cgImage,
              let imageData = self.image?.resizeAndGetData(toSize: inputTensorSize) else {
            throw UIImageToRGBDataProviderError.cantGetImageRawData
        }

        let componentsNo = cgImage.bitsPerPixel/cgImage.bitsPerComponent
        guard  shape[3] <= componentsNo else {
            throw DataProviderError.unsupportedNumbersOfChannels
        }
        var rgbData = [UInt8]()
        
        for y in 0..<Int(inputTensorSize.height) {
            for x in 0..<Int(inputTensorSize.width) {
                for i in 0..<shape[3] {
                    let byteIndex = x*componentsNo+i+Int(inputTensorSize.width)*componentsNo*y
                    rgbData.append(imageData[byteIndex])
                }
            }
        }
        switch T.self {
        case is UInt8.Type:
            return [Data(rgbData)]
        default:
            throw DataProviderError.unsupportedData
        }
        
    }
}
