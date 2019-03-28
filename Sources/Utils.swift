import Foundation

import ARKit

public func floatBetween(_ first: Float,  and second: Float) -> Float {
    // random float between upper and lower bound (inclusive)
    return (Float(arc4random()) / Float(UInt32.max)) * (first - second) + second
}

public extension SCNVector3 {
    func length() -> Float {
        return sqrtf(x * x + y * y + z * z)
    }
    
    func normalized() -> SCNVector3 {
        if self.length() == 0 {
            return self
        }
        
        return self / self.length()
    }
}
extension UIImageView {
    func getPixelColorAt(point:CGPoint) -> UIColor{
        
        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)
        
        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)
        
        pixel.deallocate(capacity: 4)
        return color
    }
}


extension UIButton{
    func topRounded(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.topLeft , .topRight],
                                     cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    func bottomRounded(){
        let maskPath1 = UIBezierPath(roundedRect: bounds,
                                     byRoundingCorners: [.bottomLeft , .bottomRight],
                                     cornerRadii: CGSize(width: 8, height: 8))
        let maskLayer1 = CAShapeLayer()
        maskLayer1.frame = bounds
        maskLayer1.path = maskPath1.cgPath
        layer.mask = maskLayer1
    }
    
    
}

extension UISegmentedControl {
    func goVertical() {
        self.transform = CGAffineTransform.init(rotationAngle:(CGFloat(M_PI_2)))
        for segment in self.subviews {
            for segmentSubview in segment.subviews {
                if segmentSubview is UILabel {
                    (segmentSubview as! UILabel).transform = CGAffineTransform.init(rotationAngle:(CGFloat(-M_PI_2)))
                }else if segmentSubview is UIImageView{
                    (segmentSubview as! UIImageView).transform = CGAffineTransform.init(rotationAngle:(CGFloat(-M_PI_2)))
                }
            }
        }
    }
}
extension UIImage {
    
    func maskWithColor(color: UIColor) -> UIImage? {
        let maskImage = cgImage!
        
        let width = size.width
        let height = size.height
        let bounds = CGRect(x: 0, y: 0, width: width, height: height)
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
        
        context.clip(to: bounds, mask: maskImage)
        context.setFillColor(color.cgColor)
        context.fill(bounds)
        
        if let cgImage = context.makeImage() {
            let coloredImage = UIImage(cgImage: cgImage)
            return coloredImage
        } else {
            return nil
        }
    }
    
    
}


extension UIColor {
    var redValue: CGFloat{ return CIColor(color: self).red * 255 }
    var greenValue: CGFloat{ return CIColor(color: self).green * 255 }
    var blueValue: CGFloat{ return CIColor(color: self).blue * 255 }
    var alphaValue: CGFloat{ return CIColor(color: self).alpha }
    
    func setSaturation(_ newSaturation: CGFloat) -> UIColor {
        
        var h = CGFloat()
        var s = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let newColor = UIColor(hue: h, saturation: newSaturation, brightness: b, alpha: a)
            return newColor
        }
        
        return self
    }
    
    func setBrightness(_ newBrightness: CGFloat) -> UIColor {
        
        var h = CGFloat()
        var s = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        if self.getHue(&h, saturation: &s, brightness: &b, alpha: &a) {
            let newColor = UIColor(hue: h, saturation: s, brightness: newBrightness, alpha: a)
            return newColor
        }
        
        return self
    }
    
    func isColorGrayScale() -> Bool {
        var r = CGFloat()
        var g = CGFloat()
        var b = CGFloat()
        var a = CGFloat()
        
        self.getRed(&r, green: &g, blue: &b, alpha: &a)
        
        return r == g && r == b
    }
}

public func + (left: SCNVector3, right: SCNVector3) -> SCNVector3 {
    return SCNVector3Make(left.x + right.x, left.y + right.y, left.z + right.z)
}

public func * (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x * right, left.y * right, left.z * right)
}

public func / (left: SCNVector3, right: Float) -> SCNVector3 {
    return SCNVector3Make(left.x / right, left.y / right, left.z / right)
}

public extension Array where Element: FloatingPoint {
    /// Returns the sum of all elements in the array
    var total: Element {
        return reduce(0, +)
    }
    /// Returns the average of all elements in the array
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

public func dbToGain(dB:Float) -> Float {
    let ret =  pow(2, dB/6)
    print("Ret is \(ret)")
    return ret
}
