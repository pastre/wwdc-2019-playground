import Foundation
import UIKit

protocol PhotoDelegate: class{
    func onBackButtonPressed()
}


public class PhotoView: UIView{
    
    public var image: UIImage
    var delegate: PhotoDelegate?

    public override init(frame: CGRect) {
        self.image = UIImage(named: "camera.png")!
        
        super.init(frame: frame)
    }
    
    public override func draw(_ rect: CGRect) {
//        print("Drawing")
        let imageView = UIImageView(image: self.image)
        let backButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 30))
        let saveButton: UIButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        
        
        backButton.setImage(UIImage(named: "back_button"), for: .normal)
        saveButton.setImage(UIImage(named: "download_button"), for: .normal)
        
        backButton.addTarget(self, action: #selector(self.backButtonCallback), for: .touchDown)
        
//        print("Drawing")
        self.addSubview(imageView)
        self.addSubview(backButton)
        self.addSubview(saveButton)
        
        print("Drawing")
        backButton.translatesAutoresizingMaskIntoConstraints = false
        backButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2 ).isActive = true
        backButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        backButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        backButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true
        
        saveButton.translatesAutoresizingMaskIntoConstraints = false
        saveButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
        saveButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2 ).isActive = true
        saveButton.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.1).isActive = true
        saveButton.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.1).isActive = true

        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 2).isActive = true
        imageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 2).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -2).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -2).isActive = true
    }
    
    @objc func backButtonCallback(){
        self.delegate?.onBackButtonPressed()
    }
    
    @objc func saveButtonCallback(){
        
        UIImageWriteToSavedPhotosAlbum(self.image, nil, nil, nil)
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        
        self.image = UIImage(named: "camera")!
        super.init(coder: aDecoder)
    }
    
    
}

