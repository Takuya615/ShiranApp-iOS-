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
    
    
    override init() {
            
        super.init()
    }
        
    
    func create(images:[UIImage],size:CGSize){//,completion:(URL)->()){
        if images.isEmpty{print("なし");return}
            //保存先のURL
        let url = NSURL(fileURLWithPath:NSTemporaryDirectory()).appendingPathComponent("\(NSUUID().uuidString).mp4")
        // AVAssetWriter
        guard let videoWriter = try? AVAssetWriter(outputURL: url!, fileType: AVFileType.mov) else {
            fatalError("AVAssetWriter error")
        }
        
        //画像サイズを変える
        let width = images[0].size.width
        let height = images[0].size.height
        
        // AVAssetWriterInput
        let outputSettings = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ] as [String : Any]
        let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings as [String :AnyObject])
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
        let durationForEachImage = 10//time
            
            // FPS
        let fps: __int32_t = 60
            
        
        let queue = DispatchQueue(label: "object-detection-queue3")
        adaptor.assetWriterInput.requestMediaDataWhenReady(on: queue, using: {
            // 全画像をbufferに埋め込む
            for image in images {
                    
                if (!adaptor.assetWriterInput.isReadyForMoreMediaData) {
                    print("ここでbreakしてる")
                    //break
                    continue
                }
                    
                    // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
                let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(durationForEachImage)), timescale: fps)
                    //時間経過を確認(確認用)
                let second = CMTimeGetSeconds(frameTime)
                print("時間系 frameTime \(frameTime) , durationForEachImage \(durationForEachImage) , frameCount \(frameCount) , second \(second) .")
                    
                //let resize = resizeImage(image: image, contentSize: size)
                    // CGImageからBufferを生成
                buffer = self.pixelBufferFromCGImage(cgImage: image.cgImage!)
                    
                    // 生成したBufferを追加
                if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
                        // Error!
                    print("adaptError")
                    print(videoWriter.error!)
                }
                    
                frameCount += 1
            }
        
            
            // 動画生成終了
            print("先にフィニッシュムーヴはいっちゃってる")
            writerInput.markAsFinished()
            videoWriter.endSession(atSourceTime: CMTimeMake(value: Int64((__int32_t(frameCount)) * __int32_t(durationForEachImage)), timescale: fps))
            videoWriter.finishWriting(completionHandler: {
                // Finish!
                print("movie created.")
            })
            SaveVideo().saveVideo(outputFileURL: url!)
            //completion(url!)
        })
        
            
        
        
            
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
                            width,height,
                            kCVPixelFormatType_32ARGB,
                            options as CFDictionary?,
                            &pxBuffer)
            
        CVPixelBufferLockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
        let pxdata = CVPixelBufferGetBaseAddress(pxBuffer!)
            
        let bitsPerComponent: size_t = 8
        let bytesPerRow: size_t = 4 * width
            
        let rgbColorSpace: CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let context = CGContext(data: pxdata,
                                width: width,height: height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
            
        context?.draw(cgImage, in: CGRect(x:0, y:0, width:CGFloat(width),height:CGFloat(height)))
            
        CVPixelBufferUnlockBaseAddress(pxBuffer!, CVPixelBufferLockFlags(rawValue: 0))
            
        return pxBuffer!
    }
        
        private func resizeImage(image:UIImage,contentSize:CGSize) -> UIImage{
            // リサイズ処理
            let origWidth  = Int(image.size.width)
            let origHeight = Int(image.size.height)
            var resizeWidth:Int = 0, resizeHeight:Int = 0
            if (origWidth < origHeight) {
                resizeWidth = Int(contentSize.width)
                resizeHeight = origHeight * resizeWidth / origWidth
            } else {
                resizeHeight = Int(contentSize.height)
                resizeWidth = origWidth * resizeHeight / origHeight
            }
            
            let resizeSize = CGSize(width:CGFloat(resizeWidth), height:CGFloat(resizeHeight))
            UIGraphicsBeginImageContext(resizeSize)
            
            image.draw(in: CGRect(x:0,y: 0,width: CGFloat(resizeWidth), height:CGFloat(resizeHeight)))
            
            let resizeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        
            return resizeImage!
        }
    
    
    
    
    func create2(images: [UIImage],completion:(URL)->()){
        // 生成した動画を保存するパス
            let tempDir = FileManager.default.temporaryDirectory
            let previewURL = tempDir.appendingPathComponent("preview006.mp4")//      要注意　ファイル名変えるべき
            
            // 既にファイルがある場合は削除する
            let fileManeger = FileManager.default
            if fileManeger.fileExists(atPath: previewURL.path) {
                try! fileManeger.removeItem(at: previewURL)
            }else{
                print("このURLは　新規ファイルのものです")
            }
            
            // 最初の画像から動画のサイズ指定する
            let size = images.first!.size
            
            guard let videoWriter = try? AVAssetWriter(outputURL: previewURL, fileType: AVFileType.mp4) else {
                abort()
            }

            let outputSettings: [String : Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: size.width,
                AVVideoHeightKey: size.height
            ]
            
            let writerInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: outputSettings)
            videoWriter.add(writerInput)
            
        /*let queue = DispatchQueue(label: "object-detection-queue")
        writerInput.requestMediaDataWhenReady(on: queue, using: {
            while writerInput.isReadyForMoreMediaData {
                
                    let nextSampleBuffer = copyNextSampleBuffer()//ToWrite()
                    if let nextSampleBuffer = nextSampleBuffer {
                        // you have another frame to add
                        writerInput.append(nextSampleBuffer)
                    } else {
                        // finished to add frames
                        writerInput.markAsFinished()
                        break
                    }
                }
        })*/
        
        
        
        
            let sourcePixelBufferAttributes: [String:Any] = [
                AVVideoCodecKey: Int(kCVPixelFormatType_32ARGB),
                AVVideoWidthKey: size.width,
                AVVideoHeightKey: size.height
            ]
            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: writerInput,
                sourcePixelBufferAttributes: sourcePixelBufferAttributes)
            writerInput.expectsMediaDataInRealTime = true

            // 動画生成開始
            if (!videoWriter.startWriting()) {
                print("Failed to start writing.")
                return
            }
            
            videoWriter.startSession(atSourceTime: CMTime.zero)
            
            var frameCount: Int64 = 0
        let durationForEachImage: Int64 = 10
            let fps: Int32 = 60//30//28
            
        /*while !adaptor.assetWriterInput.isReadyForMoreMediaData  {
            print("まだ用意できてねー")
            continue
        }*/
        
        
            for image in images {
                if !adaptor.assetWriterInput.isReadyForMoreMediaData {
                    print("アダプターエラー")
                    break//continue
                }
                
                let frameTime = CMTimeMake(value: frameCount * Int64(fps) * durationForEachImage, timescale: fps)
                let buffer = pixelBufferFromCGImage(cgImage: image.cgImage!)
                
                if !adaptor.append(buffer, withPresentationTime: frameTime) {
                    print("Failed to append buffer. [image : \(image)]")
                }
                
                frameCount += 1
                print("frameCount = \(frameCount)")
            }
            
            // 動画生成終了
            writerInput.markAsFinished()
            videoWriter.endSession(atSourceTime: CMTimeMake(value: frameCount * Int64(fps) * durationForEachImage, timescale: fps))
            videoWriter.finishWriting {
                print("Finish writing!")
                
            }
        completion(previewURL)
    }
}
    
    
    
    
    












    
    
    
    
    
    
    
    
    
    
    
    
    /*
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
        let videoOutputSettings: [String : Any] = [
            AVVideoCodecKey: AVVideoCodecType.h264,
            AVVideoWidthKey: width,
            AVVideoHeightKey: height
            ]// as [String : Any]
        let videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings as [String : AnyObject])
        videoWriterInput.expectsMediaDataInRealTime = true
        videoWriter.add(videoWriterInput)
        
        
        
        
        // 動画の生成開始
        
        // 生成できるか確認
        if (!videoWriter.startWriting()) {
            // error
            print("error videoWriter startWritingビデオ生成にしっぱい")
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
        let fps: __int32_t = 15//60
        
        // 全画像をbufferに埋め込む
        for image in images {
            
            
            
            // 動画の時間を生成(その画像の表示する時間/開始時点と表示時間を渡す)
            let frameTime: CMTime = CMTimeMake(value: Int64(__int32_t(frameCount) * __int32_t(durationForEachImage)), timescale: fps)
            //時間経過を確認(確認用)
            let second = CMTimeGetSeconds(frameTime)
            print(second)
            
            guard let resize = image.resize(size: size) else { return }
            //let newone = image.rotatedBy(degree: 90)
            //let newOne = image.rotatedBy(degree: 90)
            buffer = self.pixelBufferFromCGImage(cgImage: resize.cgImage!)
            
            // 生成したBufferを追加
            if (!adaptor.append(buffer!, withPresentationTime: frameTime)) {
                // Error!
                print("adaptErroradアダプトエラー")
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
 */


