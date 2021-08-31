//
//  Sounds.swift
//  ShiranApp
//
//  Created by user on 2021/08/04.
//

import Foundation
import AudioToolbox


class SystemSounds{
    
    
    func BeginVideoRecording(){
        var soundIdRing:SystemSoundID = 1117
        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil){
                    AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                    AudioServicesPlaySystemSound(soundIdRing)
                }
    }
    
    func EndVideoRecording(){
        var soundIdRing:SystemSoundID = 1118
        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil){
                    AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
                    AudioServicesPlaySystemSound(soundIdRing)
                }
    }
    
    // バイブレータ
    func buttonVib(_ sender : Any) {
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
    }
    
    // mp3 ファイルの再生
    @IBAction func buttonSampleWav(_ sender : Any) {
        var soundIdRing:SystemSoundID = 0
        if let soundUrl:NSURL = NSURL(fileURLWithPath:
            Bundle.main.path(forResource: "cheers", ofType:"mp3")!) as NSURL?{
            AudioServicesCreateSystemSoundID(soundUrl, &soundIdRing)
            AudioServicesPlaySystemSound(soundIdRing)
        }
    }
}
