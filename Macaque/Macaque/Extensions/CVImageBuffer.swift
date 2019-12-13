//
//  CVImageBuffer.swift
//  Macaque
//
//  Created by Kamil Wasąg on 27/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import AVFoundation
import Accelerate

public extension CVImageBuffer {
    /// Method that create resized copy of CVPixelBuffer
    ///
    /// - Parameter toSize: size of the newly created buffer
    /// - Returns: resized copy of buffer or nil, if something went wrong.
    func resize(toSize:CGSize) -> CVPixelBuffer?{
        let bytesPerRowOriginal = CVPixelBufferGetBytesPerRow(self)
        let channels = bytesPerRowOriginal/Int(CVPixelBufferGetWidth(self))
        let bytesPerRowScaled = Int(toSize.width)*channels
        var status:Int = 0
        CVPixelBufferLockBaseAddress(self, .readOnly)
        
        guard let inputBaseAddress = CVPixelBufferGetBaseAddress(self),
              let scaledBytes = malloc(Int(toSize.height*toSize.width)*channels ) else {
          return nil
        }
        
        var inputBuffer = vImage_Buffer(data: inputBaseAddress,
                                        height: vImagePixelCount(CVPixelBufferGetHeight(self)),
                                        width: vImagePixelCount(CVPixelBufferGetWidth(self)),
                                        rowBytes: bytesPerRowOriginal)
        
        var outputBuffer = vImage_Buffer(data: scaledBytes,
                                         height: vImagePixelCount(toSize.height),
                                         width: vImagePixelCount(toSize.width),
                                         rowBytes: bytesPerRowScaled)
        
        status = vImageScale_ARGB8888(&inputBuffer,
                                         &outputBuffer,
                                         nil,
                                         0)
        
        if status != kvImageNoError {
            free(scaledBytes)
            return nil
        }
        
        CVPixelBufferUnlockBaseAddress(self, .readOnly)
        
        var scaledBuffer: CVPixelBuffer?
        status = Int(CVPixelBufferCreateWithBytes(nil,
                                                  Int(toSize.width),
                                                  Int(toSize.height),
                                                  CVPixelBufferGetPixelFormatType(self),
                                                  scaledBytes,
                                                  bytesPerRowScaled,
                                                  { _ , pointer in
                                                    if let pointerToFree = pointer {
                                                        free(UnsafeMutableRawPointer(mutating: pointerToFree))
                                                    }
                                                  }, nil, nil, &scaledBuffer))
        
        if status != kCVReturnSuccess {
            free(scaledBytes)
            return nil
        }
        
        return scaledBuffer
    }
}
