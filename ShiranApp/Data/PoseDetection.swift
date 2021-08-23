//
//  PoseDetection.swift
//  ShiranApp
//
//  Created by user on 2021/08/17.
//

import Foundation
import MLKit


class PoseDetection{
    
    func getPose(UIimage: UIImage) -> [CGPoint]{
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
          return imagePoints
        }
        guard let detectedPoses = results, !detectedPoses.isEmpty else {
          print("Pose detector returned no results.")
          return imagePoints
        }
     

        // Success. Get pose landmarks here.
        for pose in detectedPoses {
            let list = poseList(pose: pose)
            for i in list {
                imagePoints.append(CGPoint(x: i.x, y: i.y))
            }
        }
        
        return imagePoints
    }
    
    
    
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




//Imageからポーズ検出し、その[CGPoints]をもとに
import Vision
protocol PoseManagerDelegate: AnyObject {
    //func didRecieve(_ observation: VNHumanBodyPoseObservation)
    func makePose(points: [CGPoint])
}
class PoseManager: NSObject {

    weak var delegate: PoseManagerDelegate?
    func push(sampleBuffer: CMSampleBuffer){
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        let ciimage : CIImage = CIImage(cvPixelBuffer: imageBuffer)
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(ciimage, from: ciimage.extent)!
        //resnet50ModelManager.performRequet(with: cgImage)
        let poseDetection = PoseDetection()
        let imagePoints = poseDetection.getPose(UIimage: UIImage(cgImage: cgImage))
        
        
        delegate?.makePose(points: imagePoints)
    }
}
