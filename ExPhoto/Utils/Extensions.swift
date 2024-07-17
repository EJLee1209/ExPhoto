//
//  Extensions.swift
//  ExPhoto
//
//  Created by 굿소프트_이은재 on 6/19/24.
//

import UIKit
extension UIImage {
    /**
     * 이미지 리사이징
     * 주어진 너비를 기준으로 높이를 계산하여 리사이징
     * - Author: EJLee1209
     * - Parameters:
     *   - newWidth : 이미지 너비
     * - Returns: 리사이징된 이미지
     */
    func resize(newWidth: CGFloat) -> UIImage {
        let scale = newWidth / self.size.width
        let newHeight = self.size.height * scale
        
        let size = CGSize(width: newWidth, height: newHeight)
        let render = UIGraphicsImageRenderer(size: size)
        let renderImage = render.image { context in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
        return renderImage
    }
    
    func fixOrientation() -> UIImage {
        guard let cgImage = self.cgImage else {
            return self;
        }
        
        if self.imageOrientation == .up {
            return self;
        }
        
        var transform = CGAffineTransform.identity;
        
        switch self.imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height);
            transform = transform.rotated(by: CGFloat(M_PI));
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height);
            transform = transform.rotated(by: CGFloat(-M_PI_2));
        case .up, .upMirrored:
            break;
        }
        
        switch self.imageOrientation {
        case .upMirrored, .downMirrored:
            transform.translatedBy(x: self.size.width, y: 0);
            transform.scaledBy(x: -1, y: 1);
        case .leftMirrored, .rightMirrored:
            transform.translatedBy(x: self.size.height, y: 0);
            transform.scaledBy(x: -1, y: 1);
        case .up, .down, .left, .right:
            break;
        }
        
        if let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: cgImage.colorSpace!, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) {
            ctx.concatenate(transform);
            
            switch self.imageOrientation {
            case .left, .leftMirrored, .right, .rightMirrored:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.height, height: self.size.width));
            default:
                ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height));
            }
            
            if let finalImage = ctx.makeImage() {
                return (UIImage(cgImage: finalImage));
            }
        }
        
        // something failed -- return original
        return self;
    }
    
    func crop(toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage?
    {
        let imageViewScale = max(self.size.width / viewWidth,
                                 self.size.height / viewHeight)
        
        // Scale cropRect to handle images larger than shown-on-screen size
        let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                              y:cropRect.origin.y * imageViewScale,
                              width:cropRect.size.width * imageViewScale,
                              height:cropRect.size.height * imageViewScale)
        
        // Perform cropping in Core Graphics
        guard let cutImageRef: CGImage = self.cgImage?.cropping(to:cropZone)
        else {
            return nil
        }
        
        // Return image to UIImage
        let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
        return croppedImage
    }
}
