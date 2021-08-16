//
//  SaveVideo.swift
//  ShiranApp
//
//  Created by user on 2021/07/19.
//

import Foundation
import Firebase
import AVFoundation
//import AssetsLibrary


class SaveVideo{
    
    func saveVideo(outputFileURL: URL){
        let uid = String(Auth.auth().currentUser!.uid)//uidの設定
        //日時の指定
        let dateFormatter = DateFormatter()
        //dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "yMMddHHmm", options: 0, locale: Locale(identifier: "ja_JP"))
        //let date = dateFormatter.string(from: Date())
        //ビデオ保存用
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:SSS"
        dateFormatter.locale =  Locale(identifier: "ja_JP")
        let date = dateFormatter.string(from: Date())
        
        //FireBase  Storage
        //let localFile = URL(string: "path/to/image")!
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let riversRef = storageRef.child("\(uid) /\(date).mov")
        
        let metadata = StorageMetadata()
        metadata.contentType = "video/mov"
        
        // Upload the file to the path "images/rivers.jpg"
        riversRef.putFile(from: outputFileURL, metadata: metadata) { metadata, error in
          riversRef.downloadURL { (url, error) in
            guard url != nil else {// Uh-oh, an error occurred! エラーした場合の記述
                print("エラー　URL生成しっぱい　\(String(describing: error))")
                return
            }
            
            //ここでURLを保存できそう！！！
            let db = Firestore.firestore()
            db.collection(uid).document(date).setData([
                "date": date,
                "url": url!.absoluteString
            ]) { err in
                if let err = err {
                    print("URLと日時　Error adding document: \(err)")
                } else {
                    print("URLと日時　Document added")
                }
            }
            
            
            
          }
        }
            
        
    }
    
    // CMSampleBuffer → UIImage
    func uiImageFromCMSampleBuffer(buffer: CMSampleBuffer) -> UIImage {
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(buffer)!
        let ciImage: CIImage = CIImage(cvPixelBuffer: pixelBuffer)
        let image: UIImage = UIImage(ciImage: ciImage)
        return image
    }
    
    
    //動画を重ね合わせるためのメソッド、保存しようとするとなぜかエラーファイルが見つかりませんと出る。。。。
    func EditVideo(outputFileURL: URL){
        // 動画URLからアセットを生成
                let videoAsset: AVURLAsset = AVURLAsset(url: outputFileURL, options: nil)

                // ベースとなる動画のコンポジション作成
                let mixComposition : AVMutableComposition = AVMutableComposition()
        let compositionVideoTrack: AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: kCMPersistentTrackID_Invalid)!

                // アセットからトラックを取得
        let videoTrack: AVAssetTrack = videoAsset.tracks(withMediaType: AVMediaType.video)[0]

                // コンポジションの設定
        try! compositionVideoTrack.insertTimeRange(CMTimeRangeMake(start: CMTime.zero, duration: videoAsset.duration), of: videoTrack, at: CMTime.zero)
        compositionVideoTrack.preferredTransform = videoAsset.tracks(withMediaType: AVMediaType.video)[0].preferredTransform

                // ロゴのCALayerの作成
        let logoImage: UIImage = UIImage(named: "shiran_app_icon")!
                let logoLayer: CALayer = CALayer()
                logoLayer.contents = logoImage.cgImage
                logoLayer.frame = CGRect(x: 5, y: 25, width: 57, height: 57)
                logoLayer.opacity = 0.9

                // 動画のサイズを取得
                let videoSize: CGSize = videoTrack.naturalSize

                // 親レイヤーを作成
                let parentLayer: CALayer = CALayer()
                let videoLayer: CALayer = CALayer()
                parentLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
                videoLayer.frame = CGRect(x: 0, y: 0, width: videoSize.width, height: videoSize.height)
                parentLayer.addSublayer(videoLayer)
                parentLayer.addSublayer(logoLayer)

                // 合成用コンポジション作成
                let videoComp: AVMutableVideoComposition = AVMutableVideoComposition()
                videoComp.renderSize = videoSize
        videoComp.frameDuration = CMTimeMake(value: 1, timescale: 30)
                videoComp.animationTool = AVVideoCompositionCoreAnimationTool.init(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        print("動画合成中")
                // インストラクション作成
                let instruction: AVMutableVideoCompositionInstruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(start: CMTime.zero, duration: mixComposition.duration)
                let layerInstruction: AVMutableVideoCompositionLayerInstruction = AVMutableVideoCompositionLayerInstruction.init(assetTrack: videoTrack)
                instruction.layerInstructions = [layerInstruction]

                // インストラクションを合成用コンポジションに設定
                videoComp.instructions = [instruction]

                // 動画のコンポジションをベースにAVAssetExportを生成
                let _assetExport = AVAssetExportSession.init(asset: mixComposition, presetName: AVAssetExportPresetMediumQuality)
                // 合成用コンポジションを設定
                _assetExport?.videoComposition = videoComp
        print("ファイル生成中")
                // エクスポートファイルの設定
                let videoName: String = "test.mov"
                let _exportPath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
                let exportPath: String = _exportPath + "/" + videoName
                let exportUrl: URL = URL(fileURLWithPath: exportPath)
        _assetExport?.outputFileType = AVFileType.mov
                _assetExport?.outputURL = exportUrl
                _assetExport?.shouldOptimizeForNetworkUse = true

                // ファイルが存在している場合は削除
                if FileManager.default.fileExists(atPath: exportPath) {
                    try! FileManager.default.removeItem(atPath: exportPath)
                }

                // エクスポート実行
                /*_assetExport?.exportAsynchronously(completionHandler: {() -> Void in
                    // 端末に保存
                    let library:ALAssetsLibrary = ALAssetsLibrary()
                    if library.videoAtPathIs(compatibleWithSavedPhotosAlbum: exportUrl) {
                        library.writeVideoAtPath(toSavedPhotosAlbum: self.delegate.exportUrl, completionBlock: nil)
                    }
                })*/
        print("このタイミングで　ビデオセーブ")
        SaveVideo().saveVideo(outputFileURL: exportUrl)//save to Firebase
    }
    
}
