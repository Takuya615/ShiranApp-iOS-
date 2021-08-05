//
//  MovieCreator.swift
//  ShiranApp
//
//  Created by user on 2021/07/31.
//

import Foundation
import AVFoundation
import UIKit

class MovieCreator: NSObject {
    
    func create(images:[UIImage],size:CGSize,time:Int,completion:(URL)->()){
        
        //保存先のURL
        guard let url = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).mp4") else {
            fatalError("URL error")
        }
        // AVAssetWriter
        guard let videoWriter = try? AVAssetWriter(outputURL: url, fileType: .mp4) else {
            fatalError("AVAssetWriter error")
        }
        
        //画像サイズを変える
        let width = size.width
        let height = size.height
        
        // AVAssetWriterInput
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ] as [String : Any]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings as [String : AnyObject])
        videoWriter.add(writerInput)
        
        // AVAssetWriterInputPixelBufferAdaptor
        let adaptor = AVAssetWriterInputPixelBufferAdaptor(
            assetWriterInput: writerInput,
            sourcePixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32ARGB),
                kCVPixelBufferWidthKey as String: width,
                kCVPixelBufferHeightKey as String: height,
                ]
        )
        
        writerInput.expectsMediaDataInRealTime = true
        
        // 動画の生成開始
        
        // 生成できるか確認
        if (!videoWriter.startWriting()) {
            // error
            print("error videoWriter startWriting")
        }
        
        // 動画生成開始
        videoWriter.startSession(atSourceTime: CMTime.zero)
        
        // pixel bufferを宣言
        var buffer: CVPixelBuffer? = nil
        
        // 現在のフレームカウント
        var frameCount = 0
        
        // 各画像の表示する時間
        let durationForEachImage = time
        
        // FPS
        let fps: __int32_t = 60
        
        // 全画像をbufferに埋め込む
        for image in images {
            
            if (!adaptor.assetWriterInput.isReadyForMoreMediaData) {
                break
            }
            
            // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
            let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(durationForEachImage)), timescale: fps)
            //時間経過を確認(確認用)
            let second = CMTimeGetSeconds(frameTime)
            print(second)
            
            guard let resize = image.resize(size: size) else { return }
            buffer = self.pixelBufferFromCGImage(cgImage: resize.cgImage!)
            
            // 生成したBufferを追加
            if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
                // Error!
                print("adaptError")
                print(videoWriter.error!)
            }
            
            frameCount += 1
        }
        
        // 動画生成終了
        writerInput.markAsFinished()
        videoWriter.endSession(atSourceTime: CMTimeMake(value: Int64((__int32_t(frameCount)) *  __int32_t(durationForEachImage)), timescale: fps))
        videoWriter.finishWriting(completionHandler: {
            // Finish!
            print("movie created.")
        })
        
        completion(url)
        
    }
    
    func pixelBufferFromCGImage(cgImage: CGImage) -> CVPixelBuffer {
        
        let options = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]
        
        var pxBuffer: CVPixelBuffer? = nil
        
        let width = cgImage.width
        let height = cgImage.height
        
        CVPixelBufferCreate(kCFAllocatorDefault,
                            width,
                            height,
                            kCVPixelFormatType_32ARGB,
                            options as CFDictionary?,
                            &pxBuffer)
        
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        let pxdata = CVPixelBufferGetBaseAddress(pxBuffer!)
        
        let bitsPerComponent: size_t = 8
        let bytesPerRow: size_t = 4 * width
        
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,
                                height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        
        context?.draw(cgImage, in: CGRect(x:0, y:0, width:CGFloat(width),height:CGFloat(height)))
        
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pxBuffer!
    }
    
}


extension UIImage {
    func resize(size:CGSize) -> UIImage?{
        
        //縦横がおかしくなる時は一度書き直すと良いらしい
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in:CGRect(x:0,y:0,width:self.size.width,height:self.size.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // リサイズ処理
        let origWidth = self.size.width
        let origHeight = self.size.height
        
        var resizeWidth:CGFloat = 0
        var resizeHeight:CGFloat = 0
        if (origWidth < origHeight) {
            resizeWidth = size.width
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = size.height
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSize(width:CGFloat(resizeWidth), height:CGFloat(resizeHeight))
        UIGraphicsBeginImageContext(resizeSize)
        
        self.draw(in: CGRect(x:0,y: 0,width: resizeWidth, height: resizeHeight))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        let cropRect = CGRect(x:( resizeWidth - size.width ) / 2,
                              y:( resizeHeight - size.height) / 2,
                              width:size.width,
                              height:size.height)
        
        if let cropRef = resizeImage?.cgImage {
            cropRef.cropping(to: cropRect)
            let cropImage = UIImage(cgImage: cropRef)
            return cropImage
        }else {
            print("error!")
            return nil
        }
    }
    
    func resizeMaintainDirection(size:CGSize) -> UIImage?{
        
        //縦横がおかしくなる時は一度書き直すと良いらしい
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        self.draw(in:CGRect(x:0,y:0,width:self.size.width,height:self.size.height))
        guard let image = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        
        // リサイズ処理
        let origWidth = image.size.width
        let origHeight = image.size.height
        
        var resizeWidth:CGFloat = 0
        var resizeHeight:CGFloat = 0
        if (origWidth < origHeight) {
            resizeWidth = size.width
            resizeHeight = origHeight * resizeWidth / origWidth
        } else {
            resizeHeight = size.height
            resizeWidth = origWidth * resizeHeight / origHeight
        }
        
        let resizeSize = CGSize(width:resizeWidth, height:resizeHeight)
        UIGraphicsBeginImageContext(resizeSize)
        
        image.draw(in: CGRect(x:0,y: 0,width: resizeWidth, height: resizeHeight))
        
        let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // 切り抜き処理
        let cropRect = CGRect(x:( resizeWidth - size.width ) / 2,
                              y:( resizeHeight - size.height) / 2,
                              width:size.width,
                              height:size.height)
        
        if let cropRef = resizeImage?.cgImage {
            cropRef.cropping(to: cropRect)
            let cropImage = UIImage(cgImage: cropRef)
            return cropImage
        }else {
            print("error!")
            return nil
        }
    }
}
