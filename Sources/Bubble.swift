
import Foundation
import ARKit


public class Bubble: SCNNode {
    
    var color: UIColor
    
    public init(color: UIColor) {
        self.color = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            
        super.init()
        
        let bubble = SCNPlane(width: 0.25, height: 0.25)
        let material = SCNMaterial()
        let img = #imageLiteral(resourceName: "ar-bubbleText.jpg").maskWithColor(color: self.color)
        material.diffuse.contents = img
        material.isDoubleSided = true
        material.writesToDepthBuffer = false
        material.blendMode = .screen
        bubble.materials = [material]
        self.geometry = bubble
        
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateColor(newColor color: UIColor){
        self.geometry?.materials.first!.diffuse.contents = #imageLiteral(resourceName: "ar-bubbleText.jpg").maskWithColor(color: self.color)
    }
    
    public func setColor(newColor color: UIColor){
        self.color = color
        self.updateColor(newColor: color)
    }
    
    
}



