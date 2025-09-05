//
//  GeneralMethods.swift
//  AbayaBazar
//
//  Created by iMac-4 on 7/14/17.
//  Copyright © 2017 iMac-4. All rights reserved.
//

import Foundation
import UIKit


@IBDesignable
class DesignableView: UIView {
}

extension UIFont {
    
    public class func AppFontRegular(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans", size: fontSize)!
    }
    
    public class func AppFontBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Bold", size: fontSize)!
    }
    
    public class func AppFontSemiBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Semibold", size: fontSize)!
    }
    
    public class func AppFontLight(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Light", size: fontSize)!
    }
    
    public class func AppFontExtraBold(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Extrabold", size: fontSize)!
    }
    
    public class func AppFontMedium(_ fontSize: CGFloat) -> UIFont {
        return UIFont(name: "OpenSans-Medium", size: fontSize)!
    }


}



//MARK:- For PullTo Refresh TableView
extension UITableView {
    
    func pullTorefresh(_ target: Selector, tintcolor: UIColor,_ toView: UIViewController?){
        let refrshControll = UIRefreshControl()
        refrshControll.tintColor = tintcolor
        refrshControll.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        refrshControll.addTarget(toView!, action: target, for: UIControl.Event.valueChanged)
        self.refreshControl = refrshControll
    }
    
    func closeEndPullRefresh(){
        self.refreshControl?.endRefreshing()
    }
}


//MARK:- For PullTo Refresh TableView
extension UICollectionView {
    
    func pullTorefresh(_ target: Selector, tintcolor: UIColor,_ toView: UIViewController?){
        let refrshControll = UIRefreshControl()
        refrshControll.tintColor = tintcolor
        refrshControll.removeTarget(nil, action: nil, for: UIControl.Event.allEvents)
        refrshControll.addTarget(toView!, action: target, for: UIControl.Event.valueChanged)
        self.refreshControl = refrshControll
    }
    
    func closeEndPullRefresh(){
        self.refreshControl?.endRefreshing()
    }
}


private var __maxLengths = [UITextField: Int]()
extension UITextField {
    @IBInspectable var maxLength: Int {
        get {
            guard let l = __maxLengths[self] else {
               return 150 // (global default-limit. or just, Int.max)
            }
            return l
        }
        set {
            __maxLengths[self] = newValue
            addTarget(self, action: #selector(fix), for: .editingChanged)
        }
    }
    @objc func fix(textField: UITextField) {
        let t = textField.text
        textField.text = String(t?.prefix(maxLength) ?? "")
    }
}

extension Date {

    func dateFormatWithSuffix() -> String {
        return "d'\(self.daySuffix())' MMM yyyy"
    }

    func daySuffix() -> String {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components(.day, from: self)
        let dayOfMonth = components.day
        switch dayOfMonth {
        case 1, 21, 31:
            return "st"
        case 2, 22:
            return "nd"
        case 3, 23:
            return "rd"
        default:
            return "th"
        }
    }
}



extension Date{
    var intVal: Int?{
        if let d = Date.coordinate{
             let inteval = Date().timeIntervalSince(d)
             return Int(inteval)
        }
        return nil
    }


    // today's time is close to `2020-04-17 05:06:06`

    static let coordinate: Date? = {
        let dateFormatCoordinate = DateFormatter()
        dateFormatCoordinate.dateFormat = "d MMM yyyy h:mm a"
        if let d = dateFormatCoordinate.date(from: "2020-04-17 05:06:06") {
            return d
        }
        return nil
    }()
}


extension Int{
    var dateVal: Date?{
        // convert Int to Double
        let interval = Double(self)
        if let d = Date.coordinate{
            return  Date(timeInterval: interval, since: d)
        }
        return nil
    }
}


//MARK:- Extension_UIColor
extension UIColor {
    
    convenience init(hex: String) {
        let scanner = Scanner(string: hex)
        scanner.scanLocation = 0
        var rgbValue: UInt64 = 0
        scanner.scanHexInt64(&rgbValue)
        let r = (rgbValue & 0xff0000) >> 16
        let g = (rgbValue & 0xff00) >> 8
        let b = rgbValue & 0xff
        
        self.init(
            red: CGFloat(r) / 0xff,
            green: CGFloat(g) / 0xff,
            blue: CGFloat(b) / 0xff, alpha: 1
        )
    }
}

//MARK:- UserDefaults
extension UserDefaults {
    
    //MARK:- UserDefault Save / Retrive Data
    static func appSetObject(_ object:Any, forKey:String){
        UserDefaults.standard.set(object, forKey: forKey)
        UserDefaults.standard.synchronize()
    }
    
    static func appObjectForKey(_ strKey:String) -> Any?{
        let strValue = UserDefaults.standard.value(forKey: strKey)
        return strValue
    }
    
    static func appRemoveObjectForKey(_ strKey:String){
        UserDefaults.standard.removeObject(forKey: strKey)
        UserDefaults.standard.synchronize()
    }
    
}


extension String {

    func isValidMobile() -> Bool {
        let PHONE_REGEX = "^[0-9]{6,14}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", PHONE_REGEX)
        let result =  phoneTest.evaluate(with: self)
        return result
    }
    
    func isValidPassword(digit: Int = 7) -> Bool {
        //Minimum six characters, at least one letter and one number
        let passwordRegex = "^(?=.*[A-Za-z])(?=.*\\d)[A-Za-z\\d].{\(digit),}"
        return NSPredicate(format: "SELF MATCHES %@", passwordRegex).evaluate(with: self)
    }

    
    func isValidString(value:String?) -> Bool {
         return value == "" || value == nil
    }
    
    func checkAcceptableValidation(AcceptedCharacters:String) -> Bool {
        let cs = NSCharacterSet(charactersIn: AcceptedCharacters).inverted
        let filtered = self.components(separatedBy: cs).joined(separator: "")
        if self != filtered{
            return false
        }
        return true
    }
    
    func byaddingLineHeight(linespacing:CGFloat) -> NSAttributedString {
        let attributedString = NSMutableAttributedString(string: self)
        // *** Create instance of `NSMutableParagraphStyle`
        let paragraphStyle = NSMutableParagraphStyle()
        // *** set LineSpacing property in points ***
        paragraphStyle.lineSpacing = linespacing  // Whatever line spacing you want in points
        // *** Apply attribute to string ***
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        return attributedString
    }
    
    func trimed() -> String{
       return  self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}


//MARK:- Label FOnt scaling
extension UITextField{
    
    @IBInspectable
    var fontScaling: Bool{
        get{
            return false
        }
        set{
            if newValue == true{
                if screenScale > CGFloat(1){
                    self.font = UIFont.init(name: (self.font?.fontName)!, size: ((self.font?.pointSize)! * screenScale))
                }
            }
        }
    }
}

//MARK:- Label FOnt scaling
extension UILabel{
    
    @IBInspectable
    var fontScaling: Bool{
        get{
            return false
        }
        set{
            if newValue == true{
                if screenScale > CGFloat(1){
                    self.font = UIFont.init(name: self.font.fontName, size: (self.font.pointSize * screenScale))
                }
            }
        }
    }
}

//MARK:- Label FOnt scaling
extension UIButton{
    @IBInspectable
    var fontScaling: Bool{
        get{
            return false
        }
        set{
            if newValue == true{
                if screenScale > CGFloat(1){
                    self.titleLabel?.font = UIFont.init(name: (self.titleLabel?.font.fontName)!, size: ((self.titleLabel?.font.pointSize)! * screenScale))
                }
            }
        }
    }
    
}

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
    
    @IBInspectable var DynamicRound:Bool{
        get{
            return false
        }
        set{
            if newValue == true {
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                    self.layer.cornerRadius = self.frame.height / 2
                    self.layer.masksToBounds = true;
                })
            }
        }
        
    }
    
    @IBInspectable var RoundWithShadow: Bool{
        get{
            return false
        }set{
            if newValue == true{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                    self.layer.masksToBounds = false
                    self.layer.borderColor = self.borderColor?.cgColor
                    self.layer.borderWidth = self.borderWidth
                    self.layer.shadowOffset = self.shadowOffset
                    self.layer.cornerRadius = self.bounds.height/2
                    self.layer.shadowColor = self.shadowColor?.cgColor
                    self.layer.shadowRadius = self.shadowRadius
                    self.layer.shadowOpacity = self.shadowOpacity
                    self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: self.layer.cornerRadius).cgPath
                    let backgroundColor = self.backgroundColor?.cgColor
                    self.backgroundColor = nil
                    self.layer.backgroundColor =  backgroundColor

                })
            }
        }
    }
    
    @IBInspectable var cornerradiusWithShadow: Bool{
        get{
            return false
        }set{
            if newValue == true{
                DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01, execute: {
                    self.layer.masksToBounds = false
                    self.layer.borderColor = self.borderColor?.cgColor
                    self.layer.borderWidth = self.borderWidth
                    self.layer.shadowOffset = self.shadowOffset
                    self.layer.cornerRadius = self.cornerRadius
                    self.layer.shadowColor = self.shadowColor?.cgColor
                    self.layer.shadowRadius = self.shadowRadius
                    self.layer.shadowOpacity = self.shadowOpacity
                    self.layer.shadowPath = UIBezierPath(roundedRect: self.layer.bounds, cornerRadius: self.layer.cornerRadius).cgPath
                    let backgroundColor = self.backgroundColor?.cgColor
                    self.backgroundColor = nil
                    self.layer.backgroundColor =  backgroundColor
                })
            }
        }
    }
    
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.05) {
            let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            self.layer.mask = mask
        }
    }
}
extension UIFont{
    func fontWith(name:String, size:CGFloat) -> UIFont{
        return (UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size))
    }
}
extension UITextField{
    
    func addDoneToolbar(TintColor:UIColor = AppColor.app_GreenColor, selector:Selector? = nil, targate:Any? = nil)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: screenWidth, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        var done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        
        if let selctr = selector{
            done = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: targate, action: selctr)
        }
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = TintColor
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func done() {
        self.endEditing(true)
    }
}

extension UITextView{
    func addDoneToolbar(TintColor:UIColor = AppColor.app_GreenColor)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = TintColor
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func done() {
        self.endEditing(true)
    }
    
    
    
    func addDoneToolbarwithClearButton(TintColor:UIColor = AppColor.app_GreenColor)
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        doneToolbar.barStyle       = UIBarStyle.default
        let flexSpace              = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let done: UIBarButtonItem  = UIBarButtonItem(title: "Done", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.done))
        let clear: UIBarButtonItem  = UIBarButtonItem(title: "Clear", style: UIBarButtonItem.Style.done, target: self, action: #selector(self.clearText))
        
        var items = [UIBarButtonItem]()
        items.append(flexSpace)
        items.append(done)
        items.append(clear)
        
        doneToolbar.items = items
        doneToolbar.sizeToFit()
        doneToolbar.tintColor = TintColor
        self.inputAccessoryView = doneToolbar
    }
    
    @objc func clearText() {
        self.text = ""
    }
}

extension Date {
    var ticks: UInt64 {
        return UInt64((self.timeIntervalSince1970 + 62_135_596_800) * 10_000_000)
    }
    
    var age: Int {
        return Calendar.current.dateComponents([.year], from: self, to: Date()).year!
    }
    
    func rounded(on amount: Int, _ component: Calendar.Component) -> Date {
        let cal = Calendar.current
        let value = cal.component(component, from: self)
        
        // Compute nearest multiple of amount:
        let roundedValue = lrint(Double(value) / Double(amount)) * amount
        let newDate = cal.date(byAdding: component, value: roundedValue - value, to: self)!
        
        return newDate.floorAllComponents(before: component)
    }
    
    func floorAllComponents(before component: Calendar.Component) -> Date {
        // All components to round ordered by length
        let components = [Calendar.Component.year, .month, .day, .hour, .minute, .second, .nanosecond]
        
        guard let index = components.firstIndex(of: component) else {
            fatalError("Wrong component")
        }
        
        let cal = Calendar.current
        var date = self
        
        components.suffix(from: index + 1).forEach { roundComponent in
            let value = cal.component(roundComponent, from: date) * -1
            date = cal.date(byAdding: roundComponent, value: value, to: date)!
        }
        
        return date
    }
   
}

extension DateFormatter {
    convenience init(dateStyle: Style) {
        self.init()
        self.dateStyle = dateStyle
    }
}
extension UIApplication {
    var statusBarView: UIView? {
        if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        }
        return nil
    }
}



extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}


extension String {
    
    func index(at position: Int, from start: Index? = nil) -> Index? {
        let startingIndex = start ?? startIndex
        return index(startingIndex, offsetBy: position, limitedBy: endIndex)
    }
    
    func character(at position: Int) -> Character? {
        guard position >= 0, let indexPosition = index(at: position) else {
            return nil
        }
        return self[indexPosition]
    }
    
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(boundingBox.width)
    }
}


extension UISearchBar {
    
    func change(textFont : UIFont?) {
        
        for view : UIView in (self.subviews[0]).subviews {
            
            if let textField = view as? UITextField {
                textField.font = textFont
            }
        }
    }
    
    func setWhitebackground_color() {
        if #available(iOS 13.0, *) {
           self.searchTextField.backgroundColor = .white
        }
    }
    
}


extension Date {
    /// Returns the amount of years from another date
    func years(from date: Date) -> Int {
        return Calendar.current.dateComponents([.year], from: date, to: self).year ?? 0
    }
    /// Returns the amount of months from another date
    func months(from date: Date) -> Int {
        return Calendar.current.dateComponents([.month], from: date, to: self).month ?? 0
    }
    /// Returns the amount of weeks from another date
    func weeks(from date: Date) -> Int {
        return Calendar.current.dateComponents([.weekOfMonth], from: date, to: self).weekOfMonth ?? 0
    }
    /// Returns the amount of days from another date
    func days(from date: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: date, to: self).day ?? 0
    }
    /// Returns the amount of hours from another date
    func hours(from date: Date) -> Int {
        return Calendar.current.dateComponents([.hour], from: date, to: self).hour ?? 0
    }
    /// Returns the amount of minutes from another date
    func minutes(from date: Date) -> Int {
        return Calendar.current.dateComponents([.minute], from: date, to: self).minute ?? 0
    }
    /// Returns the amount of seconds from another date
    func seconds(from date: Date) -> Int {
        return Calendar.current.dateComponents([.second], from: date, to: self).second ?? 0
    }
    /// Returns the a custom time interval description from another date
    func offset(from date: Date) -> String {
        if years(from: date)   > 0 { return "\(years(from: date)) years ago"   }
        if months(from: date)  > 0 { return "\(months(from: date)) Months ago"  }
        if weeks(from: date)   > 0 { return "\(weeks(from: date)) week ago"   }
        if days(from: date)    > 0 { return "\(days(from: date)) days ago"    }
        if hours(from: date)   > 0 { return "\(hours(from: date)) hrs ago"   }
        if minutes(from: date) > 0 { return "\(minutes(from: date)) mins ago" }
        if seconds(from: date) > 0 { return "Just now" } //\(seconds(from: date)) secs ago
        return ""
    }
    
    
    
    
    func timeAgoSinceDate() -> String {
        
        // From Time
        let fromDate = self
        
        // To Time
        let toDate = Date()
        
        // Estimation
        // Year
        if let interval = Calendar.current.dateComponents([.year], from: fromDate, to: toDate).year, interval > 0  {
            return interval == 1 ? "\(interval)" + " " + "y" : "\(interval)" + " " + "y"
        }
        // Weeks
        if let interval = Calendar.current.dateComponents([.weekday], from: fromDate, to: toDate).weekday, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "w" : "\(interval)" + " " + "w"
        }
        
        // Day
        if let interval = Calendar.current.dateComponents([.day], from: fromDate, to: toDate).day, interval > 0  {
            
            return interval == 1 ? "\(interval)" + " " + "d" : "\(interval)" + " " + "d"
        }
        
        // Hours
        if let interval = Calendar.current.dateComponents([.hour], from: fromDate, to: toDate).hour, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "h" : "\(interval)" + " " + "h"
        }
        
        // Minute
        if let interval = Calendar.current.dateComponents([.minute], from: fromDate, to: toDate).minute, interval > 0 {
            
            return interval == 1 ? "\(interval)" + " " + "m" : "\(interval)" + " " + "m"
        }
        
        return "now"
    }
    
    
    
    func notification_timeAgo_SinceDate(_ from_Dateee: Date) -> String {

        let calendar = Calendar.current
        let now = Date()
        let unitFlags: NSCalendar.Unit = [.second, .minute, .hour, .day, .weekOfYear, .month, .year]
        let components = (calendar as NSCalendar).components(unitFlags, from: from_Dateee, to: now, options: [])
        if let year = components.year, year >= 1 {
            return year == 1 ? "\(year)" + " " + "y" : "\(year)" + " " + "y"
        }

        if let year = components.year, year >= 1 {
            return year == 1 ? "\(year)" + " " + "y" : "\(year)" + " " + "y"
        }

        if let month = components.month, month >= 2 {
            return month == 1 ? "\(month)" + " " + "m" : "\(month)" + " " + "m"
        }

        if let month = components.month, month >= 1 {
            return month == 1 ? "\(month)" + " " + "m" : "\(month)" + " " + "m"
        }

        if let week = components.weekOfYear, week >= 2 {
            return week == 1 ? "\(week)" + " " + "w" : "\(week)" + " " + "w"
        }

        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "\(week)" + " " + "w" : "\(week)" + " " + "w"
        }

        if let day = components.day, day >= 2 {
            return day == 1 ? "\(day)" + " " + "d" : "\(day)" + " " + "d"
        }

        if let day = components.day, day >= 1 {
            return day == 1 ? "\(day)" + " " + "d" : "\(day)" + " " + "d"
        }

        if let hour = components.hour, hour >= 2 {
            return hour == 1 ? "\(hour)" + " " + "h" : "\(hour)" + " " + "h"
        }

        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "\(hour)" + " " + "h" : "\(hour)" + " " + "h"
        }

        if let minute = components.minute, minute >= 2 {
            return minute == 1 ? "\(minute)" + " " + "m" : "\(minute)" + " " + "m"
        }

        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "\(minute)" + " " + "m" : "\(minute)" + " " + "m"
        }

        return "now"
    }
}



//MARK:- Terms Lable Tap

extension UITapGestureRecognizer {
    
    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: label.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.maximumNumberOfLines = label.numberOfLines
        let labelSize = label.bounds.size
        textContainer.size = labelSize
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: label)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
    //    func didTapAttributedTextInLabel(label: UILabel, inRange targetRange: NSRange) -> Bool {
    //        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
    //        let layoutManager = NSLayoutManager()
    //        let textContainer = NSTextContainer(size: CGSize.zero)
    //        let textStorage = NSTextStorage(attributedString: label.attributedText!)
    //
    //        // Configure layoutManager and textStorage
    //        layoutManager.addTextContainer(textContainer)
    //        textStorage.addLayoutManager(layoutManager)
    //
    //        // Configure textContainer
    //        textContainer.lineFragmentPadding = 0.0
    //        textContainer.lineBreakMode = label.lineBreakMode
    //        textContainer.maximumNumberOfLines = label.numberOfLines
    //        let labelSize = label.bounds.size
    //        textContainer.size = labelSize
    //        // Find the tapped character location and compare it to the specified range
    //        let locationOfTouchInLabel = self.location(in: label)
    //        let textBoundingBox = layoutManager.usedRect(for: textContainer)
    //
    //        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
    //        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
    //                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
    //        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
    //        return NSLocationInRange(indexOfCharacter, targetRange)
    //    }
    
    
    
    
    func didTapAttributedTextInTextView(txtView: UITextView, inRange targetRange: NSRange) -> Bool {
        // Create instances of NSLayoutManager, NSTextContainer and NSTextStorage
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: CGSize.zero)
        let textStorage = NSTextStorage(attributedString: txtView.attributedText!)
        
        // Configure layoutManager and textStorage
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)
        
        // Configure textContainer
        textContainer.lineFragmentPadding = 0.0
        let labelSize = txtView.bounds.size
        textContainer.size = labelSize
        // Find the tapped character location and compare it to the specified range
        let locationOfTouchInLabel = self.location(in: txtView)
        let textBoundingBox = layoutManager.usedRect(for: textContainer)
        
        let textContainerOffset = CGPoint(x: (labelSize.width - textBoundingBox.size.width) * 0.5 - textBoundingBox.origin.x,y:(labelSize.height - textBoundingBox.size.height) * 0.5 - textBoundingBox.origin.y)
        let locationOfTouchInTextContainer = CGPoint(x:locationOfTouchInLabel.x - textContainerOffset.x,
                                                     y:locationOfTouchInLabel.y - textContainerOffset.y);
        let indexOfCharacter = layoutManager.characterIndex(for: locationOfTouchInTextContainer, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        return NSLocationInRange(indexOfCharacter, targetRange)
    }
    
}


extension Sequence where Element: AdditiveArithmetic {
    func sum() -> Element {
        return reduce(.zero, +)
    }
}


extension UIDevice {
    var isSimulator: Bool {
        #if IOS_SIMULATOR
        return true
        #else
        return false
        #endif
    }
    

    static let modelName: String = {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
            #if os(iOS)
            switch identifier {
            case "iPod5,1":                                 return "iPod touch (5th generation)"
            case "iPod7,1":                                 return "iPod touch (6th generation)"
            case "iPod9,1":                                 return "iPod touch (7th generation)"
            case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
            case "iPhone4,1":                               return "iPhone 4s"
            case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
            case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
            case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
            case "iPhone7,2":                               return "iPhone 6"
            case "iPhone7,1":                               return "iPhone 6 Plus"
            case "iPhone8,1":                               return "iPhone 6s"
            case "iPhone8,2":                               return "iPhone 6s Plus"
            case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
            case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
            case "iPhone8,4":                               return "iPhone SE"
            case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
            case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
            case "iPhone10,3", "iPhone10,6":                return "iPhone X"
            case "iPhone11,2":                              return "iPhone XS"
            case "iPhone11,4", "iPhone11,6":                return "iPhone XS Max"
            case "iPhone11,8":                              return "iPhone XR"
            case "iPhone12,1":                              return "iPhone 11"
            case "iPhone12,3":                              return "iPhone 11 Pro"
            case "iPhone12,5":                              return "iPhone 11 Pro Max"
            case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
            case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad (3rd generation)"
            case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad (4th generation)"
            case "iPad6,11", "iPad6,12":                    return "iPad (5th generation)"
            case "iPad7,5", "iPad7,6":                      return "iPad (6th generation)"
            case "iPad7,11", "iPad7,12":                    return "iPad (7th generation)"
            case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
            case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
            case "iPad11,4", "iPad11,5":                    return "iPad Air (3rd generation)"
            case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad mini"
            case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad mini 2"
            case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad mini 3"
            case "iPad5,1", "iPad5,2":                      return "iPad mini 4"
            case "iPad11,1", "iPad11,2":                    return "iPad mini (5th generation)"
            case "iPad6,3", "iPad6,4":                      return "iPad Pro (9.7-inch)"
            case "iPad7,3", "iPad7,4":                      return "iPad Pro (10.5-inch)"
            case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4":return "iPad Pro (11-inch)"
            case "iPad8,9", "iPad8,10":                     return "iPad Pro (11-inch) (2nd generation)"
            case "iPad6,7", "iPad6,8":                      return "iPad Pro (12.9-inch)"
            case "iPad7,1", "iPad7,2":                      return "iPad Pro (12.9-inch) (2nd generation)"
            case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8":return "iPad Pro (12.9-inch) (3rd generation)"
            case "iPad8,11", "iPad8,12":                    return "iPad Pro (12.9-inch) (4th generation)"
            case "AppleTV5,3":                              return "Apple TV"
            case "AppleTV6,2":                              return "Apple TV 4K"
            case "AudioAccessory1,1":                       return "HomePod"
            case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
            default:                                        return identifier
            }
            #elseif os(tvOS)
            switch identifier {
            case "AppleTV5,3": return "Apple TV 4"
            case "AppleTV6,2": return "Apple TV 4K"
            case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
            default: return identifier
            }
            #endif
        }
        
        return mapToDevice(identifier: identifier)
    }()
}


extension UINavigationController{
  func addCrossDesolveAnimation(time:CFTimeInterval) {
    let transition = CATransition()
    transition.duration = time
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.fade
    self.view.layer.add(transition, forKey: nil)
  }
}


extension UIImageView {
  func setImageColor(color: UIColor) {
    let templateImage = self.image?.withRenderingMode(.alwaysTemplate)
    self.image = templateImage
    self.tintColor = color
  }
}


//............................... SET VALUE  ............................................//

//MARK: - Manage function for value save -
extension NSDictionary {
    func getStringForID(key: String) -> String! {
        
        var strKeyValue : String = ""
        if self[key] != nil {
            if (self[key] as? Int) != nil {
                strKeyValue = String(self[key] as? Int ?? 0)
            } else if (self[key] as? String) != nil {
                strKeyValue = self[key] as? String ?? ""
            }else if (self[key] as? Double) != nil {
                strKeyValue = String(self[key] as? Double ?? 0)
            }else if (self[key] as? Float) != nil {
                strKeyValue = String(self[key] as? Float ?? 0)
            }else if (self[key] as? Bool) != nil {
                let bool_Get = self[key] as? Bool ?? false
                if bool_Get == true{
                    strKeyValue = "1"
                }else{
                    strKeyValue = "0"
                }
            }
        }
        return strKeyValue
    }
    
    func getArrayVarification(key: String) -> NSArray {
        
        var strKeyValue : NSArray = []
        if self[key] != nil {
            if (self[key] as? NSArray) != nil {
                strKeyValue = self[key] as? NSArray ?? []
            }
        }
        return strKeyValue
    }
}

extension UITextField{
    
   @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedString.Key.foregroundColor: newValue!, .font: UIFont.AppFontMedium(16)])
        }
    }
    
}


extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}



extension String {

    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}


extension Dictionary {
    func nullKeyRemoval() -> Dictionary {
        var dict = self

        let keysToRemove = Array(dict.keys).filter { dict[$0] is NSNull }
        for key in keysToRemove {
            dict.removeValue(forKey: key)
        }

        return dict
    }
}

extension Utils {
    static func getAuthToken() -> String {
        let token = kUserDefaults.value(forKey: AppMessage.Authorise_Token) as? String ?? ""
        return token
    }
    
    static func getLoginUserUsername() -> String {
        guard let empData = kUserDefaults.object(forKey: AppMessage.USER_DATA) as? [String: Any] else {
            return ""
        }
        return empData["name"] as? String ?? ""
    }
    
    static func getLoginUserGender() -> String {
        guard let empData = kUserDefaults.object(forKey: AppMessage.USER_DATA) as? [String: Any] else {
            return ""
        }
        return empData["gender"] as? String ?? "Male"
    }
}


extension CAGradientLayer {
    
    convenience init(frame: CGRect, colors: [UIColor], direction: GradientDirection) {
        self.init()
        self.frame = frame
        self.colors = []
        for color in colors {
            self.colors?.append(color.cgColor)
        }
        //  locations = [0.0, 0.55]
        //        startPoint = CGPoint(x: 1.0, y: 0.5)
        //        endPoint = CGPoint(x: 0.0, y: 0.5)
        
        switch direction {
        case .Right:
            startPoint = CGPoint(x: 0.0, y: 0.5)
            endPoint = CGPoint(x: 1.0, y: 0.5)
        case .Left:
            startPoint = CGPoint(x: 1.0, y: 0.5)
            endPoint = CGPoint(x: 0.0, y: 0.5)
        case .Bottom:
            startPoint = CGPoint(x: 0.5, y: 0.0)
            endPoint = CGPoint(x: 0.5, y: 1.0)
        case .Top:
            startPoint = CGPoint(x: 0.5, y: 1.0)
            endPoint = CGPoint(x: 0.5, y: 0.0)
        case .TopLeftToBottomRight:
            startPoint = CGPoint(x: 0.0, y: 0.0)
            endPoint = CGPoint(x: 1.0, y: 1.0)
        case .TopRightToBottomLeft:
            startPoint = CGPoint(x: 1.0, y: 0.0)
            endPoint = CGPoint(x: 0.0, y: 1.0)
        case .BottomLeftToTopRight:
            startPoint = CGPoint(x: 0.0, y: 1.0)
            endPoint = CGPoint(x: 1.0, y: 0.0)
        default:
            startPoint = CGPoint(x: 1.0, y: 1.0)
            endPoint = CGPoint(x: 0.0, y: 0.0)
        }
        
    }
    
    func creatGradientImage() -> UIImage? {
        
        var image: UIImage? = nil
        UIGraphicsBeginImageContext(bounds.size)
        if let context = UIGraphicsGetCurrentContext() {
            render(in: context)
            image = UIGraphicsGetImageFromCurrentImageContext()
        }
        UIGraphicsEndImageContext()
        return image
    }
    
}

extension UIImage {
    func getPixelColors(atLocation location: CGPoint, withFrameSize size: CGSize) -> [Float] {
        let x: CGFloat = (self.size.width) * location.x / size.width
        let y: CGFloat = (self.size.height) * location.y / size.height
        let pixelPoint: CGPoint = CGPoint(x: x, y: y)
        let pixelData = self.cgImage!.dataProvider!.data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        let pixelIndex: Int = ((Int(self.size.width) * Int(pixelPoint.y)) + Int(pixelPoint.x)) * 4
        let r = CGFloat(data[pixelIndex]) / CGFloat(255.0)
        let g = CGFloat(data[pixelIndex+1]) / CGFloat(255.0)
        let b = CGFloat(data[pixelIndex+2]) / CGFloat(255.0)
        
//        let a = CGFloat(data[pixelIndex+3]) / CGFloat(255.0)
        return [Float(r), Float(g), Float(b)]
        //let testColor = UIColor(red: r, green: g, blue: b, alpha: a)
        //return UIColor(red: r, green: g, blue: b, alpha: a)
    }
}

// MARK: -
extension Date {
    func dateString(format: String, locale: Locale? = nil) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        return df.string(from: self)
    }
    func dateStringEnglishLocale(format: String) -> String {
        let df = DateFormatter()
        df.dateFormat = format
        df.locale = Locale(identifier: "EN")
        return df.string(from: self)
    }
    
}

extension Dictionary where Key == String {
    mutating func addVikritiResultFinalValue() {
        if kUserDefaults.value(forKey: VIKRITI_SPARSHNA) != nil {
            //vikriti (sparshna) test has given
            let currentKPVStatus = Utils.getYourCurrentKPVState(isHandleBalanced: false)
            self["aggravation"] = currentKPVStatus.rawValue.lowercased() as? Value
        }
    }
    
    mutating func addPrakritiResultFinalValue() {
        if kUserDefaults.value(forKey: VIKRITI_SPARSHNA) != nil {
            //vikriti (sparshna) test has given
            let currentPraktitiStatus = Utils.getYourCurrentPrakritiStatus()
            self["prakriti_dosha"] = currentPraktitiStatus.rawValue.lowercased() as? Value
        }
    }
}

// MARK: -
extension String {
    func caseInsensitiveContains(_ string: String) -> Bool {
        return self.lowercased().contains(string.lowercased())
    }
    
    func caseInsensitiveEqualTo(_ string: String) -> Bool {
        return self.lowercased() == string.lowercased()
    }
}

extension Date {
    func adding(minutes: Int) -> Date {
        return Calendar.current.date(byAdding: .minute, value: minutes, to: self)!
    }
}


// MARK: - Static Properties for De-Duping
private extension DispatchQueue {
    static var workItems = [AnyHashable : DispatchWorkItem]()
    static var weakTargets = NSPointerArray.weakObjects()
    static func dedupeIdentifierFor(_ object: AnyObject) -> String {
        return "\(Unmanaged.passUnretained(object).toOpaque())." + String(describing: object)
    }
}

extension DispatchQueue {
    
    public func asyncDeduped(target: AnyObject, after delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        let dedupeIdentifier = DispatchQueue.dedupeIdentifierFor(target)
        if let existingWorkItem = DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier) {
            existingWorkItem.cancel()
            NSLog("Deduped work item: \(dedupeIdentifier)")
        }
        let workItem = DispatchWorkItem {
            DispatchQueue.workItems.removeValue(forKey: dedupeIdentifier)
            for ptr in DispatchQueue.weakTargets.allObjects {
                if dedupeIdentifier == DispatchQueue.dedupeIdentifierFor(ptr as AnyObject) {
                    work()
                    NSLog("Ran work item: \(dedupeIdentifier)")
                    break
                }
            }
        }
        DispatchQueue.workItems[dedupeIdentifier] = workItem
        DispatchQueue.weakTargets.addPointer(Unmanaged.passUnretained(target).toOpaque())
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}



extension Date {
    var minute: Int { Calendar.current.component(.minute, from: self) }
    var next10Minit: Date {
        Calendar.current.nextDate(after: self, matching: DateComponents(minute: minute >= 10 ? 0 : 10), matchingPolicy: .strict)!
    }
}
