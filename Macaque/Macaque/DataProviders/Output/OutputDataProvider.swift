//
//  OutputDataProvider.swift
//  Macaque
//
//  Created by Kamil Wasąg on 22/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import Foundation

/// Protocol for Output Data Providers
///
/// Objects implementing this protocol are responsible for taking data from model prediction and convert it to data that can be easily used by application.
/// There are available few implementations of OutputDataProvider, more can be easily implemented.
public protocol OutputDataProvider {
    /// The property where, for future use, Predictor will assign data received in prediction.
    var data:[(data:Data, shape:[Int])]? { get set}
}
