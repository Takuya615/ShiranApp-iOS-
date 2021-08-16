//
//  VideoCapture.swift
//  ShiranApp
//
//  Created by user on 2021/07/23.
//


import CoreML
import AVFoundation
protocol VideoCaptureDelegate: AnyObject {
    func didSet(_ previewLayer: AVCaptureVideoPreviewLayer)
    func didCaptureFrame(from cgImage: CGImage)/*CVImageBuffer)*/
}
class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate{
    weak var delegate: VideoCaptureDelegate?
    // AVの出入力のキャプチャを管理するセッションオブジェクト
    let captureSession = AVCaptureSession()
    // ビデオを記録し、処理を行うためにビデオフレームへのアクセスを提供するoutput
    let videoOutput = AVCaptureVideoDataOutput()
    let audioDataOutput = AVCaptureAudioDataOutput()
    // カメラセットアップとフレームキャプチャを処理する為のDispathQueue
    private let sessionQueue = DispatchQueue(label: "object-detection-queue")
    var videoWriter: VideoWriter!
    //var isRecording = false
    //var videoWriter: VideoWriter?
    
    //let w = 720
    //let h = 1280
    var viewController = RealTimeImageClassficationViewController()
    
    func startCapturing() {
        
        let size = viewController.view.bounds.size
        videoWriter = VideoWriter(height: Int(size.height), width: Int(size.width))
        
        
        //captureSession.sessionPreset = .low
        
        // capture deviceのメディアタイプを決め、
        // 何からインプットするかを決める
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {return}
        
        captureSession.addInput(audioInput)
        captureSession.addInput(deviceInput)
        
        
        // ビデオフレームの更新ごとに呼ばれるデリゲートをセット
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        //videoOutput.alwaysDiscardsLateVideoFrames = true//??????????????
        audioDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // captureSessionから出力を取得するためにdataOutputをセット
        captureSession.addOutput(audioDataOutput)
        captureSession.addOutput(videoOutput)
        
        // キャプチャセッションの開始　（カメラからのデータの描画作業）
        captureSession.startRunning()

    
        // captureSessionをUIに描画するためにPreviewLayerにsessionを追加
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        delegate?.didSet(previewLayer)
    }
    func stopCapturing() {
        // キャプチャセッションの終了
        captureSession.stopRunning()
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegateのプロトコールから引用
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
//        //connection.videoOrientation = .portraitUpsideDown///カメラ向き（縦長）　修正
//        connection.isVideoMirrored = true//水平に反転
//        // フレームからImageBufferに変換
//        //guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
//        //if !self.isRecording{return}
//
//
//
//        //録画を押して、３秒後からUIImageを集め始める
//        if viewController.isRecording{
//            print("ビデオ録画中")
//
//            let image:UIImage = UIImage.init(cgImage: cgImage)
//            viewController.images.append(image)
//        }
        
        let isVideo = output is AVCaptureVideoDataOutput
        if isVideo {
            connection.videoOrientation = .portrait//カメラ向き（縦長）　修正}
            
            // CMSampleBuffer  ->  CGImage
            let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)!
            let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            let context:CIContext = CIContext.init(options: nil)
            let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
            delegate?.didCaptureFrame(from: cgImage)//Pose検出する
        }
                
        
        
        if !viewController.isRecording{return}
        guard CMSampleBufferDataIsReady(sampleBuffer) else{
                print("data not ready")
                return
            }
        videoWriter.write(sample: sampleBuffer, isVideo: isVideo)
        
        
        
        
    }
    
}






import Vision
protocol Resnet50ModelManagerDelegate: AnyObject {
    func didRecieve(_ observation: VNHumanBodyPoseObservation)
}
class Resnet50ModelManager: NSObject {

    weak var delegate: Resnet50ModelManagerDelegate?
    
    func bodyPoseHandler(request: VNRequest, error: Error?) {
        //print("少なくともハンドラーまではきてる")
        guard let observations =
                request.results as? [VNHumanBodyPoseObservation] else {
            print("observationsの制作しっぱい")
            return
        }
        
        // Process each observation to find the recognized body pose points.
        observations.forEach {self.delegate?.didRecieve($0)}//processObservation($0)
        
    }

    func performRequet(with cgImage: CGImage) {
        
        // Create a new image-request handler.
        let requestHandler = VNImageRequestHandler(cgImage: cgImage)

        // Create a new request to recognize a human body pose.
        let request = VNDetectHumanBodyPoseRequest(completionHandler: bodyPoseHandler)

        do {
            // Perform the body pose-detection request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the request: \(error).")
        }
 
    }
}








import UIKit
class PoseView: UIView{
    var points: [CGPoint]
    var score: CGFloat
    init(frame: CGRect, points: [CGPoint], score: CGFloat) {
        self.points = points
        self.score = score
        super .init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        //let h = rect.height
        //let w = rect.width
        for point in points {
            if point.x == 0 {continue}
            let circle = UIBezierPath(
                arcCenter: CGPoint(x: point.x, y: point.y),
                radius: 10,
                startAngle: 0,
                endAngle: CGFloat(Double.pi)*2,
                clockwise: true)
            UIColor(red: 0, green: 1, blue: 0, alpha: 1.0).setFill()// 内側の色
            circle.fill()// 内側を塗りつぶす
            UIColor(red: 0, green: 1, blue: 0, alpha: 1.0).setStroke() // 線の色
            //circle.lineWidth = 2.0// 線の太さ
            circle.stroke()// 線を塗りつぶす
        }
        
        //線を描く
        let startP = [0,1,6,7,3, 4,9,10,0,3,0, 6]
        let endP = [1,2,7,8,4, 5,10,11,6,9,3, 9]
        let path = UIBezierPath()
        for i in 0...11{
            if points[startP[i]].x == 0 || points[endP[i]].x == 0 {continue}
            path.move(to: CGPoint(x: points[startP[i]].x, y: points[startP[i]].y))
            path.addLine(to: CGPoint(x: points[endP[i]].x, y: points[endP[i]].y))
        }
        path.lineWidth = 8.0 // 線の太さ
        UIColor.yellow.setStroke() // 色をセット
        path.stroke()
        
        
        "Score \(Int(score)/10000)".draw(at: CGPoint(x: 100, y: 10), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.blue,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40),
        ])
        
    }
    
    
}

