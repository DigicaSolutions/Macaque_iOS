//
//  VideoStreamInputDataProvider.swift
//  Macaque
//
//  Created by Kamil Wasąg on 26/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import AVFoundation
/// Input Data Provider converting CVImageBuffer from camera stream to Data
///
/// Object of this class takes CVImageBuffer as input from user and
/// provides single output of RGB Data of type given in generic type to the Predictor.
///
///     let inputDataProvider = VideoStreamInputDataProvider<UInt8>()
///     //now data will be mapped to UInt8
public class VideoStreamInputDataProvider<T>:InputDataProvider {
    /// Empty init just to make it public to make it possible to invoke class outside of framework.
    public init(){}
    /// Buffer used in prediction.
    ///
    /// This buffer will be converted by method `data(forShapes shapes: [[Int]]) throws -> [Data] ` to format that can be used in prediction.
    /// - Warning:
    ///     Data from this property are used in `Predictor.predict()` or `data(forShapes shapes: [[Int]]) throws -> [Data]` methods.
    ///     If `nil`, mentioned methods throws error.
    public var pixelBuffer:CVImageBuffer?
    
    /// The method that converts the image into data for prediction.
    ///
    /// At the beginning, the method will take an image from `self.image` and resize it to size given by Predictor (this size is taken from model input).
    /// Then RGB first channels of the image will be returned (number of channels is taken from model input).
    /// Before return data is also mapped to type given in type given as Generalised parameter during class initialization.
    ///
    /// - Parameter shapes:
    ///     shape of input of model. It is used to resize UIImage and select supported channels. 
    /// - Returns:
    ///     One element Array with Data transferred from UIImage to data
    /// - Throws:
    ///     1. DataProviderError.dataIsNotAvailable -> if `self.pixelBuffer` is nil
    ///     2. DataProviderError.cantGetDataAddress -> if can't retrieve `UnsafeMutableRawPointer` property form buffer
    ///     3. UIImageToRGBDataProviderError.unsupportedNumbersOfChanels -> if the number of channels required by model input is greater than the number of channels available in the buffer
    ///     4. DataProviderError.unsupportedData -> if type of given `T` is not supported
    /// - Warning:
    ///     For now only BGRA colourspace is supported
    public func data(forShapes shapes: [[Int]]) throws -> [Data] {
        if shapes[0][3] <= 1 {
            return [Data]()
        }
        let frameSize = CGSize(width: shapes[0][1], height: shapes[0][2])
        guard let scaledBuffer = self.pixelBuffer?.resize(toSize: frameSize) else {
            throw DataProviderError.cantResizeData
        }
        
        CVPixelBufferLockBaseAddress(scaledBuffer, .readOnly)
        guard let rawData = CVPixelBufferGetBaseAddress(scaledBuffer) else {
            throw DataProviderError.cantGetDataAddress
        }
        let componentsNo = CVPixelBufferGetBytesPerRow(scaledBuffer)/Int(CVPixelBufferGetWidth(scaledBuffer))
        guard shapes[0][3] <= componentsNo else {
            throw DataProviderError.unsupportedNumbersOfChannels
        }
        let data = Data(bytesNoCopy: rawData,
                        count: CVPixelBufferGetDataSize(scaledBuffer),
                        deallocator: .none)
        var rgbData = [UInt8]()
        for y in 0..<Int(frameSize.height){
            for x in 0..<Int(frameSize.width) {
                let byteIndex = x*componentsNo+Int(frameSize.width)*componentsNo*y
                rgbData.append(data[byteIndex+2])
                rgbData.append(data[byteIndex+1])
                rgbData.append(data[byteIndex])
            }
        }
        CVPixelBufferUnlockBaseAddress(scaledBuffer, .readOnly)
        switch T.self {
        case is UInt8.Type:
            return [Data(rgbData)]
        default:
            throw DataProviderError.unsupportedData
        }
    }
}
