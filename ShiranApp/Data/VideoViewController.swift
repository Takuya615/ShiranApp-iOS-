//
//  VideoViewController.swift
//  ShiranApp
//
//  Created by user on 2021/08/10.
//

//import Foundation

import UIKit
import AVFoundation
import Vision
class RealTimeImageClassficationViewController: UIViewController{
    @IBOutlet private weak var previewView: UIView!
    //var images: [UIImage]!
    var Score: CGFloat = 0.0
    var recordButton: UIButton!
    
    var time = 4
    var timer = Timer()
    var textTimer: UILabel!
    var countDown = true
    
    var setTimer = 0
    
    var isRecording = false

    private let videoCapture = VideoCapture()
    private let resnet50ModelManager = Resnet50ModelManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        //images = []
        self.taskCal()
        resnet50ModelManager.delegate = self
        videoCapture.delegate = self
        videoCapture.startCapturing()
        self.setUpCaptureButton()
        
    }
    func taskCal(){
        let totalDay: Int = UserDefaults.standard.integer(forKey: "totalDay") / 3
        setTimer = 5//5 * totalDay + 5
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
        self.textTimer.textColor = UIColor.green
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
                    self.time = self.setTimer //                           本編スタート
                }else{
                    print("撮影終了")
                    self.isRecording = false
                    timer.invalidate()//timerの終了
                    self.textTimer.isHidden = true
                    SystemSounds().EndVideoRecording()
                }
            }
            
        })
       
    }
    
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoCapture.stopCapturing()
        timer.invalidate()
        //create(movieSize: CGSize(width:self.view.bounds.width,height:self.view.bounds.height))
        
    }
    
    //これを呼び出すと　動画作成がはじまる
    /*
    func create(movieSize:CGSize){
        if self.images.isEmpty {print("データなし"); return}
        else {print("imagesは\(self.images.count)")}
        //バックグラウンド非同期処理
        DispatchQueue.global().async {
            print("MovieCreator発動")
            //let movie = MovieCreator()
            //16の倍数
            //let movieSize = CGSize(width:self.view.bounds.width,height:self.view.bounds.height)
            // time / 60 秒表示する
            /*let time = self.setTimer//5  角画像を映す時間
            movie.create(images: self.images, size: movieSize, time: time, completion: {url in
                print("URLが来ているぜ！！！\(url)")
                SaveVideo().saveVideo(outputFileURL: url)
            })*/
            
            /*movie.create2(images: self.images, completion: {url in
                print("URLが来ている\(url)")
                SaveVideo().saveVideo(outputFileURL: url)
                
            })*/
        }
    }
    */
    
}

extension RealTimeImageClassficationViewController: VideoCaptureDelegate {

    // previewLayerがセットされた時に呼ばれる
    func didSet(_ previewLayer: AVCaptureVideoPreviewLayer) {
        previewView = self.view
        previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = previewView.frame
    }

    // フレームがキャプチャされる度に呼ばれる
    func didCaptureFrame(from cgImage: CGImage) {
        
        resnet50ModelManager.performRequet(with: cgImage)
        
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






import SwiftUI
//カメラのビュー
struct VideoCameraView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> UIViewController {
        return RealTimeImageClassficationViewController()
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}
