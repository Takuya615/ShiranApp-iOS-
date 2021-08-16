//
//  ViewController2.swift
//  copypeVideo
//
//  Created by user on 2021/08/13.
//

//import Foundation
//import UIKit
import AVFoundation
import SwiftUI
import Vision

//カメラのビュー
struct VideoCameraView2: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController2()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}



class ViewController2: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    // AVの出入力のキャプチャを管理するセッションオブジェクト
    private let captureSession = AVCaptureSession()
    // ビデオを記録し、処理を行うためにビデオフレームへのアクセスを提供するoutput
    let videoDataOutput = AVCaptureVideoDataOutput()
    let audioDataOutput = AVCaptureAudioDataOutput()
    // カメラセットアップとフレームキャプチャを処理する為のDispathQueue
    private let sessionQueue = DispatchQueue(label: "object-detection-queue")
    
    //@IBOutlet private weak var previewView: UIView!
    var videoWriter: VideoWriter!
    //var images: [UIImage]!
    var recordButton: UIButton!
    var isRecording = false
    
    
    //var previewURL: URL! //= FileManager.default.temporaryDirectory.appendingPathComponent("preview005.mp4")
    var size: CGSize = CGSize()
    //let channel: UInt32 = 1
    //let sampleRate: Float64 = 44100.000000
    var Score: CGFloat = 0.0
    
    let resnet50ModelManager = Resnet50ModelManager()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //images = []
        resnet50ModelManager.delegate = self
        self.setUpCamera()
        self.setUpCaptureButton()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopCapturing()
        //print("Cameraおしまい　\(images.count)")
        videoWriter.finish()
        /*DispatchQueue.global().async {
            let movie = MovieCreator()
            movie.create2(images: self.images, completion: { url in
                SaveVideo().saveVideo(outputFileURL: url)
            })
        }*/
        
    }
    
    func setUpCamera() {
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMddHHmmSSS"
//        dateFormatter.locale =  Locale(identifier: "ja_JP")
//        let date = dateFormatter.string(from: Date())
//        previewURL = FileManager.default.temporaryDirectory.appendingPathComponent(date)
        size = view.bounds.size
        videoWriter = VideoWriter(height: Int(size.height), width: Int(size.width))
        
        // capture deviceのメディアタイプを決め、
        //captureSession.sessionPreset = .low
        // 何からインプットするかを決める
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else{print("エラー１");return}
        //videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)// FPSの設定
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { print("エラー2");return }
        guard let audioDevice = AVCaptureDevice.default(for: .audio) else {print("エラー3");return}
        guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {print("エラー4");return}
        
        
        /*guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { print("エラー１");return }
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {print("エラー2");return}*/
        
        captureSession.addInput(videoInput)
        captureSession.addInput(audioInput)
        
        // ビデオフレームの更新ごとに呼ばれるデリゲートをセット
        videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        //videoOutput.alwaysDiscardsLateVideoFrames = true//??????????????
        audioDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // captureSessionから出力を取得するためにdataOutputをセット
        captureSession.addOutput(videoDataOutput)
        captureSession.addOutput(audioDataOutput)
        
        // キャプチャセッションの開始　（カメラからのデータの描画作業）
        captureSession.startRunning()

    
        //print("ここまで来ている？？");
        // captureSessionをUIに描画するためにPreviewLayerにsessionを追加
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        //videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.view.layer.addSublayer(videoLayer)
        videoLayer.frame = self.view.frame
        
    }
    func stopCapturing() {
        // キャプチャセッションの終了
        if captureSession.isRunning{
            captureSession.stopRunning()
        }
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegateのプロトコールから引用
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let isVideo = output is AVCaptureVideoDataOutput
        if isVideo {
            // CMSampleBuffer  ->  CGImage
            guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
            let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
            let context:CIContext = CIContext.init(options: nil)
            let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
            resnet50ModelManager.performRequet(with: cgImage)
            
            connection.videoOrientation = .portraitUpsideDown///カメラ向き（縦長）　修正
            //connection.isVideoMirrored = true//水平に反転
        }
        
        
        if !self.isRecording{return}
        guard CMSampleBufferDataIsReady(sampleBuffer) else{
                print("data not ready")
                return
            }
        videoWriter.write(sample: sampleBuffer, isVideo: isVideo)
//        if self.isRecording{
//
//            let image:UIImage = UIImage.init(cgImage: cgImage)
//            self.images.append(image)
//        }
        
        
    }
    
    func setUpCaptureButton(){
        // recording button
        self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.recordButton.backgroundColor = UIColor.red
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = self.recordButton.frame.width/2
        self.recordButton.setTitle("Record", for: .normal)
        //self.recordButton.layer.cornerRadius = 20
        self.recordButton.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height * 0.8)
        self.recordButton.addTarget(self, action: #selector(self.onClickRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)//subView 0

    }
    @objc func onClickRecordButton(sender: UIButton) {
        
        
        if isRecording {
            isRecording = false
            recordButton.backgroundColor = .gray
        }else{
            isRecording = true
            recordButton.backgroundColor = .red
        }
        
        //self.recordButton.isHidden = true
    }
    
    
    
}

extension ViewController2: Resnet50ModelManagerDelegate {

    // 画像分析リクエストから観測値を受け取る度に呼ばれる
    func didRecieve(_ observation: VNHumanBodyPoseObservation) {
        DispatchQueue.main.async {
            // Retrieve all torso points.
            guard let recognizedPoints =
                    try? observation.recognizedPoints(.all) else {
                print("ポイントの配列？の生成に失敗")
                return
            }
                // Torso joint names in a clockwise ordering.
                let bodyJointNames: [VNHumanBodyPoseObservation.JointName] = [
                    
                    /*.nose,
                    .leftEar,
                    .leftEye,
                    .rightEar,
                    .rightEye*/
                    
                    .rightShoulder,
                    .rightElbow,
                    .rightWrist,
                    .rightHip,
                    .rightKnee,
                    .rightAnkle,
                    
                    .leftShoulder,
                    .leftElbow,
                    .leftWrist,
                    .leftHip,
                    .leftKnee,
                    .leftAnkle
                    
                ]
                
                // Retrieve the CGPoints containing the normalized X and Y coordinates.
                let imagePoints: [CGPoint] = bodyJointNames.compactMap {
                    guard let point = recognizedPoints[$0]/*, point.confidence > 0*/ else {
                        print("ポイント生成に失敗")
                        return nil
                    }
                    
                    let width:CGFloat = self.view.bounds.width
                    let height:CGFloat = self.view.bounds.height
                    
                    // Translate the point from normalized-coordinates to image coordinates.
                    return VNImagePointForNormalizedPoint(point.location,
                                                          Int(width),
                                                          Int(height))
                }
                
            
            print("pointsの内容\(imagePoints)")
            let x:CGFloat = self.view.bounds.origin.x
            let y:CGFloat = self.view.bounds.origin.y
            var height:CGFloat = self.view.bounds.height
            let width:CGFloat = self.view.bounds.width

            if !self.isRecording {
                //UIボタンを押せるように、一時的にマスクの範囲を制限する。
                height = height - 100
            }else{
                //height = height + 100
                //Recoding中のみスコアを加算する
                for i in imagePoints {
                    if i.x == 0 {continue}
                    self.Score = self.Score + i.x + i.y
                }
            }
            
            let frame:CGRect = CGRect(x: x, y: y, width: width, height: height)
            let myView = PoseView(frame: frame, points: imagePoints, score: self.Score)
            myView.isOpaque = false
            //myView.transform = CGAffineTransform(rotationAngle: CGFloat(90 * CGFloat.pi / 180))//(Double.pi)/2)//90度回転
            
            self.view.subviews.last?.removeFromSuperview()//直近のsubViewだけ、描画のリセット
            
            self.view.addSubview(myView)
            
            
            
            //動画のUIImageを繋げる
            /*
            UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, false, 0.0)
            let context = UIGraphicsGetCurrentContext()// else { return nil }
            self.view.layer.render(in: context!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.images.append(image!)*/
            
        }
        
    }

}

