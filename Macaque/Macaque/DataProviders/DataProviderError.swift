//
//  DataProviderError.swift
//  Macaque
//
//  Created by Kamil Wasąg on 28/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation


/// Errors that can be thrown during operations in DataProviders
public enum DataProviderError: Error {
    /// An error thrown when it was not possible to receive pointer to bytes of data
    case cantGetDataAddress
    /// An error thrown when it was not possible to resize data
    case cantResizeData
    /// An error thrown when type or format of given data type is not supported
    case unsupportedData
    /// An error thrown when data is not passed to data provider
    ///
    /// 1. Thrown during prediction if InputDataProvider did not receive data from app
    /// 2. In OutputDataProvider if prediction was not done yet.
    case dataIsNotAvailable
    /// Error thrown if number of channels is different than required by the model. For e.g. this error will be thrown if user provides 3 channel image (RGB) and model requires 4 channel image (RGBA)
    case unsupportedNumbersOfChannels
}
