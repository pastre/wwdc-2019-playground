import Foundation
import UIKit

class TutorialView: UIView{
    
    let steps = [
        "intro",
        "cataventoOption",
        "autoOption" ,
        "touchOption" ,
        "cameraOption" ,
        "colorPicker"
    ]
    
    var nextButton: UIButton!
    var previousButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nextButton = UIButton()
        self.previousButton = UIButton()
    }
    
    

    
    
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
