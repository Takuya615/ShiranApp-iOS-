//
//  PoseDetection.swift
//  ShiranApp
//
//  Created by user on 2021/08/17.
//

import Foundation
import MLKit


class OriginalPoseDetection{
    
    var score: CGFloat = 0
    var prePoints: [CGPoint] = []
    
    //リアルタイム処理
    func getPose(UIimage: UIImage) -> ([CGPoint],CGFloat){
        var imagePoints: [CGPoint] = []
        let options = PoseDetectorOptions()
        options.detectorMode = .stream
        
        let poseDetector = PoseDetector.poseDetector(options: options)
        let image = VisionImage(image: UIimage)
        //visionImage.orientation = image.imageOrientation
        
        var results: [Pose]?
        do {
          results = try poseDetector.results(in: image)
        } catch let error {
          print("Failed to detect pose with error: \(error.localizedDescription).")
          return (imagePoints,0)
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
          print("Pose detector returned no results.")
          return (imagePoints,0)
        }
     
        // Success. Get pose landmarks here.
        for pose in detectedPoses {
            let list = poseList(pose: pose)
            for i in list {
                imagePoints.append(CGPoint(x: i.x, y: i.y))
            }
        }
        
        if prePoints.isEmpty || imagePoints.isEmpty {prePoints = imagePoints; return (imagePoints,0)}
        
        //var coun = 0
        for i in 0 ... imagePoints.count-1 {
            var xDis = abs(imagePoints[i].x - prePoints[i].x)
            var yDis = abs(imagePoints[i].y - prePoints[i].y)
            if xDis < 5 { /*coun=coun+1; */xDis = 0 }//全く動いていなければスコアは0
            if yDis < 5 { /*coun=coun+1; */yDis = 0 }
            score = xDis + yDis
        }
        //print("カット率 \(coun)");
        
        prePoints = imagePoints
        return (imagePoints,score)
    }
    
    func getScore() -> CGFloat{
        return score
    }
    
    //非同期処理の場合
    func getPose2(UIimage: UIImage) -> [CGPoint]{
        print("ポーズ検出開始！！")
        var imagePoints: [CGPoint] = []
        let options = PoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
        let image = VisionImage(image: UIimage)
        //visionImage.orientation = image.imageOrientation
        poseDetector.process(image) { detectedPoses, error in
          guard error == nil else {
            // Error.
            print("えらー　その１\(error.debugDescription)")
            return
          }
            guard !detectedPoses!.isEmpty else {
            // No pose detected.
                print("えらー　その２")
            return
          }
          // Success. Get pose landmarks here.
            for pose in detectedPoses! {
                let list = self.poseList(pose: pose)
                for i in list {
                    imagePoints.append(CGPoint(x: i.x, y: i.y))
                }
            }
        }
        print("作られたimagePointsは　\(imagePoints)")
     return imagePoints
    }
    
    func poseList(pose:Pose) -> [Vision3DPoint]{
        return
            [
            pose.landmark(ofType: .rightShoulder).position,
            pose.landmark(ofType: .rightElbow).position,
            pose.landmark(ofType: .rightWrist).position,
            pose.landmark(ofType: .rightHip).position,
            pose.landmark(ofType: .rightKnee).position,
            pose.landmark(ofType: .rightAnkle).position,
                
            pose.landmark(ofType: .leftShoulder).position,
            pose.landmark(ofType: .leftElbow).position,
            pose.landmark(ofType: .leftWrist).position,
            pose.landmark(ofType: .leftHip).position,
            pose.landmark(ofType: .leftKnee).position,
            pose.landmark(ofType: .leftAnkle).position,
        ]
        
    }
          
}



import UIKit
class PoseView: UIView {
    var points: [CGPoint]
    var score: CGFloat
    
    init(frame: CGRect, points: [CGPoint], score: CGFloat) {
        self.points = points
        self.score = score
        super .init(frame: frame)
        self.isUserInteractionEnabled = false // 重なったViewでもボタン押せる
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        
        "Score  \(Int(score))".draw(at: CGPoint(x: rect.width * 0.1, y: rect.height * 0.9), withAttributes: [
            NSAttributedString.Key.foregroundColor : UIColor.blue,
            NSAttributedString.Key.font : UIFont.systemFont(ofSize: 40),
        ])
        
        if points.isEmpty {print("nil");return}
        let t: CGFloat = 1.0
        
        for point in points {
            if point.x == 0 {continue}
            let circle = UIBezierPath(
                arcCenter: CGPoint(x: point.x*t, y: point.y*t),//                   *t  *t
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
            path.move(to: CGPoint(x: points[startP[i]].x*t, y: points[startP[i]].y*t))//              *t  *t
            path.addLine(to: CGPoint(x: points[endP[i]].x*t, y: points[endP[i]].y*t))//               *t  *t
        }
        path.lineWidth = 8.0 // 線の太さ
        UIColor.yellow.setStroke() // 色をセット
        path.stroke()
        
        
        
        
        
    }
    
    
}
