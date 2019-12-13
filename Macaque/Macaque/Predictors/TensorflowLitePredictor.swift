//
//  TensorflowLitePredictor.swift
//  Macaque
//
//  Created by Kamil Wasąg on 10/12/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation
import TensorFlowLite

/// Class used to do prediction on TensorfloLite models
public class TensorflowLitePredictor:Predictor {
    private let interpreter:Interpreter;
    
    
    /// This computed property return array of shapes of input data used in prediction
    public var inputShapes:[[Int]] {
        var shapes = [[Int]]()
        for i in 0..<self.interpreter.inputTensorCount {
            shapes.append((try? self.interpreter.input(at: i).shape.dimensions) ?? [Int]())
        }
        return shapes
    }
    /// Creates a predictor using path to model file.
    ///
    /// Checks if model file exists - if not throw exception.
    /// - Parameters:
    ///   - path: Path to file with model.
    ///   - threadsNo: Number of threads used during prediction. If `nil` or less than 1 passed, Predictor will decide the number of threads.
    /// - Throws:
    ///     1. `PredictorError.modelFileNotFound` - if the model file is not found,
    ///     2. `InterpreterError.failedToCreateInterpreter` - if cannot create the instance of the model from file or the model file is corrupted.
    public init(modelPath path:String, threadsNo:Int? = nil) throws{
        guard FileManager.default.fileExists(atPath: path) else {
            throw PredictorError.modelFileNotFound
        }
        
        var options = InterpreterOptions()
        options.threadCount=threadsNo ?? 0 > 0 ? threadsNo : nil
        
        self.interpreter = try Interpreter(modelPath: path, options: options)
        try self.interpreter.allocateTensors()
    }
    
    /// Creates a predictor using model name and extension.
    ///
    /// Checks if model file exists in given bundle if not throw exception.
    /// - Parameters:
    ///   - name: String with name of model file.
    ///   - modelExtension: String with extension on model file.
    ///   - bundle: bundle to search for model file.
    ///   - threadsNo: Number of threads used during prediction. If `nil` or less than 1 passed  Predictor will decide the number of threads.
    /// - Throws:
    ///     1. `PredictorError.modelFileNotFound` - if the model file is not found,
    ///     2. `InterpreterError.failedToCreateInterpreter` - if cannot create the instance of the model from file or the model file is corrupted.
    public convenience init(modelName name:String, modelExtension: String, inBundle bundle:Bundle, threadsNo:Int? = 1) throws {
        guard let modelPath = Bundle.main.path(forResource: name, ofType: modelExtension) else {
            throw PredictorError.modelFileNotFound
        }
        try self.init(modelPath: modelPath, threadsNo: threadsNo)
    }
    
    
    /// Method that invokes prediction.
    ///
    /// - Parameter inputData: Bytes each object from this array will be passed to input tenors for prediction
    /// - Warning: Order of input data array is important
    /// - Returns: Raw bytes and shape predicted data
    public func predict(onInputData inputData: [Data]) throws -> [(data:Data, shape:[Int])]  {
        for i in 0..<self.interpreter.inputTensorCount {
            try self.interpreter.copy(inputData[i], toInputAt: i)
        }
        
        try self.interpreter.invoke()
        
        var dataFromInterpreter = [(data:Data, shape:[Int])]()
        for i in 0..<self.interpreter.outputTensorCount {
            let outputTensor = try self.interpreter.output(at: i)
            dataFromInterpreter.append((outputTensor.data, outputTensor.shape.dimensions))
        }
        
        return dataFromInterpreter
    }
}
