import Foundation
import UIKit

protocol OptionViewDelegate: class{
    func onOptionChanged(newOption: String)
    func onCameraPressed()
}

public class OptionsView  : UIView{
    let icons = [
        "blow": UIImage(named: "blow")!,
        "auto": UIImage(named: "catavento")!,
        "touch": UIImage(named: "touch")!,
//        "camera": UIImage(named: "camera")!,
    ]
    
    let colors = [
        "selected_icon": #colorLiteral(red: 0, green: 0.9283531308, blue: 1, alpha: 1),
        "default_icon": #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
        "selected_background": #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 0),
        "default_background": #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 0) ,

//        "selected_background": #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1),
//        "default_background":#colorLiteral(red: 0.9999960065, green: 1, blue: 1, alpha: 1),
    ]
    
    var buttons = [String: UIButton]()
    weak var delegate: OptionViewDelegate?
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.initButtons()
        self.addButtonsToView()
        
//        self.setButtonAsActive(button: self.buttons["blow"]!, withIcon: self.icons["blow"]!)
    }
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    public override func draw(_ rect: CGRect) {
        print("Pintando!")
    }
    
    func initButtons(){
        for (buttonName, _) in self.icons {
            let button = getButton(withName: buttonName, index: 0)
            self.buttons[buttonName] = button
        }
    }
    
    func addButtonsToView(){
        let order = [
            "blow",
            "auto",
            "touch",
//            "camera",
            ]
        
        for (_, button) in self.buttons{
            self.addSubview(button)
        }
        
        var offset = CGFloat(0)
        
        for (buttonName) in order{
            let button = self.buttons[buttonName]!
            button.translatesAutoresizingMaskIntoConstraints = false
            button.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
            button.topAnchor.constraint(equalTo: self.topAnchor, constant: offset).isActive = true
            button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 1).isActive = true
            button.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.4).isActive = true
//            if buttonName == "catavento"{
//                button.topRounded()
//            }else if buttonName == "touch"{
//                button.bottomRounded()
//            }
            offset += 60
        }
    }
    
    func getButton(withName named : String, index: Int) -> UIButton{
        let buttonIcon = self.icons[named]!
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: buttonIcon.cgImage!.width, height: buttonIcon.cgImage!.height))
//        let isRounded = index != 1
//        if isRounded{
//            let isTop = index == 0
//            button.roundedCorners(top: isTop)
//        }
        button.setImage(buttonIcon.maskWithColor(color: self.colors["default_icon"]!), for: .normal)
//        if named == "camera"{
//            button.backgroundColor = .none
//        }else{
//            button.backgroundColor = self.colors["default_background"]
//        }
//        button.setImage(buttonIcon.maskWithColor(color: #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)), for: .highlighted)
//        button.clipsToBounds = true
//        button.layer.cornerRadius = 20
//        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.addTarget(self, action: #selector(self.buttonCallback), for: .touchDown)
        
        return button
    }
    
    @objc func buttonCallback(sender: UIButton!){
        for (buttonName, button) in buttons{
            let icon = self.icons[buttonName]!
            if buttonName == "camera"{
                if sender == button{
                    self.delegate?.onCameraPressed()
                    break
                }
                continue
            }
            if button == sender{
                print("O botao eh ", button)
                setButtonAsActive(button: button, withIcon: icon)
                self.delegate?.onOptionChanged(newOption: buttonName)
            }else{
                setButtonAsInactive(button: button, withIcon: icon)
            }
        }
    }
    
    func setButtonAsActive(button: UIButton, withIcon icon: UIImage){
        button.backgroundColor = self.colors["selected_background"]
        button.setImage(icon.maskWithColor(color: self.colors["selected_icon"]!), for: .normal)
    }
    
    func setButtonAsInactive(button: UIButton, withIcon icon: UIImage ){
        button.backgroundColor = self.colors["default_background"]
        button.setImage(icon.maskWithColor(color: self.colors["default_icon"]!), for: .normal)
    }
    
    func addBehavior() {
        print("Add all the behavior here")
    }
    
}
