//
//  ViewController.swift
//  ImageColorHandle
//
//  Created by 周伟克 on 2018/10/30.
//  Copyright © 2018 周伟克. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {
    
    
    @IBOutlet weak var reversalColorImageView: UIImageView!
    @IBOutlet weak var grayImageView: UIImageView!
    var ctxA: CGContext!
    var ctxB: CGContext!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        testAuto()
//        testManual()
        
    }
    
    
    /// 测试自动上下文自动申请内存
    func testAuto() {
        
        let image = UIImage(named: "girl2.jpg")!
        ctxA = image.convertToData()!
        UIImage.traversePixels(ctxA) { (red, green, blue, alpha) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar)? in
            
            let newColorInfo = Int(red) * 77 / 255 + Int(green) * 151 / 255 + Int(blue) * 88 / 255
            let gray = CUnsignedChar(newColorInfo > 255 ? 255 : newColorInfo)
            return (gray, gray, gray, alpha)
        }
        grayImageView.image = UIImage(cgImage: ctxA.makeImage()!)
        
        ctxB = image.convertToData()!
        UIImage.traversePixels(ctxB) { (red, green, blue, alpha) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar)? in
            return (255 - red, 255 - green, 255 - blue, alpha)
        }
        reversalColorImageView.image = UIImage(cgImage: ctxB.makeImage()!)
    }
    
    /// 测试手动申请内存
    func testManual() {
        
        let image = UIImage(named: "girl2.jpg")!
        var data = image.convertToData44()!
        UIImage.traversePixels(data, source: image.cgImage!) { (red, green, blue, alpha) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar)? in

            let newColorInfo = Int(red) * 77 / 255 + Int(green) * 151 / 255 + Int(blue) * 88 / 255
            let gray = CUnsignedChar(newColorInfo > 255 ? 255 : newColorInfo)
            return (gray, gray, gray, alpha)

        }
        grayImageView.image = UIImage.render(data,
                                             source: image.cgImage!)

        free(data)
        data = image.convertToData2()!
        UIImage.traversePixels44(data, source: image.cgImage!) { (red, green, blue, alpha) -> (CUnsignedChar, CUnsignedChar, CUnsignedChar, CUnsignedChar)? in
            return (255 - red, 255 - green, 255 - blue, alpha)
        }
        reversalColorImageView.image = UIImage.render44(data,
                                                      source: image.cgImage!)
        free(data)
    }
}
