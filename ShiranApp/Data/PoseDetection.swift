//
//  PoseDetection.swift
//  ShiranApp
//
//  Created by user on 2021/07/19.
//







//あいあいあいあいいあいあいあいあいいあいあいあいいあいあいあいあいいあいあいあいいあいあいあいあいあいいあ












/*
import Foundation
import AVFoundation
import Firebase
//import MLKit

class PoseDetection {
    
    //private var samples: [UIImage] = []
    
    func pose(uiimage:UIImage) -> UIImage{
        // Base pose detector with streaming, when depending on the PoseDetection SDK
        let options = PoseDetectorOptions()
        options.detectorMode = .stream
        let poseDetector = PoseDetector.poseDetector(options: options)
            
        let image = VisionImage(image: uiimage)
        //VisionImage.orientation = image.imageOrientation
        
        var results: [Pose]?
        do {
          results = try poseDetector.results(in: image)
        } catch let error {
          print("Failed to detect pose with error: \(error.localizedDescription).")
          return UIImage()
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
          print("Pose detector returned no results.")
          return UIImage()
        }
        
        var x_list: [CGFloat] = []
        var y_list: [CGFloat] = []
        for pose in detectedPoses {
            let leftAnkleLandmark = pose.landmark(ofType: .leftAnkle)
            let leftHipLandmark = pose.landmark(ofType: .leftHip)
            let lA = leftAnkleLandmark.position
            let lH =  leftHipLandmark.position
            print("左かたの座標\(lA) 左こし\(lH)")
                
            x_list.append(lH.x)
            x_list.append(lA.x)
                        
            y_list.append(lH.y)
            y_list.append(lA.y)
        }
        print("描画に挑戦")
        let img = self.makeUIImage(uiImage: uiimage, xlist: x_list, ylist: y_list)
        return img
    }
    
    
    func poseFromBuffer(sampleBuffer: CMSampleBuffer,cameraPosition: AVCaptureDevice.Position) -> ([CGFloat],[CGFloat]){
        // Base pose detector with streaming, when depending on the PoseDetection SDK
        print("PoseDetectionの開始")
            let options = PoseDetectorOptions()
            options.detectorMode = .stream
            let poseDetector = PoseDetector.poseDetector(options: options)
            
        
        let image = VisionImage(buffer: sampleBuffer)
        image.orientation = imageOrientation(
          deviceOrientation: UIDevice.current.orientation,
          cameraPosition: cameraPosition)
        
        
        
        var results: [Pose]?
        do {
          results = try poseDetector.results(in: image)
        } catch let error {
          print("Failed to detect pose with error: \(error.localizedDescription).")
            return ([],[])
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
          print("Pose detector returned no results.")
          return ([],[])
        }

        
        var x_list: [CGFloat] = []
        var y_list: [CGFloat] = []
        
        
        for pose in detectedPoses {
            
            let poses:[Vision3DPoint] = [
                pose.landmark(ofType: .nose).position,//0
                pose.landmark(ofType: .leftShoulder).position,
                pose.landmark(ofType: .rightShoulder).position,
                pose.landmark(ofType: .leftElbow).position,
                pose.landmark(ofType: .rightElbow).position,
                pose.landmark(ofType: .leftWrist).position,//5
                pose.landmark(ofType: .rightWrist).position,
                pose.landmark(ofType: .leftHip).position,
                pose.landmark(ofType: .rightHip).position,
                pose.landmark(ofType: .leftKnee).position,
                pose.landmark(ofType: .rightKnee).position,//10
                pose.landmark(ofType: .leftAnkle).position,
                pose.landmark(ofType: .rightAnkle).position,
                pose.landmark(ofType: .leftPinkyFinger).position,
                pose.landmark(ofType: .rightPinkyFinger).position,
                pose.landmark(ofType: .leftIndexFinger).position,//15
                pose.landmark(ofType: .rightIndexFinger).position
                
            ]
            
            
            for el in poses {
                x_list.append(el.x)
                y_list.append(el.y)
            }
            //print("左かたの座標\(lA) 左こし\(lH)")
              
        }
        
        //print("描画に挑戦")
        //let img = self.makeUIImage(uiImage: image, xlist: x_list, ylist: y_list)
        return (x_list,y_list)
    }
    func imageOrientation(
      deviceOrientation: UIDeviceOrientation,
      cameraPosition: AVCaptureDevice.Position
    ) -> UIImage.Orientation {
        switch deviceOrientation {
      case .portrait:
        return cameraPosition == .front ? .leftMirrored : .right
      case .landscapeLeft:
        return cameraPosition == .front ? .downMirrored : .up
      case .portraitUpsideDown:
        return cameraPosition == .front ? .rightMirrored : .left
      case .landscapeRight:
        return cameraPosition == .front ? .upMirrored : .down
      case .faceDown, .faceUp, .unknown:
        return .up
        default: print("エラー かめらの方向を取得できなかった")
        return .up
        }
    }
        
    
    
    
    
    func makeUIImage(uiImage: UIImage, xlist: [CGFloat],ylist: [CGFloat]) -> UIImage{
            //var image: UIImage = UIImage()
            //let imageWidth = uiImage.size.width
            //let imageHeight = uiImage.size.height
            //let rect = CGRect(x:0, y:0, width:imageWidth, height:imageHeight)
            
            UIGraphicsBeginImageContext(uiImage.size)
            uiImage.draw(at: CGPoint.zero)
            guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
            context.setLineWidth(50.0)
            context.setStrokeColor(UIColor.blue.cgColor)
            context.move(to: CGPoint(x: xlist[0], y: ylist[0]))
            context.addLine(to: CGPoint(x: xlist[1], y: ylist[1]))
            context.strokePath()
            // Context 終了
            
            guard let resultImage = UIGraphicsGetImageFromCurrentImageContext() else { return UIImage() }
            UIGraphicsEndImageContext()
            return resultImage
    }
        
}
*/
