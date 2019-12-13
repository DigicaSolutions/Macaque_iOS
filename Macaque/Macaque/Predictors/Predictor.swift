//
//  Predictor.swift
//  Macaque
//
//  Created by Kamil Wasąg on 10/12/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation

/// Errors that can be thrown during operations in DataProviders
public enum PredictorError: Error {
    ///Error will be thrown if there is no file under given path to model
    case modelFileNotFound
    /// The error will be thrown when trying to run more than one prediction
    case predictionInProgress
}

/// Protocol used for predictor class.
///
/// Class that will be used by Macaque object to perform prediction needs to implement this protocol.
public protocol Predictor {
    /// This computed property return array of shapes of input data used in predictions
    var inputShapes:[[Int]] { get }
    
    
    /// Method that invokes prediction.
    ///
    /// This method will called by Macaque object to perform prediction.
    /// - Parameter inputData: Bytes each object from this array will be passed to input tenors for prediction
    /// - Warning: Order of input data array is important
    /// - Returns: Raw bytes and shape predicted data
    /// - Throws: Method re-throws errors from InputDataProvider and OutputDataProvider or AI library
    /// - Warning:This operation, depending on model, might be very expensive. It is highly recommended to perform this operation in background thread.
    func predict(onInputData inputData: [Data]) throws -> [(data:Data, shape:[Int])]
}
