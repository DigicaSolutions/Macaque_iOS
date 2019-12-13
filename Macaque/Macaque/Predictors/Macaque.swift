//
//  Macaque.swift
//  Macaque
//
//  Created by Kamil Wasąg on 15/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o.
//

import Foundation
import TensorFlowLite

private struct PredictionStatus {
    static var predictionInProgress:Bool = false
}

/// The class is responsible for handling prediction.
///
/// This is the main class of library. It is used for making predictions based on data read from
/// Input Data Provider, with use of Predictor and storing results in Output Data Provider.
/// To create a Macaque object you need 4 things:
///    1. The model that is on your device,
///    2. Proper predictor to handle your model. This type of class needs to implement `Predictor` protocol.
///    3. an object that will transform your data in a way that your model is able to digest. This type of class needs to implement the `InputDataProvider` protocol.
///    In this framework, we provide several standard `InputDataProvider` classes,
///    4. an object that will be able to transform data from prediction to an object that is usable by your app. This kind of class needs to implement the `OutputDataProvider` protocol.
///    In this framework, we provide several standard `OutputDataProviders` classes.
///
/// To make a prediction it is needed just 7 lines of code:
///
///            // Init TensorflowLitePredictor
///            guard let predictor = try? TensorflowLitePredictor(modelName: "detect", modelExtension: "tflite", inBundle: Bundle.main) else {
///                 return nil
///            }
///            // Standard provider that converts UIImage to data
///            let inputDataProvider = UIImageToRGBDataProvider<UInt8>()
///            // Standard provider that transform data from prediction to BoundingBoxes
///            let outputDataProvider = Detection4OutputsBoundingBoxesDataProvider()
///
///            let macaque = try? Macaque(withPredictor: predictor,
///                                         withInputDataProvider: VideoStreamInputDataProvider<UInt8>(),
///                                         withOutputDataProvider: Detection4OutputsBoundingBoxesDataProvider())
///            inputDataProvider.image = UIImage(named:"ImageForDetection")
///            try? macaque?.predict()
///            let results = outputDataProvider.getResults()
///            // ... do something with results ...
///
///    - Warning:
///               Performing the operation of prediction is very expensive. It is highly recommended to run a `predict()` method in a background thread.
public class Macaque<K:Predictor, T:InputDataProvider, U:OutputDataProvider> {
    
    
    /// Indicates if prediction is in progress.
    public var predictionInProgress:Bool {
        return PredictionStatus.predictionInProgress
    }
    
    /// An object that will translate bytes from prediction to object that used by the application. It needs to implement `OutputDataProvider` protocol
    public var outputDataProvider:U
    
    /// An object that will transform your data in a way that your model is able to digest. This type of class needs to implement the `InputDataProvider` protocol.
    public let inputDataProvider:T
    /// An object that holds the model. It also has all information how to do prediction this model.
    public let predictor:K
    
    
    /// Initialiser of Macaque. This initialiser is used to set predictor, input and output data providers
    /// - Parameters:
    ///   - predictor: Instance of object that implements `Predictor` protocol. It will be used to perform prediction.
    ///   - inputDataProvider: instance of object implementing InputDataProvider protocol. Data taken from this class will be used in prediction.
    ///   - outputDataProvider: instance of object implementing OutputDataProvider protocol. Bytes from prediction will be passed to this object for future use.
    public init(withPredictor predictor:K, withInputDataProvider inputDataProvider:T, withOutputDataProvider outputDataProvider:U) {
        self.predictor = predictor
        self.inputDataProvider = inputDataProvider
        self.outputDataProvider = outputDataProvider
    }
    /// The method that does predictions on the loaded model.
    ///
    /// Perform prediction on data passed by `InputDataProvider`. When prediction finished, results are passed to OutputDataProvider.
    ///
    /// - Warning:
    ///     1. Only one prediction can be performed at the time.
    ///     2. Running this method, depending on the model, might be very expensive. It is highly recommended to call it in a background thread.
    /// - Throws:
    ///     1. `PredictorError.predictionInProgress` - throws if prediction is in progress
    ///     2. Method re-throws errors from InputDataProvider and OutputDataProvider
    public func predict() throws {
        if self.predictionInProgress {
            throw PredictorError.predictionInProgress
        }
        PredictionStatus.predictionInProgress = true
        defer {
            PredictionStatus.predictionInProgress = false
        }
        let inputData = try inputDataProvider.data(forShapes: self.predictor.inputShapes)
        self.outputDataProvider.data = try self.predictor.predict(onInputData: inputData)
    }
}
