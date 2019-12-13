//
//  ViewController.swift
//  MacaquePreview
//
//  Created by Kamil Wasąg on 25/11/2019.
//  Copyright © 2019 Enigma Pattern Sp. z o.o. All rights reserved.
//

import UIKit
import Macaque
import AVFoundation

class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    let predictor:Macaque<TensorflowLitePredictor,VideoStreamInputDataProvider<UInt8>,Detection4OutputsBoundingBoxesDataProvider>? =  {
        guard let predictor = try? TensorflowLitePredictor(modelName: "detect", modelExtension: "tflite", inBundle: Bundle.main) else {
            return nil
        }
        return Macaque(withPredictor: predictor,
                       withInputDataProvider: VideoStreamInputDataProvider<UInt8>(),
                       withOutputDataProvider: Detection4OutputsBoundingBoxesDataProvider())
    }()
    
    private let session = AVCaptureSession()
    private var videoDataOutput:AVCaptureVideoDataOutput!
    var done = false
    
    @IBOutlet weak var cameraPreview: CameraPreview!
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.session.sessionPreset = .medium
        guard let backCamera = AVCaptureDevice.default(for: AVMediaType.video) else {
            return
        }
        do {
            let input = try AVCaptureDeviceInput(device: backCamera)
            
            let sampleBufferQueue = DispatchQueue(label: "sampleBufferQueue")
            videoDataOutput = AVCaptureVideoDataOutput()
               videoDataOutput.setSampleBufferDelegate(self, queue: sampleBufferQueue)
               videoDataOutput.alwaysDiscardsLateVideoFrames = true
               videoDataOutput.videoSettings = [ String(kCVPixelBufferPixelFormatTypeKey) : kCMPixelFormat_32BGRA]
            if self.session.canAddInput(input) && self.session.canAddOutput(videoDataOutput) {
                self.session.addInput(input)
                session.addOutput(videoDataOutput)
                videoDataOutput.connection(with: .video)?.videoOrientation = .portrait
            }
        }catch let error {
            print(error)
        }
        self.cameraPreview.videoPreviewLayer.session = self.session
        self.cameraPreview.videoPreviewLayer.videoGravity = .resizeAspectFill
        self.cameraPreview.videoPreviewLayer.connection?.videoOrientation = .portrait
        
        
        
        DispatchQueue.global(qos: .userInitiated).async {
            self.session.startRunning()
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer: CVPixelBuffer? = CMSampleBufferGetImageBuffer(sampleBuffer)
        
        guard let imagePixelBuffer = pixelBuffer else {
            return
        }
        self.predictor?.inputDataProvider.pixelBuffer = imagePixelBuffer
        try? self.predictor?.predict()
        if let results = try? self.predictor?.outputDataProvider.getResults() {
            DispatchQueue.main.async {
                self.cameraPreview.layer.draw(boundingBoxes: results)
            }
        }
    }
}

class CameraPreview:UIView {
    override class var layerClass: AnyClass{
        return AVCaptureVideoPreviewLayer.self
    }
    
    var videoPreviewLayer:AVCaptureVideoPreviewLayer{
        return layer as! AVCaptureVideoPreviewLayer
    }
}
