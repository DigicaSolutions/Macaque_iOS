//
//  InputDataProvider.swift
//  Macaque
//
//  Created by Kamil Wasąg on 22/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation


/// Protocol for Input Data Providers
///
/// Objects implementing this protocol are responsible for taking data from user and translating it
/// to form accepted by the model. There are available few implementations of
/// InputDataProvider, more can be easily implemented.
public protocol InputDataProvider { 
    /// Method which takes data provided by the user to Input Data Provider and returns it to
    /// Predictor in form accepted by the model.
    /// - Parameter shapes: array of shapes used in process of generating data for Predictor. It is automatically passed by Predictor
    /// - Returns: prepared array of data used as input for model.  If single input is expected by the model then single element array should be returned.
    /// - Throws: Error if any occurred during data transform
    func data(forShapes shapes: [[Int]]) throws -> [Data]
}
