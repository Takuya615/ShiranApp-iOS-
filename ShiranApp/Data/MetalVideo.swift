//
//  MetalVideo.swift
//  ShiranApp
//
//  Created by user on 2021/08/19.
//
/*
import AVFoundation

class MetalVideo{
    
    
    func metal(device: MTLDevice, sampleBuffer: CMSampleBuffer){
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {return}
        var textureCache : CVMetalTextureCache?
        CVMetalTextureCacheCreate(kCFAllocatorDefault, nil, device, nil, &textureCache)
        
        
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)

        var imageTexture: CVMetalTexture? = CVMetalTexture()

        let result = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, textureCache, imageBuffer, nil, pixelFormat, width, height, 0, &imageTexture)
        
        
        let texture = CVMetalTextureGetTexture(imageTexture)
        
    }
}*/
