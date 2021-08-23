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
struct VideoCameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}



class ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    // AVの出入力のキャプチャを管理するセッションオブジェクト
    private let captureSession = AVCaptureSession()
    // ビデオを記録し、処理を行うためにビデオフレームへのアクセスを提供するoutput
    let videoDataOutput = AVCaptureVideoDataOutput()
    //let audioDataOutput = AVCaptureAudioDataOutput()
    // カメラセットアップとフレームキャプチャを処理する為のDispathQueue
    private let sessionQueue = DispatchQueue(label: "object-detection-queue")
    //var videoWriter: VideoWriter!
    
    //var buffer: [CMSampleBuffer] = []
    var images: [UIImage] = []
    var count = 0
    var recordButton: UIButton!
    var isRecording = false
    var bound: CGRect = CGRect()
    
    var Score: CGFloat = 0.0
    
    
    /*var time = 4                                                 timer
    var timer = Timer()
    var textTimer: UILabel!
    var countDown = true
    var setTimer = 5*/
    
    
    
    //let resnet50ModelManager = Resnet50ModelManager()
    let poseManager = PoseManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.taskCal()
        //resnet50ModelManager.delegate = self
        //poseManager.delegate = self
        self.setUpCamera()
        self.setUpCaptureButton()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.stopCapturing()
        
        //videoWriter.write2(sampleV: buffer)
        //videoWriter.finish()
        //timer.invalidate()                       timer     timer
        /*DispatchQueue.global().async {
            print("imagesのかず　\(self.images.count)")
            let movie = MovieCreator()
            movie.create(images: self.images, size: self.bound.size)
            //movie.create2(images: self.images, completion: { url in SaveVideo().saveVideo(outputFileURL: url)})
        }*/
        
    }
    
    func setUpCamera() {
        
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "yyyyMMddHHmmSSS"
//        dateFormatter.locale =  Locale(identifier: "ja_JP")
//        let date = dateFormatter.string(from: Date())
//        previewURL = FileManager.default.temporaryDirectory.appendingPathComponent(date)
        bound = view.bounds
        //videoWriter = VideoWriter(height: Int(bound.size.height), width: Int(bound.size.width))
        
        // capture deviceのメディアタイプを決め、
        captureSession.sessionPreset = .low
        // 何からインプットするかを決める
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else{print("エラー１");return}
        videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)// FPSの設定
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else { print("エラー2");return }
        //guard let audioDevice = AVCaptureDevice.default(for: .audio) else {print("エラー3");return}
        //guard let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {print("エラー4");return}
        
        
        /*guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { print("エラー１");return }
        guard let audioDevice = AVCaptureDevice.default(for: .audio),
              let audioInput = try? AVCaptureDeviceInput(device: audioDevice) else {print("エラー2");return}*/
        
        captureSession.addInput(videoInput)
        //captureSession.addInput(audioInput)
        
        videoDataOutput.alwaysDiscardsLateVideoFrames = true//新しいフレーム取得ごとに以前のフレームを破棄する？？
        // ビデオフレームの更新ごとに呼ばれるデリゲートをセット
        videoDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        //videoOutput.alwaysDiscardsLateVideoFrames = true//??????????????
        //audioDataOutput.setSampleBufferDelegate(self, queue: sessionQueue)
        
        // captureSessionから出力を取得するためにdataOutputをセット
        captureSession.addOutput(videoDataOutput)
        //captureSession.addOutput(audioDataOutput)
        
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
        captureSession.stopRunning()
    }
    
    //AVCaptureVideoDataOutputSampleBufferDelegateのプロトコールから引用
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        let isVideo = output is AVCaptureVideoDataOutput
        
        if !isVideo {return}
        
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = true//水平に反転
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {print("ボトル2");return}
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        
        let poseDetection = PoseDetection()
        let imagePoints = poseDetection.getPose(UIimage: UIImage(cgImage: cgImage))
        DispatchQueue.main.async {
           if imagePoints.isEmpty {print("po-zu 未検出"); return}
            
            //var height = self.bound.size.height
            //if !self.isRecording {height = height - 400}
            //print("height = \(height)")
            
            let frame:CGRect = CGRect(
            x: self.bound.origin.x, y: self.bound.origin.y,
            width: self.bound.size.width, height: self.bound.size.height)
           let myView = PoseView(frame: frame, points: imagePoints, score: self.Score)
           myView.isOpaque = false
           //myView.transform = CGAffineTransform(rotationAngle: CGFloat(90 * CGFloat.pi / 180))//(Double.pi)/2)//90度回転
           self.view.subviews.last?.removeFromSuperview()//直近のsubViewだけ、描画のリセッ
           self.view.addSubview(myView)
        }
        if self.isRecording{
            
        }
        
        //コピー
        //guard let newCgIm: CGImage = cgImage.copy() else {print("コピー失敗");return}//(imageView.image?.CGImage)
        //let newImage = UIImage(cgImage: newCgIm,scale: UIImage(cgImage: cgImage).scale,orientation: UIImage(cgImage: cgImage).imageOrientation)
        
        /*if self.isRecording{
            count = count + 1
            print("\(count)回呼ばれている")
            //buffer.append(sampleBuffer)
            images.append(UIImage(cgImage: cgImage))
        }*/
        
        
        
        
        
        
        /*if self.isRecording{
            images.append(UIImage(cgImage: cgImage))
            //self.isVideoList.append(isVideo)
            /*guard CMSampleBufferDataIsReady(sampleBuffer) else { print("ボトル1");return }
            self.videoWriter.write(sample: sampleBuffer, isVideo: isVideo)*/
        }*/
        //if isVideo {}
            //connection.videoOrientation = .portrait
            //connection.isVideoMirrored = true//水平に反転
            //poseManager.push(sampleBuffer: sampleBuffer)
            
        
    }
    
    
    
    /*func taskCal(){
        let totalDay: Int = UserDefaults.standard.integer(forKey: "totalDay") / 3
        setTimer = 5//5 * totalDay + 5
        print("totalDayは　\(totalDay)日 本日のタスク時間は\(setTimer)")
    }*/
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
        
        /*                                                 timer                                                 timer
        self.textTimer = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.textTimer.text = "0"
        self.textTimer.textColor = UIColor.green
        self.textTimer.font = UIFont.systemFont(ofSize: 50)
        self.textTimer.layer.position = CGPoint(x: self.view.bounds.width * 0.95 , y:self.view.bounds.height * 0.85)
        self.view.addSubview(textTimer)//subView 1
        
         */
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        text.text = "   からだ全体が見える位置に移動してください"
        text.font = UIFont.systemFont(ofSize: 18)
        text.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height / 2)
        text.textColor = .green
        self.view.addSubview(text)//subView 2
        
        

    }
    @objc func onClickRecordButton(sender: UIButton) {
        if isRecording {
            isRecording = false
            recordButton.backgroundColor = .gray
        }else{
            isRecording = true
            recordButton.backgroundColor = .red
        }//self.recordButton.isHidden = true
        
        /*                                                 timer                                                 timer
        self.recordButton.isHidden = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.time -= 1
            self.textTimer.text = String(self.time)
            
            if self.time == 0 {
                if self.countDown{
                    self.countDown = false
                    self.isRecording = true
                    SystemSounds().BeginVideoRecording()
                    self.time = self.setTimer //                           本編スタート
                }else{
                    print("撮影終了")
                    self.isRecording = false
                    timer.invalidate()//timerの終了
                    self.textTimer.isHidden = true
                    SystemSounds().EndVideoRecording()
                }
            }
            
        })*/
    }
    
    func zuttomo(){
        
        print("Viewがロードされるたびに呼ばれている？？")
        // キャプチャする範囲を取得する
        let rect = self.view.bounds
        // ビットマップ画像のcontextを作成する
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        let context : CGContext = UIGraphicsGetCurrentContext()!
        // view内の描画をcontextに複写する
        self.view.layer.render(in: context)
        // contextのビットマップをUIImageとして取得する
        let image : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        // contextを閉じる
        UIGraphicsEndImageContext()

        DispatchQueue.global().async {
            let poseDetection = PoseDetection()
            let imagePoints = poseDetection.getPose(UIimage: image)
            DispatchQueue.main.async {
                
               if imagePoints.isEmpty {print("po-zu 未検出"); return}
                
                //var height = self.bound.size.height
                //if !self.isRecording {height = height - 400}
                //print("height = \(height)")
                
                let frame:CGRect = CGRect(
                x: self.bound.origin.x, y: self.bound.origin.y,
                width: self.bound.size.width, height: self.bound.size.height)
               let myView = PoseView(frame: frame, points: imagePoints, score: self.Score)
               myView.isOpaque = false
               //myView.transform = CGAffineTransform(rotationAngle: CGFloat(90 * CGFloat.pi / 180))//(Double.pi)/2)//90度回転
               self.view.subviews.last?.removeFromSuperview()//直近のsubViewだけ、描画のリセッ
               self.view.addSubview(myView)
            
            }
        }

    }
    
    
    
}
/*
extension ViewController: PoseManagerDelegate {
    func makePose(points: [CGPoint]) {
        DispatchQueue.main.async {
    
        if points.isEmpty {print("po-zu 未検出"); return}
        
            var height = self.bound.size.height
            if !self.isRecording {height = height - 100}
            print("height = \(height)")
            
        let frame:CGRect = CGRect(
            x: self.bound.origin.x, y: self.bound.origin.y,
            width: self.bound.size.width, height: height)
        let myView = PoseView(frame: frame, points: points, score: self.Score)
        myView.isOpaque = false
        //print("Viewへ渡したCGRectは width \(frame.width) , height \(frame.height)")
        //myView.transform = CGAffineTransform(rotationAngle: CGFloat(90 * CGFloat.pi / 180))//(Double.pi)/2)//90度回転
        self.view.subviews.last?.removeFromSuperview()//直近のsubViewだけ、描画のリセッ
        self.view.addSubview(myView)
        }
    }
}
*/

/*
extension ViewController: Resnet50ModelManagerDelegate {

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
            
            
        }
        
    }

}*/
