//
//  VideoWriter.swift
//  naruhodo
//
//  Created by FUJIKI TAKESHI on 2014/11/11.
//  Copyright (c) 2014年 Takeshi Fujiki. All rights reserved.
//
/*
import Foundation
import AVFoundation
import AssetsLibrary

class VideoWriter : NSObject{
    var fileWriter: AVAssetWriter!
    var videoInput: AVAssetWriterInput!
    //var audioInput: AVAssetWriterInput!
    
    

    init( height:Int, width:Int){//}, channels:Int, samples:Float64){
        
        //ファイルURL生成
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMddHHmmSSS"
        dateFormatter.locale =  Locale(identifier: "ja_JP")
        let date = dateFormatter.string(from: Date())
        let fileUrl = FileManager.default.temporaryDirectory.appendingPathComponent(date)
        
        
        fileWriter = try? AVAssetWriter(outputURL: fileUrl , fileType: AVFileType.mov)
        
        let videoOutputSettings: [String: Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : width,
            AVVideoHeightKey : height
        ];
        videoInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoOutputSettings)
        videoInput.expectsMediaDataInRealTime = true
        fileWriter.add(videoInput)
        
        let audioOutputSettings: [String: Any] = [
            AVFormatIDKey : Int(kAudioFormatMPEG4AAC),
            AVNumberOfChannelsKey : 1,//channels,
            AVSampleRateKey : 44100,//samples,
            AVEncoderBitRateKey : 128000
        ]
        //audioInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioOutputSettings)
        //audioInput.expectsMediaDataInRealTime = true
        //fileWriter.add(audioInput)
    }
    
    func write(sample: CMSampleBuffer, isVideo: Bool){
        if CMSampleBufferDataIsReady(sample) {
            if fileWriter.status == AVAssetWriter.Status.unknown {
                //Logger.log("Start writing, isVideo = \(isVideo), status = \(fileWriter.status.rawValue)")
                print("Start writing, isVideo = \(isVideo), status = \(fileWriter.status.rawValue)")
                let startTime = CMSampleBufferGetPresentationTimeStamp(sample)
                fileWriter.startWriting()
                fileWriter.startSession(atSourceTime: startTime)
                
            }
            if fileWriter.status == AVAssetWriter.Status.failed {
                //Logger.log("Error occured, isVideo = \(isVideo), status = \(fileWriter.status.rawValue), \(fileWriter.error!.localizedDescription)")
                print("Error occured, isVideo = \(isVideo), status = \(fileWriter.status.rawValue), \(fileWriter.error!.localizedDescription)")
                return
            }
            if isVideo {
                if videoInput.isReadyForMoreMediaData {
                    videoInput.append(sample)
                }
            }else{
                //if audioInput.isReadyForMoreMediaData {
                //    audioInput.append(sample)
                //}
            }
        }
    }
    func write2(sampleV: [CMSampleBuffer]/*, sampleA: [CMSampleBuffer]*/){//          ボツ
        
        let queue = DispatchQueue(label: "object-detection-queue2")
        videoInput.requestMediaDataWhenReady(on: queue, using: {
            print("いま準備できた")
            
            if CMSampleBufferDataIsReady(sampleV[0]) {print("No Ready");return}
            
            if self.fileWriter.status == AVAssetWriter.Status.unknown {
                    //Logger.log("Start writing, isVideo = \(isVideo), status = \(fileWriter.status.rawValue)")
                print("Start writing,  status = \(self.fileWriter.status.rawValue)")
                    let startTime = CMSampleBufferGetPresentationTimeStamp(sampleV[0])
                self.fileWriter.startWriting()
                self.fileWriter.startSession(atSourceTime: startTime)
                    
                }
            if self.fileWriter.status == AVAssetWriter.Status.failed {
                    //Logger.log("Error occured, isVideo = \(isVideo), status = \(fileWriter.status.rawValue), \(fileWriter.error!.localizedDescription)")
                print("Error occured, status = \(self.fileWriter.status.rawValue), \(self.fileWriter.error!.localizedDescription)")
                    return
                }
            for sample in sampleV {
                if self.videoInput.isReadyForMoreMediaData {
                    self.videoInput.append(sample)
                }
            }
            self.finish()
        })
        
    }
    
    func finish(){
        videoInput.markAsFinished()
        fileWriter.finishWriting {
            let url = self.fileWriter.outputURL
            SaveVideo().saveVideo(outputFileURL: url)
        }
    }
    //func finish(callback: ()@escaping  -> Void){fileWriter.finishWritingWithCompletionHandler(callback)}
}
*/
