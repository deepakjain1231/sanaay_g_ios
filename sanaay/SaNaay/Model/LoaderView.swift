import UIKit

class LoaderView: UIView {
    
    class func displaySpinner(message : String) {
        removeSpinner()
        let win:UIWindow = UIApplication.shared.delegate!.window!!
        let spinnerView = UIView.init(frame: win.bounds)
        
        let label = UILabel.init(frame: CGRect(x: 50, y: (win.frame.size.height / 2) + 40, width: win.frame.size.width - 100, height: 21))
        label.textAlignment = .center
        label.text = message
        label.textColor = AppColor.app_GreenColor
        spinnerView.tag = 9999
        spinnerView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.6)
        let ai = UIActivityIndicatorView.init(style: .whiteLarge)
        ai.startAnimating()
        ai.center = spinnerView.center
        ai.tintColor = AppColor.app_GreenColor
        ai.color = AppColor.app_GreenColor
        DispatchQueue.main.async {
            spinnerView.addSubview(ai)
            spinnerView.addSubview(label)
            let win:UIWindow = UIApplication.shared.delegate!.window!!
            win.addSubview(spinnerView)
        }
    }
    
    class func removeSpinner() {
        DispatchQueue.main.async {
            let win:UIWindow = UIApplication.shared.delegate!.window!!
            for subView : UIView in win.subviews {
                if subView.tag == 9999{
                    subView.removeFromSuperview()
                }
            }
        }
    }
}
