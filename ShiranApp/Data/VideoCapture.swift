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
    func didCaptureFrame(from imageBuffer: CMSampleBuffer)/*CVImageBuffer)*/
}
class VideoCapture: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate{
    weak var delegate: VideoCaptureDelegate?
    // AVの出入力のキャプチャを管理するセッションオブジェクト
    private let captureSession = AVCaptureSession()
    // ビデオを記録し、処理を行うためにビデオフレームへのアクセスを提供するoutput
    let videoOutput = AVCaptureVideoDataOutput()
    // カメラセットアップとフレームキャプチャを処理する為のDispathQueue
    private let sessionQueue = DispatchQueue(label: "object-detection-queue")
    
    
    func startCapturing() {
        // capture deviceのメディアタイプを決め、
        // 何からインプットするかを決める
        guard let captureDevice = AVCaptureDevice.default(
                .builtInWideAngleCamera, for: .video, position: .front),
              let deviceInput = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        // captureSessionにdeviceInputを入力値として入れる
        captureSession.addInput(deviceInput)

        // キャプチャセッションの開始　（カメラからのデータの描画作業）
        captureSession.startRunning()

        // ビデオフレームの更新ごとに呼ばれるデリゲートをセット
        videoOutput.setSampleBufferDelegate(self, queue: sessionQueue)

        // captureSessionから出力を取得するためにdataOutputをセット
        captureSession.addOutput(videoOutput)
        

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
        // フレームからImageBufferに変換
        //guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}

        delegate?.didCaptureFrame(from: sampleBuffer)
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

    func performRequet(with cgImage: CGImage/*CMSampleBuffer*/) {
        
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
import AVFoundation
import Vision
class RealTimeImageClassficationViewController: UIViewController{
    @IBOutlet private weak var previewView: UIView!
    var images: [UIImage]!
    var Score: CGFloat = 0.0
    var recordButton: UIButton!
    
    var time = 4
    var timer = Timer()
    var textTimer: UILabel!
    var countDown = true
    var isRecording = false
    var setTimer = 0
    
   

    private let videoCapture = VideoCapture()
    private let resnet50ModelManager = Resnet50ModelManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        images = []
        self.taskCal()
        resnet50ModelManager.delegate = self
        videoCapture.delegate = self
        videoCapture.startCapturing()
        self.setUpCaptureButton()
        
    }
    func taskCal(){
        let totalDay: Int = UserDefaults.standard.integer(forKey: "totalDay") / 3
        setTimer = 5 * totalDay + 5
        print("totalDayは　\(totalDay)日 本日のタスク時間は\(setTimer)")
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
        
        
        self.textTimer = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.textTimer.text = "0"
        self.textTimer.font = UIFont.systemFont(ofSize: 50)
        self.textTimer.layer.position = CGPoint(x: self.view.bounds.width * 0.95 , y:self.view.bounds.height * 0.85)
        self.view.addSubview(textTimer)//subView 1
        
        
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 100))
        text.text = "   からだ全体が見える位置に移動してください"
        text.font = UIFont.systemFont(ofSize: 18)
        text.layer.position = CGPoint(x: self.view.bounds.width / 2, y:self.view.bounds.height / 2)
        self.view.addSubview(text)//subView 2

    }
    @objc func onClickRecordButton(sender: UIButton) {
        
        
        self.recordButton.isHidden = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.time -= 1
            self.textTimer.text = String(self.time)
            
            if self.time == 0 {
                if self.countDown{
                    self.countDown = false
                    self.isRecording = true
                    SystemSounds().BeginVideoRecording()
                    self.time = self.setTimer //                           本編スタート 30
                }else{
                    print("撮影終了")
                    
                    self.isRecording = false
                    timer.invalidate()//timerの終了
                    SystemSounds().EndVideoRecording()
                }
            }
            
        })
       
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCapture.stopCapturing()
        timer.invalidate()
        create()
    }
    
    //これを呼び出すと　動画作成がはじまる
    func create(){
        //バックグラウンド非同期処理
        DispatchQueue.global().async {
            print("MovieCreator発動")
            let movie = MovieCreator()
            //16の倍数
            let movieSize = CGSize(width:self.view.bounds.width,height:self.view.bounds.height)
            // time / 60 秒表示する
            let time = self.setTimer//5
            movie.create(images: self.images, size: movieSize, time: time, completion: {url in
                print("URLが来ているぜ！！！\(url)")
                SaveVideo().saveVideo(outputFileURL: url)
            })
        }
    }
    
    
}

extension RealTimeImageClassficationViewController: VideoCaptureDelegate {

    // previewLayerがセットされた時に呼ばれる
    func didSet(_ previewLayer: AVCaptureVideoPreviewLayer) {
        previewView = self.view
        previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = previewView.frame
    }

    // フレームがキャプチャされる度に呼ばれる
    func didCaptureFrame(from imageBuffer: CMSampleBuffer) {
        // CMSampleBuffer  ->  CGImage
        let imageBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(imageBuffer)!
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        resnet50ModelManager.performRequet(with: cgImage)
        
        //録画を押して、３秒後からUIImageを集め始める
        if self.isRecording{
            print("ビデオ録画中")
            let image:UIImage = UIImage.init(cgImage: cgImage)
            self.images.append(image)
        }
        
        
    }
}

extension RealTimeImageClassficationViewController: Resnet50ModelManagerDelegate {

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
                                                          Int(height),//  !!!!!!!!!!!!!!!!!!!!!
                                                          Int(width))
                }
                
            
            print("pointsの内容\(imagePoints)")
            let x:CGFloat = self.view.bounds.origin.x
            let y:CGFloat = self.view.bounds.origin.y
            var height:CGFloat = self.view.bounds.height
            let width:CGFloat = self.view.bounds.width

            if !self.isRecording{
                //UIボタンを押せるように、一時的にマスクの範囲を制限する。
                height = height - 100
            }else{
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






import SwiftUI

//カメラのビュー
struct VideoCameraView123: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return RealTimeImageClassficationViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


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
        let w = rect.width
        for point in points {
            if point.x == 0 {continue}
            let circle = UIBezierPath(
                arcCenter: CGPoint(x: w - point.y, y: point.x),//     ！！
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
            path.move(to: CGPoint(x: w - points[startP[i]].y, y: points[startP[i]].x))
            path.addLine(to: CGPoint(x: w - points[endP[i]].y, y: points[endP[i]].x))
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

