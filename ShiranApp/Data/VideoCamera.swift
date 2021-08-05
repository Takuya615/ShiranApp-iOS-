//
//  AVFoundationVM.swift
//  aaa
//
//  Created by user on 2021/06/22.
//

//import Foundation

import UIKit
import Combine
import AVFoundation

import SwiftUI


//カメラのビュー
struct VideoCameraView: UIViewControllerRepresentable {
     var caLayer:CALayer

     func makeUIViewController(context: UIViewControllerRepresentableContext<VideoCameraView>) -> UIViewController {
         let viewController = ViewController()//UIViewController()

         viewController.view.layer.addSublayer(caLayer)
         caLayer.frame = viewController.view.layer.frame
        //caLayer.shouldRasterize = YES
        caLayer.rasterizationScale = 0.1
        //caLayer.addSublayer(CALayer)                                         レイヤーにれいやーを重ねることができる！！！！！！１１
         return viewController
     }

     func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<VideoCameraView>) {
         caLayer.frame = uiViewController.view.layer.frame
     }
    
 }






class VideoCamera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, ObservableObject {
    ///撮影した画像
    @Published var image: UIImage?
    ///プレビュー用レイヤー
    var previewLayer:CALayer!

    ///撮影開始フラグ
    //private var _takePhoto:Bool = false
    ///セッション
    private let captureSession = AVCaptureSession()
    ///撮影デバイス
    private var capturepDevice:AVCaptureDevice!

    override init() {
        super.init()

        prepareCamera()
        beginSession()
    }
//
//    func takePhoto() {
//        _takePhoto = true
//    }

    private func prepareCamera() {
        captureSession.sessionPreset = .photo

        //カメラの向き修正
        if let availableDevice = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices.first {
            capturepDevice = availableDevice
        }
    }

    
    private func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: capturepDevice)

            captureSession.addInput(captureDeviceInput)
        } catch {
            print(error.localizedDescription)
        }

        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer

        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA]

        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }

        // video quality setting
        captureSession.beginConfiguration()
        captureSession.sessionPreset = .low//.cif352x288//.low
        
        captureSession.commitConfiguration()

        let queue = DispatchQueue(label: "FromF.github.com.AVFoundationSwiftUI.AVFoundation")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    

//    func startSession() {
//        if captureSession.isRunning { return }
//        captureSession.startRunning()
//    }
//
//    func endSession() {
//        if !captureSession.isRunning { return }
//        captureSession.stopRunning()
//    }

    // MARK: - AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        // フレームからImageBufferに変換
                guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                else { return }
        
        
    }

//    private func getImageFromSampleBuffer (buffer: CMSampleBuffer) -> UIImage? {
//        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
//            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
//            let context = CIContext()
//
//            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
//
//            if let image = context.createCGImage(ciImage, from: imageRect) {
//                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
//            }
//        }
//
//        return nil
//    }
}


//ビデオ撮影できる　クラス
import Firebase

class ViewController: UIViewController,AVCaptureFileOutputRecordingDelegate {
    
    var recordButton: UIButton!
    var fileOutput = AVCaptureMovieFileOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .black
        self.setUpCamera()
    }

    func setUpCamera() {
        
        let captureSession: AVCaptureSession = AVCaptureSession()
        let videoDevice: AVCaptureDevice? = AVCaptureDevice.default(
            .builtInWideAngleCamera,for: AVMediaType.video,position: .front)//( カメラの方向　前・後ろの設定
            //for: AVMediaType.video)
        let audioDevice: AVCaptureDevice? = AVCaptureDevice.default(for: AVMediaType.audio)

        // video input setting
        let videoInput: AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: videoDevice!)
        captureSession.addInput(videoInput)

        // audio input setting
        let audioInput = try! AVCaptureDeviceInput(device: audioDevice!)
        captureSession.addInput(audioInput)

        captureSession.addOutput(fileOutput)

        captureSession.startRunning()

        // video preview layer
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspect//fill　　アスペクト比の調整
        self.view.layer.addSublayer(videoLayer)

        // recording button
        self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.recordButton.backgroundColor = UIColor.red
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = self.recordButton.frame.width/2
        self.recordButton.setTitle("Record", for: .normal)
        //self.recordButton.layer.cornerRadius = 20
        self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height - 120)
        self.recordButton.addTarget(self, action: #selector(self.onClickRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)
        
    }

    @objc func onClickRecordButton(sender: UIButton) {
        if self.fileOutput.isRecording {
            // stop recording
            fileOutput.stopRecording()

            self.recordButton.backgroundColor = .red//gray
            self.recordButton.setTitle("Record", for: .normal)
        } else {
            // start recording
            //let path = "\(NSTemporaryDirectory())/Documents"
            let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
            let fileURL: URL = tempDirectory.appendingPathComponent("mytemp1.mp4")//保存する動画のファイル名
            //URL出なくpathを渡す
            //let directory = NSTemporaryDirectory()
            fileOutput.startRecording(to: fileURL, recordingDelegate: self)

            //let avCaptureConnection = AVCaptureConnection()
            //fileOutput?(fileOutput, didStartRecordingTo: fileURL, from: avCaptureConnection)
            
            self.recordButton.backgroundColor = .gray//red
            self.recordButton.setTitle("●Recording", for: .normal)
        }
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("動画　撮影　終了")
       //動画をセーブしますよー
        
        //SaveVideo().EditVideo(outputFileURL: outputFileURL)
        SaveVideo().saveVideo(outputFileURL: outputFileURL)
        
        
    }
    
    
}


