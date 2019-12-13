//
//  String.swift
//  Macaque
//
//  Created by Kamil Wasąg on 28/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

extension String {
    /// Method that draw string in context in single line.
    /// - Parameters:
    ///   - context: context to draw string
    ///   - point: top left corner of frame of drawn string
    ///   - attributes: A dictionary of text attributes to be applied to the string.
    func draw(inContext context:CGContext, atPoint point:CGPoint, withAttributes attributes:[NSAttributedString.Key: Any]){
        UIGraphicsPushContext(context)
        context.saveGState()
        defer {
            context.restoreGState()
            UIGraphicsPopContext()
        }
        context.translateBy(x: point.x, y: point.y)
        context.scaleBy(x: 1, y: -1)
        (self as NSString).draw(at: .zero, withAttributes: attributes)
    }
}
