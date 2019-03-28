import Foundation
import ARKit
import UIKit
import AVFoundation
import CoreAudio

public class GameScene: UIViewController, ARSCNViewDelegate, ARSessionDelegate, OptionViewDelegate, PhotoDelegate {
    
    // ARView stuff
    let session = ARSession()
    var sceneView: ARSCNView!
    
    // Declares a view to display pics
    var photoView: PhotoView!
    
    var debugLabel: UILabel!
    var detectingLabel: UILabel!
    
    // This is in order to play the pop sound
    let popSound = URL(fileURLWithPath: Bundle.main.path(forResource: "pop", ofType: "mp3")!)
    var audioPlayer: AVAudioPlayer!
    

    // This is in order to use the mic
    var recorder: AVAudioRecorder!
    let LEVEL_THRESHOLD: Float = -20.0
    
    // Color picking stuff
    var colorPicker: UIImage!
    var colorPickerView: UIImageView!
    var currentColor: UIColor!
    
    
    // Bubble blower stuff
    var bubbleBlowerImage: UIImage!
    var bubbleBlowerView: UIImageView!
    
    // Armazena o estado tendo em vista as opcoes
    var currentState: String!
    var bubbleCounter: Int!
    
    
    public override func loadView() {
        self.currentColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        sceneView = ARSCNView(frame: CGRect(x: 0.0, y: 0.0, width: 768, height: 1024))
        photoView = PhotoView(frame: CGRect(x: 0, y: 0, width: 768, height: 1024))
        
        initMicrophone() // Inicializa o microfone para detectar o sopro
        sceneView.delegate = self
        sceneView.session = session

        bubbleCounter = 0

        sceneView.session.delegate = self
        sceneView.autoenablesDefaultLighting = true

        photoView.delegate = self
        
        self.view = sceneView
        self.setupUI()
        self.setUpSceneView()
        
//        self.spawnBubblePopParticle(spawnAt: SCNVector3(0, 0, 0), withColor: #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1))
    }

    public func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
        let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
        
        
        for node in sceneView.scene.rootNode.childNodes {
            node.look(at: pos)
        }
        if self.currentState == "auto"{
            if self.bubbleCounter % 6 == 0{
                spawnBubble()
            }
            bubbleCounter += 1
        }else if self.currentState == "blow"{
            self.updateMic()
        }
    }
    
    func onBackButtonPressed() {
        print("Back button pressed!")
        self.view = sceneView
    }
    
    func onCameraPressed() {
        print("Tirando foto na GameScene")
        let pic = self.sceneView.snapshot()
//        self.goToPhotoView(image: pic)
    }
    
    func onOptionChanged(newOption: String) {
        self.currentState = newOption
        print("Mudando o estado para", newOption)
    }
    
    private func setupUI() {
        
        // Creating and setting the detecting plane label
        let font = UIFont(name: "HelveticaNeue-BoldItalic", size: 22)
        detectingLabel = UILabel(frame: CGRect(x: 20, y: -20, width: 300, height: 100))
        detectingLabel.font = font
        detectingLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        detectingLabel.layer.shadowColor = UIColor.black.cgColor
        detectingLabel.layer.shadowOpacity = 1.0
        detectingLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        detectingLabel.text = "detecting horizontal plane..."
        
        
        // Instantiating and setting the debug label
        debugLabel = UILabel(frame: CGRect(x: 20, y: 20, width: 300, height: 100))
        debugLabel.font = font
        debugLabel.textColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        debugLabel.layer.shadowColor = UIColor.black.cgColor
        debugLabel.layer.shadowOpacity = 1.0
        debugLabel.layer.shadowOffset = CGSize(width: 2, height: 2)
        //        debugLabel.text = "\(recorder.averagePower(forChannel: 0))"
        
        // Loading image for the color picker
        colorPicker = UIImage(named: "raw_color_picker")!
        
        // Instancia a view da escolha de cores
        let colorPickerView = UIImageView(image: colorPicker)
        colorPickerView.frame = CGRect(x: 0, y:0, width: 60, height: 60)
        colorPickerView.isUserInteractionEnabled = true
        self.colorPickerView = colorPickerView
        
        // Instancia a view do bubble blower
        let bubbleBlowerImage = self.getBubbleBlowerImage()
        let bubbleBlowerView = UIImageView(image: bubbleBlowerImage)
        bubbleBlowerView.frame = CGRect(x: 0, y:0, width: 60, height: 60)
        self.bubbleBlowerView = bubbleBlowerView
        
        
        let optionsView = OptionsView()
        optionsView.delegate = self
        // coloca as imagens nas views
        self.view.addSubview(bubbleBlowerView)
        self.view.addSubview(colorPickerView)
//        self.view.addSubview(detectingLabel)
//        self.view.addSubview(debugLabel)
        self.view.addSubview(optionsView)
//        self.view.addSubview(optionsView)
        
//        self.view.addSubview(self.segmentControl)
        // Configura as constrains do colorPicker
        colorPickerView.translatesAutoresizingMaskIntoConstraints = false
        colorPickerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 2).isActive = true
        colorPickerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -2).isActive = true
        colorPickerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.05).isActive = true
        colorPickerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.3).isActive = true
        
        // Configura as constrains do bubblePicker
        bubbleBlowerView.translatesAutoresizingMaskIntoConstraints = false
        bubbleBlowerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bubbleBlowerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        bubbleBlowerView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.3).isActive = true
        bubbleBlowerView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        
    
        // Configura as contrains do menu de opcoes
        optionsView.translatesAutoresizingMaskIntoConstraints = false
        optionsView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -2).isActive = true
        optionsView.bottomAnchor.constraint(equalTo:colorPickerView.bottomAnchor, constant: 0).isActive = true
        optionsView.widthAnchor.constraint(equalTo:  view.widthAnchor, multiplier: 0.1).isActive = true
        optionsView.heightAnchor.constraint(equalTo: colorPickerView.heightAnchor).isActive = true
        
        
        
    }
    

    func goToPhotoView(image toDisplay: UIImage){
        self.photoView.image = toDisplay
        self.view = self.photoView
    }
    
    func initMicrophone(){
        print("a")
        
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")
        print("a")
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]
        print("a")
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord, mode: .default)
            try audioSession.setActive(true)
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)
            
        } catch {
            return
        }
        
        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        recorder.record()
    }
    
    func spawnBubble(){
        
        guard let frame = self.sceneView.session.currentFrame else {
            return
        }
        let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
        let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
        
        let position = getNewPosition()
        
        let newBubble = Bubble(color: self.currentColor)
        newBubble.position = position
        newBubble.scale = SCNVector3(1,1,1) * floatBetween(0.6, and: 1)
//        self.debugLabel.text = "\(self.currentColor.redValue), \(self.currentColor.greenValue), \(self.currentColor.blueValue), "
        newBubble.setColor(newColor: self.currentColor)
        
        let firstVector = dir.normalized() * 0.5 + SCNVector3(0,0.15,0)
        let secondVector =  dir + SCNVector3(floatBetween(-1.5, and:1.5 ),floatBetween(0, and: 1.5),0)
        
        let firstAction = SCNAction.move(by: firstVector, duration: 0.5)
        firstAction.timingMode = .easeOut
        
        let secondAction = SCNAction.move(by: secondVector, duration: TimeInterval(floatBetween(8, and: 11))) // Tempo de vida da bolha
        
        secondAction.timingMode = .easeOut
        newBubble.runAction(firstAction)
        newBubble.runAction(secondAction, completionHandler: {
            newBubble.runAction(SCNAction.fadeOut(duration: 0), completionHandler: {
                print("Morri")
                let moved = newBubble.position + firstVector + secondVector
//                self.playPop()
                self.spawnBubblePopParticle(spawnAt: moved, withColor: self.currentColor)
                newBubble.removeFromParentNode()
            })
        })
        
        sceneView.scene.rootNode.addChildNode(newBubble)
        self.debugLabel.text = "\(self.bubbleCounter)"
    }
    
    func spawnBubblePopParticle(spawnAt point: SCNVector3, withColor color: UIColor){
        return
        let emitter = SCNParticleSystem(named: "reactor.scnp" , inDirectory: nil)!
        emitter.particleColor = color
        emitter.particleLifeSpan = 1.0
        sceneView.scene.rootNode.addParticleSystem(emitter)
        emitter.removeAllAnimations()
    }
    
    public func setUpSceneView() {
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        sceneView.session.run(configuration)
        sceneView.delegate = self
    }
    
    
    
    public func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        DispatchQueue.main.async {
            self.detectingLabel.isHidden = true
        }
        
        guard let planeAnchor = anchor as? ARPlaneAnchor else { return }
        
        let width = CGFloat(planeAnchor.extent.x)
        let height = CGFloat(planeAnchor.extent.z)
        let plane = SCNPlane(width: width, height: height)
        plane.materials.first?.diffuse.contents = UIColor.clear
        
        
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.currentState == "touch"{
            spawnBubble()
        }

    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleColorChange(touches)
    }
    
    func handleColorChange(_ touches: Set<UITouch>){
        for touch in touches{
            let point = touch.location(in: self.colorPickerView)
            let color = self.colorPickerView.getPixelColorAt(point: point)
            if color.alphaValue != 0{
                self.bubbleBlowerView.image = self.getBubbleBlowerImage()
                self.currentColor = color.withAlphaComponent(1.0)
            }
        }
    }
    
    @objc func takePic(){
        print("Taking picture")
//
        let pic = self.sceneView.snapshot()
        print("Loaded pic")
        UIImageWriteToSavedPhotosAlbum(pic, nil, nil, nil)
        print("Saved pic")
    }
    
    func playPop(){
        print("Played pop!")
//        canRecord = false;
        do{
            try AVAudioSession.sharedInstance().setCategory(.playback , mode: .default)
            
            audioPlayer = try AVAudioPlayer(contentsOf: popSound)
            audioPlayer.play()
        }catch let error  {
            print("AI IRMAO DEU RUIM \(error)")
        }
//        canRecord = true;
    }
    func getNewPosition() -> (SCNVector3) { // (direction, position)
        if let frame = self.sceneView.session.currentFrame {
            let mat = SCNMatrix4(frame.camera.transform) // 4x4 transform matrix describing camera in world space
            let dir = SCNVector3(-1 * mat.m31, -1 * mat.m32, -1 * mat.m33) // orientation of camera in world space
            let pos = SCNVector3(mat.m41, mat.m42, mat.m43) // location of camera in world space
            return pos + SCNVector3(0,-0.07,0) + dir.normalized() * 0.5
        }
        return SCNVector3(0, 0, -1)
    }
    
    func updateMic(){
        self.initMicrophone()
        recorder.updateMeters()
        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        if isLoud{
            spawnBubble()
        }
        
//        debugLabel.text = "\(level)"
    }
    
    
    func getBubbleBlowerImage() -> UIImage{
        let img = UIImage(named: "bubbleblower")!
        return img.maskWithColor(color: self.currentColor)!
        //        return imgz
    }
    //
}

