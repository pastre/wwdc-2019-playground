import Foundation
import ARKit


public class BblExplosionParticle: SCNNode {
    
    var color: UIColor
    
    public init(color: UIColor) {
        self.color = color
        
        super.init()
        
        let bubble = SCNPlane(width: 0.25, height: 0.25)
        let material = SCNMaterial()
        let emitter = self.getEmitter()
        
        material.diffuse.contents = emitter
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
        self.geometry?.materials.first!.diffuse.contents = self.getEmitter()
    }
    
    func getEmitter() -> SKEmitterNode{
        let emitter = SKEmitterNode(fileNamed: "explosion")!
        
        //emitter.particleColorBlendFactor = 1.0
        //emitter.particleColorSequence = nil
        //emitter.particleColor = self.color
        return emitter
    }
    
    public func setColor(newColor color: UIColor){
        self.color = color
        self.updateColor(newColor: color)
    }
    
    
}
