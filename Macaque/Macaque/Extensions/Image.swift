//
//  Image.swift
//  Macaque
//
//  Created by Kamil Wasąg on 15/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import UIKit
import CoreGraphics

public extension UIImage {
    /// Method use CoreGraphics to resize image.
    ///
    /// - Parameter toSize: size of output UImage
    /// - Returns: new image, or nil if method could not create graphics context or receive image from that context.
    func resize(toSize:CGSize) -> UIImage?{
        return resizeAndGetImageWithData(toSize: toSize).0
    }
    
    /// Method use CoreGraphics to resize image and return Data of that image.
    ///
    /// - Parameter toSize: size of output UImage
    /// - Returns: bytes of scaled image, or nil if method could not create graphics context or receive image from that context.
    func resizeAndGetData(toSize:CGSize) -> Data? {
        return resizeAndGetImageWithData(toSize: toSize).1
    }
    
    /// Method use CoreGraphics to resize image and return Data of that image.
    ///
    /// - Parameter toSize: size of output UImage
    /// - Returns: tuple with resized image and its bytes in Data of scaled image, or nil if method could not create graphics context or receive image from that context.
    func resizeAndGetImageWithData(toSize:CGSize) -> (UIImage?, Data?) {
        return autoreleasepool { () -> (UIImage?, Data?) in
            guard let cgImage = self.cgImage else {
                return (nil, nil)
            }
            let bytePerPixel:CGFloat = CGFloat(cgImage.bitsPerPixel/8)
            let bytesPerRow = toSize.width * bytePerPixel
            let colorspace = cgImage.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!
            guard let context = CGContext(data: nil,
                                          width: Int(toSize.width),
                                          height: Int(toSize.height),
                                          bitsPerComponent: cgImage.bitsPerComponent,
                                          bytesPerRow: Int(bytesPerRow),
                                          space: colorspace,
                                          bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                                            return (nil, nil);
            }

            context.draw(cgImage, in: CGRect(x: 0, y: 0, width: toSize.width, height: toSize.height))
            
            var imageToReturn:UIImage? = nil
            if let imageRef = context.makeImage() {
                imageToReturn = UIImage(cgImage: imageRef)
            }
            
            var dataToReturn:Data? = nil
            if let bytes = context.data {
                dataToReturn = Data(bytes: bytes, count: Int(toSize.height*toSize.width*bytePerPixel))
            }
            return (imageToReturn, dataToReturn)
        }
    }

    /// Method use CoreGraphics to return Data of that image.
    ///
    /// - Returns: bytes in Data of  image, or nil if method could not create graphics context or receive image from that context.
    func getImageData() -> Data?{
        self.resizeAndGetData(toSize: self.size)
    }
    
    /// Method that draw bounding boxes from given array of DetectionResult
    ///
    /// Red bounding boxes with labels with classification classes are drawn on copy of the image.
    ///
    /// - Parameter boxes: Array of DetectionResult to draw on image.
    /// - Returns: New image with with bounding boxes, or nil if could not create context or receive image form it.
    func draw(boundingBoxes boxes:[DetectionResult]) -> UIImage?{
        let size = self.size
        let color = UIColor.red
        
        let textFont = UIFont.systemFont(ofSize: size.width/50)
        let textFontAttributes = [
            NSAttributedString.Key.backgroundColor: color,
            NSAttributedString.Key.font: textFont,
            NSAttributedString.Key.foregroundColor: UIColor.white,
        ]
        guard let cgImage = self.cgImage,
            let colorspace = cgImage.colorSpace,
            let context = CGContext (data: nil,
                                     width: cgImage.width,
                                     height: cgImage.height,
                                     bitsPerComponent: cgImage.bitsPerComponent,
                                     bytesPerRow: cgImage.bytesPerRow,
                                     space: colorspace,
                                     bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        
        context.draw(cgImage, in: CGRect(origin: CGPoint(x: 0,y: 0), size: self.size))
        
        for bbox in boxes {
            var rect = CGRect.zero
            rect.origin.x = bbox.boundingBox.minX*self.size.width
            rect.origin.y = self.size.height - bbox.boundingBox.maxY*self.size.height
            rect.size.width = (bbox.boundingBox.maxX-bbox.boundingBox.minX)*self.size.width
            rect.size.height = (bbox.boundingBox.maxY-bbox.boundingBox.minY)*self.size.height
            
            context.setStrokeColor(color.cgColor)
            context.setLineWidth(size.width*0.002)
            context.stroke(rect)
            let stringToDraw = "\(bbox.objectClass)"
            let stringSize = (stringToDraw as NSString).size(withAttributes: textFontAttributes);
            stringToDraw.draw(inContext: context, atPoint: CGPoint(x: rect.origin.x, y: rect.maxY+stringSize.height), withAttributes: textFontAttributes)
        }
        if let newImage = context.makeImage() {
            return UIImage(cgImage: newImage)
        }
        return nil
    }
}

