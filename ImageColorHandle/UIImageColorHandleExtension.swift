//
//  UIImageColorHandleExtension.swift
//  ImageColorHandle
//
//  Created by 周伟克 on 2018/10/30.
//  Copyright © 2018 周伟克. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
        
    /// 采用自动申请内存的方式把图片信息存入位图上下文中
    func convertToDataAutoMallocMemory() -> CGContext? {
        
        guard let cgImage = cgImage else {
            return nil
        }
        //let data = malloc(cgImage.height * cgImage.bytesPerRow)
        let ctx = CGContext(data: nil, width: cgImage.width,
                            height: cgImage.height,
                            bitsPerComponent: cgImage.bitsPerComponent,
                            bytesPerRow: cgImage.bytesPerRow,
                            space: cgImage.colorSpace!,
                            bitmapInfo: cgImage.bitmapInfo.rawValue)!
        ctx.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return ctx
    }
    
    /// 采用手动申请内存的方式将图片信息存入位图上下文中
    func convertToDataManualMallocMemory() -> UnsafeMutableRawPointer? {
        
        guard let cgImage = cgImage else {
            return nil
        }
        let length = cgImage.height * cgImage.bytesPerRow
        let data = malloc(length)
        memset(data, 0, length)
        let ctx = CGContext(data: data, width: cgImage.width,
                            height: cgImage.height,
                            bitsPerComponent: cgImage.bitsPerComponent,
                            bytesPerRow: cgImage.bytesPerRow,
                            space: cgImage.colorSpace!,
                            bitmapInfo: cgImage.bitmapInfo.rawValue)!
        ctx.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return data
    }
    
    /**
     * 遍历位图上下文申请内存的所有颜色信息，并且抛给调用者，再对应指针位置存储新的颜色信息
     para ctx: 位图上下文
     handler: 处理闭包
     */
    static func traversePixels(_ ctx: CGContext,
                               handler: ((CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar))?) {
        
        guard let data = ctx.data else {
            return
        }
        for row in 0 ..< ctx.height {
            for column in 0 ..< ctx.width {
                let bitMapIndex = (ctx.width * row + column) * 4
                let red = data.load(fromByteOffset: bitMapIndex,
                                    as: CUnsignedChar.self)
                let green = data.load(fromByteOffset: bitMapIndex + 1,
                                      as: CUnsignedChar.self)
                let blue = data.load(fromByteOffset: bitMapIndex + 2,
                                     as: CUnsignedChar.self)
                let alpha = data.load(fromByteOffset: bitMapIndex + 3, as: CUnsignedChar.self)
                
                // 将修改后的RGBA存入这块内存
                if let newRGBA = handler?(red, green, blue, alpha) {
                    data.storeBytes(of: newRGBA.0, toByteOffset: bitMapIndex,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.1, toByteOffset: bitMapIndex + 1,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.2, toByteOffset: bitMapIndex + 2,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.3, toByteOffset: bitMapIndex + 3,
                                    as: CUnsignedChar.self)
                }
            }
        }
    }
    
    /**
     * 遍历位图上下文申请内存的所有颜色信息，并且抛给调用者，再对应指针位置存储新的颜色信息
     para data: 位图上下文
     para source: 原图片文件
     handler: 处理闭包
     */
    static func traversePixels(_ data: UnsafeMutableRawPointer,
                               source: CGImage,
                               handler: ((CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar))?) {
            
        for row in 0 ..< source.height {
            for column in 0 ..< source.width {
                let bitMapIndex = (source.width * row + column) * 4
                let red = data.load(fromByteOffset: bitMapIndex,
                                    as: CUnsignedChar.self)
                let green = data.load(fromByteOffset: bitMapIndex + 1,
                                      as: CUnsignedChar.self)
                let blue = data.load(fromByteOffset: bitMapIndex + 2,
                                     as: CUnsignedChar.self)
                let alpha = data.load(fromByteOffset: bitMapIndex + 3, as: CUnsignedChar.self)

                // 将修改后的RGBA存入这块内存
                if let newRGBA = handler?(red, green, blue, alpha) {
                    data.storeBytes(of: newRGBA.0, toByteOffset: bitMapIndex,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.1, toByteOffset: bitMapIndex + 1,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.2, toByteOffset: bitMapIndex + 2,
                                    as: CUnsignedChar.self)
                    data.storeBytes(of: newRGBA.3, toByteOffset: bitMapIndex + 3,
                                    as: CUnsignedChar.self)
                }
            }
        }
    }

    /// 渲染位图上下文
    static func render(_ data: UnsafeMutableRawPointer, source: CGImage) -> UIImage? {
        
        let size = source.bytesPerRow * source.height
        let provider = CGDataProvider(dataInfo: nil, data: data, size: size) { (dataInfo, data, size) in
        }
        let newCGImage = CGImage(width: source.width,
                                 height: source.height,
                                 bitsPerComponent: source.bitsPerComponent,
                                 bitsPerPixel: source.bitsPerPixel,
                                 bytesPerRow: source.bytesPerRow,
                                 space: source.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                                 bitmapInfo: source.bitmapInfo,
                                 provider: provider!,
                                 decode: source.decode,
                                 shouldInterpolate: source.shouldInterpolate,
                                 intent: source.renderingIntent)
        if let newCGImage = newCGImage {
            return UIImage(cgImage: newCGImage)
        }
        return nil
    }
}

