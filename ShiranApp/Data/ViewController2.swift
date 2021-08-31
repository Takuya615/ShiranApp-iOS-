//
//  ViewController2.swift
//  ShiranApp
//
//  Created by user on 2021/08/23.
//

import AVFoundation
import SwiftUI
import Instructions

//カメラのビュー
struct VideoCameraView2: UIViewControllerRepresentable {
    @Binding var isVideo:Bool
    func makeUIViewController(context: Context) -> UIViewController {
        return ViewController2(videoCameraView2: self)
    }
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
    }
}


class ViewController2: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var pD = OriginalPoseDetection()
    // カメラからの入出力データをまとめるセッション
    var session: AVCaptureSession!
    // プレビューレイヤ
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    
    var count = 0
    var recordButton: UIButton!
    var isRecording = false
    
    var score: CGFloat = 0
    
    var time = 4
    var timer = Timer()
    var textTimer: UILabel!
    var countDown = true
    
    //コーチマーク用
    var coachController = CoachMarksController()
    var messages:[String] = []
    var views: [UIView] = []
    
    
    
    var videoCameraView2:VideoCameraView2
    init(videoCameraView2:VideoCameraView2) {
        self.videoCameraView2 = videoCameraView2
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.coachController.dataSource = self//CoachMark
    }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      UIApplication.shared.isIdleTimerDisabled = true  //この画面をスリープさせない。
    }
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      UIApplication.shared.isIdleTimerDisabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super .viewDidAppear(animated)
        self.initCamera()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Viewが閉じられたとき、セッションを終了
        if !DataCounter().coachMark2{
            self.coachController.stop(immediately: true)//CoachMark
            UserDefaults.standard.set(true, forKey: "CoachMark2")//CoachMark
        }
        
        self.isRecording = false
        timer.invalidate()
        self.session.stopRunning()
        // メモリ解放
        for output in self.session.outputs {
            self.session.removeOutput(output as AVCaptureOutput)
        }
        for input in self.session.inputs {
            self.session.removeInput(input as AVCaptureInput)
        }
        self.session = nil
        
        if !countDown {
            //dataCounter.scoreCounter()
            //let save = SaveVideo().environmentObject(DataCounter())
            SaveVideo().saveData(score: Int(score))
        }
        
    }

    private func initCamera() {
        // バックカメラを取得
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else{return}
        // FPSの設定
        //videoDevice.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: 30)

        do {
            // 入力設定
            let input = try AVCaptureDeviceInput(device: videoDevice)
            // 出力設定
            let output: AVCaptureVideoDataOutput = AVCaptureVideoDataOutput()
            // 出力設定: カラーチャンネル
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey : kCVPixelFormatType_32BGRA] as [String : Any]
            // 出力設定: デリゲート、画像をキャプチャするキュー
            output.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            // 出力設定: キューがブロックされているときに新しいフレームが来たら削除
            output.alwaysDiscardsLateVideoFrames = true

            // セッションの作成
            self.session = AVCaptureSession()
            // 解像度を設定
            self.session.sessionPreset = .medium

            // セッションに追加.
            if self.session.canAddInput(input) && self.session.canAddOutput(output) {
                self.session.addInput(input)
                self.session.addOutput(output)

                // プレビュー開始
                self.startPreview()
            }
        }
        catch _ {
            print("error occurd")
        }
    }

    private func startPreview() {
        // 画像を表示するレイヤーを生成
        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.session)
        // カメラ入力の縦横比を維持したまま、レイヤーいっぱいに表示
        self.videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        // 縦向きで固定
        //self.videoPreviewLayer.connection?.videoOrientation = .portrait
        // previewViewに追加
        self.view.layer.addSublayer(videoPreviewLayer)
        self.setUpCaptureButton()
        // startRunningメソッドはブロッキングメソッドなので、非同期に並列処理を行う
        // qos引数は処理の優先順位
        DispatchQueue.global(qos: .userInitiated).async {
            // セッション開始
            self.session.startRunning()
            // 上記処理の終了後、下記処理をメインスレッドで実行
            DispatchQueue.main.async {
                // 'previewView'の大きさに'videoPreviewLayer'をリサイズ
                let frame = self.view.bounds
                self.videoPreviewLayer.frame = CGRect(x: 10, y: 0, width: frame.width - 20, height: frame.height)//self.view.bounds
            }
        }
        
    }
    func setUpCaptureButton(){
        let rect = self.view.bounds.size
        
        // recording button
        self.recordButton = UIButton(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.recordButton.backgroundColor = UIColor.orange
        self.recordButton.layer.masksToBounds = true
        self.recordButton.layer.cornerRadius = self.recordButton.frame.width/2
        self.recordButton.setTitle("START", for: .normal)
        //self.recordButton.layer.cornerRadius = 20
        self.recordButton.layer.position = CGPoint(x: rect.width / 2, y:rect.height * 0.8)
        self.recordButton.addTarget(self, action: #selector(self.onClickRecordButton(sender:)), for: .touchUpInside)
        self.view.addSubview(recordButton)//subView 0
        
        //TimerBoard
        self.textTimer = UILabel(frame: CGRect(x: 0, y: 0, width: 150, height: 50))
        self.textTimer.text = self.min(time: self.taskTime())
        self.textTimer.textColor = UIColor.blue
        self.textTimer.backgroundColor = .white
        self.textTimer.font = UIFont.systemFont(ofSize: 50)
        self.textTimer.textAlignment = NSTextAlignment.center
        self.textTimer.center = CGPoint(x: rect.width/2, y: rect.height*0.01)
        
        self.textTimer.layer.borderColor = UIColor.blue.cgColor
        self.textTimer.layer.borderWidth = 2
        self.textTimer.layer.masksToBounds = true
        self.textTimer.layer.cornerRadius = 10
        self.view.addSubview(textTimer)//subView 1
        
         
        let text = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 25))
        text.text = "準備中..."
        text.textColor = .blue
        text.font = UIFont.systemFont(ofSize: 18)
        text.textAlignment = NSTextAlignment.center
        text.center = CGPoint(x: rect.width/2, y: rect.height/2)
        //text.layer.position = CGPoint(x: self.view.bounds.width/2 , y:self.view.bounds.height / 2)
        self.view.addSubview(text)//subView 2
        
        if !DataCounter().coachMark2 {
            let MainView = UIHostingController(rootView: IntroView(imageName: "sample", number: 0).environmentObject(AppState()))//ContentView())
            MainView.presentationController?.delegate = self
            self.present(MainView, animated: true, completion:nil)
        }

    }
    @objc func onClickRecordButton(sender: UIButton) {
        
        self.recordButton.isHidden = true
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (timer) in
            self.time -= 1
            
            if self.countDown {
                self.textTimer.text = String(self.time)
                self.textTimer.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
                self.textTimer.font = UIFont.systemFont(ofSize: 200)
                self.textTimer.layer.position = CGPoint(x: self.view.bounds.width / 2 , y: self.view.bounds.height * 0.5)
            }else{
                self.textTimer.text = self.min(time: self.time)
                self.textTimer.frame = CGRect(x: 0, y: 0, width: 150, height: 50)
                self.textTimer.font = UIFont.systemFont(ofSize: 50)
                self.textTimer.layer.position = CGPoint(x: self.view.bounds.width / 2 , y: self.view.bounds.height * 0.01)
            }
            
            
            if self.time == 0 {
                if self.countDown{
                    //   moment of 0 Sec
                    self.countDown = false
                    self.isRecording = true
                    SystemSounds().BeginVideoRecording()
                    self.time = self.taskTime() //                           本編スタート
                }else{
                    print("撮影終了")
                    SystemSounds().buttonVib("")
                    SystemSounds().buttonSampleWav("")
                    //SystemSounds().EndVideoRecording()
                    self.isRecording = false
                    timer.invalidate()//timerの終了
                    self.textTimer.isHidden = true
                    
                    
                    
                    //スコア表示する　ダイアログを設定する
                    let totalDay: Int = UserDefaults.standard.integer(forKey: "totalDay")//読み込み
                    let alert: UIAlertController = UIAlertController(
                        title: """
                                \(totalDay)日目　最終スコア
                            \(Int(self.score))
                            """,
                        message:"", preferredStyle:  UIAlertController.Style.alert)
                    // OKボタン
                    let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:{
                        // ボタンが押された時の処理
                          (action: UIAlertAction!) -> Void in
                          // 何かしらの処理を記載
                        self.videoCameraView2.isVideo = false
                    })
                    // UIAlertControllerにActionを追加
                    alert.addAction(defaultAction)
                    // Alert表示
                    self.present(alert, animated: true, completion: nil)
                    //モーダル表示
                    //let MainView = UIHostingController(rootView: DialogView().environmentObject(AppState()))//ContentView())
                    //self.present(MainView, animated: true, completion: nil)
                    
                }
            }
            
        })
    }

    func taskTime() -> Int{
        var taskTime: Int = UserDefaults.standard.integer(forKey: "TaskTime")
        if taskTime < 5 {taskTime = 5}
        if taskTime > 240 {taskTime = 240}
        return taskTime
    }
    func min(time: Int) -> String{
        if time<60 {return String(time)}
        let min = time/60
        let sec = time%60
        return String("\(min):\(sec)")
    }
    
    // delegateメソッド
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //print("1フレームごとの処理をここに書く")
        
        connection.videoOrientation = .portrait
        connection.isVideoMirrored = true
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        
        //let pDf = OriginalPoseDetection()
        let imagePoints = pD.getPose(UIimage: UIImage(cgImage: cgImage))
        if self.isRecording {
            
            score = score + imagePoints.1//pD.getScore()
        }
        
        DispatchQueue.main.async {
            //if imagePoints.0.isEmpty { return}
            
            let frame:CGRect = CGRect(
                x: self.view.bounds.origin.x, y: self.view.bounds.origin.y,
                width: self.view.bounds.size.width, height: self.view.bounds.size.height)
            let myView = PoseView(frame: frame, points: imagePoints.0, score: self.score)
           myView.isOpaque = false
           //myView.transform = CGAffineTransform(rotationAngle: CGFloat(90 * CGFloat.pi / 180))//(Double.pi)/2)//90度回転
           self.view.subviews.last?.removeFromSuperview()//直近のsubViewだけ、描画のリセッ
           self.view.addSubview(myView)
        }
    }
}


//コーチマーク
extension ViewController2 :UIAdaptivePresentationControllerDelegate{
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        self.coachController.start(in: .window(over: self))//CoachMark  .currentWindow(of: self))
    }
}
