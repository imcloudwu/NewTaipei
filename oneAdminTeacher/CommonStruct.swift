//
//  CommonStruct.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

//struct DisplayItem{
//    var Title : String
//    var Value : String
//    var OtherInfo : String
//    var ColorAlarm : Bool
//}

class DisplayItem{
    var Title : String
    var Value : String
    var OtherInfo : String
    var OtherInfo2 : String
    var OtherInfo3 : String
    var ColorAlarm : Bool
    
    convenience init(Title:String,Value:String,OtherInfo:String,ColorAlarm:Bool){
        
        self.init(Title:Title,Value:Value,OtherInfo:OtherInfo,OtherInfo2:"",OtherInfo3:"",ColorAlarm:ColorAlarm)
    }
    
    init(Title:String,Value:String,OtherInfo:String,OtherInfo2:String,OtherInfo3:String,ColorAlarm:Bool){
        self.Title = Title
        self.Value = Value
        self.OtherInfo = OtherInfo
        self.OtherInfo2 = OtherInfo2
        self.OtherInfo3 = OtherInfo3
        self.ColorAlarm = ColorAlarm
    }
}

protocol SemesterProtocol
{
    var SchoolYear : String { get set }
    var Semester : String { get set }
}

protocol ContainerViewProtocol
{
    //var StudentData : EmbaStudent! { get set }
    var ParentNavigationItem : UINavigationItem? { get set }
}

class TeacherAccount : Equatable{
    var SchoolName : String
    var Name : String
    var Account : String
    var UUID : String
    
    init(schoolName:String,name:String,account:String){
        SchoolName = schoolName
        Name = name
        Account = account
        UUID = ""
    }
    
//    init(uuid:String){
//        SchoolName = ""
//        Name = ""
//        Account = ""
//        UUID = uuid
//    }
}

func ==(lhs: TeacherAccount, rhs: TeacherAccount) -> Bool {
    return lhs.SchoolName == rhs.SchoolName && lhs.Name == rhs.Name && lhs.Account == rhs.Account
}

struct SemesterItem : Equatable,Comparable{
    var SchoolYear : String
    var Semester : String
    
    var Description: String {
        get {
            if Semester == "0"{
                return "第\(SchoolYear)學年度夏季學期"
            }
            
            return "第\(SchoolYear)學年度\(Semester)學期"
        }
    }
    
    var CompareValue : Int{
        if let sy = Int(SchoolYear) , let sm = Int(Semester){
            return sy * 10 + sm
        }
        else{
            return 0
        }
    }
}

func ==(lhs: SemesterItem, rhs: SemesterItem) -> Bool {
    return lhs.SchoolYear == rhs.SchoolYear && lhs.Semester == rhs.Semester
}

func <(lhs: SemesterItem, rhs: SemesterItem) -> Bool{
    return lhs.CompareValue < rhs.CompareValue
}

//Mark : My Toast Class
class Toast {
    
    var container: UIView = UIView()
    var Message: UILabel = UILabel()
    
    func ShowMessage(uiView: UIView,msg:String) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        Message.text = msg
        Message.alpha = 1
        Message.textColor = UIColor.whiteColor()
        Message.textAlignment = NSTextAlignment.Center
        Message.frame = CGRectMake(0, 0, 200, 50)
        Message.center = container.center
        Message.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        Message.layer.masksToBounds = true
        Message.layer.cornerRadius = 10
        
        container.addSubview(Message)
        uiView.addSubview(container)
    }
    
    func HideMessage(uiView: UIView) {
        container.removeFromSuperview()
    }
    
    /*
    Show customized activity indicator,
    actually add activity indicator to passing view
    
    @param uiView - add activity indicator to this view
    */
    func ToastMessage(uiView: UIView,msg:String,callback:(() -> ())?) {
        container.frame = uiView.frame
        container.center = uiView.center
        container.backgroundColor = UIColorFromHex(0xffffff, alpha: 0.3)
        
        Message.text = msg
        Message.alpha = 1
        Message.textColor = UIColor.whiteColor()
        Message.textAlignment = NSTextAlignment.Center
        Message.frame = CGRectMake(0, 0, 200, 50)
        Message.center = container.center
        Message.backgroundColor = UIColorFromHex(0x444444, alpha: 0.7)
        Message.layer.masksToBounds = true
        Message.layer.cornerRadius = 10
        
        container.addSubview(Message)
        uiView.addSubview(container)
        
        UIView.animateWithDuration(1.5, animations: { () -> Void in
            self.Message.alpha = 0
            }) { (success) -> Void in
                self.container.removeFromSuperview()
                
                if let call = callback{
                    call()
                }
        }
    }
    
    /*
    Define UIColor from hex value
    
    @param rgbValue - hex color value
    @param alpha - transparency level
    */
    func UIColorFromHex(rgbValue:UInt32, alpha:Double=1.0)->UIColor {
        let red = CGFloat((rgbValue & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgbValue & 0xFF)/256.0
        return UIColor(red:red, green:green, blue:blue, alpha:CGFloat(alpha))
    }
    
}