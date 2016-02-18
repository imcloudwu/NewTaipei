//
//  Extension.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

//extension Optional{
//    func ParseInt() -> Int{
//        if let str = self as? String{
//            return str.toInt() ?? 0
//        }
//
//        return 0
//    }
//}

extension NSDate {
    public var stringValue: String {
        
        let secondsAgo:NSTimeInterval = self.timeIntervalSinceNow
        
        let value = -1*secondsAgo
        
        let day = Int(value / (60*60*24))
        let hour = Int(value / (60*60))
        let min = Int(value / (60))
        let sec = Int(value)
        
        //        if day > 3 {
        //            let dateStr = "\(self)"
        //
        //            return dateStr.substringToIndex(advance(dateStr.startIndex, 10))
        //        }
        //        else if day > 0 {
        //            return "\(day) 天以前"
        //        }
        if day > 0{
            let format:NSDateFormatter = NSDateFormatter()
            format.dateFormat = "yyyy/MM/dd"
            
            return format.stringFromDate(self)
        }
        else if hour > 0 {
            return "\(hour) 小時以前"
        }
        else if min > 0 {
            return "\(min) 分鐘以前"
        }
        else{
            return "\(sec) 秒以前"
        }
        
    }
}

extension HttpClient{
    
    class func GetWithHeader(url:String) -> NSData? {
        
        var response: NSURLResponse?
        //var error: NSError?
        
        let request = NSMutableURLRequest()
        
        request.HTTPMethod = "GET"
        request.URL = NSURL(string: url)
        
        request.addValue("Basic dGVzdDEyMzQ6dGVzdDEyMzQ=", forHTTPHeaderField: "Authorization")
        
        var tokenData: NSData?
        do {
            tokenData = try NSURLConnection.sendSynchronousRequest(request,returningResponse: &response)
        } catch _ {
            //error = error1
            tokenData = nil
        }
        
        return tokenData
    }
}

extension Connection{
    
    func SendRequest(targetService:String,bodyContent:String,inout _ error: DSFault!) -> String {
        
        var e : DSFault!
        
        var rsp = self.sendRequest(targetService, bodyContent: bodyContent, &e)
        
        if e != nil{
            self.connect(self.accessPoint, self.targetContract, SecurityToken.createOAuthToken(Global.AccessToken), &error)
            rsp = self.sendRequest(targetService, bodyContent: bodyContent, &e)
        }
        
        error = e
        
        return rsp == nil ? "" : rsp
    }
}

//if failed will return 0
extension String {
    
    var intValue: Int {
        return Int(self) ?? 0
    }
    
    var int16Value: Int16 {
        return Int16(self.intValue)
    }
    
    var doubleValue: Double {
        return (self as NSString).doubleValue
    }
    
    public var dataValue: NSData {
        return self.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)!
    }
    
    public var UrlEncoding: String?{
        return self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
    }
    
//    func PadLeft(leng:Int,str:String) -> String{
//        
//        if (self as NSString).length < leng {
//            var l = leng - (self as NSString).length
//            
//            var s = ""
//            
//            for i in 0...l{
//                s += str
//            }
//            
//            return s + self
//        }
//        
//        return self
//    }
    
    func PadRight(leng:Int,str:String) -> String{
        
        if (self as NSString).length < leng {
            let l = leng - (self as NSString).length
            
            var s = ""
            
            for _ in 1...l{
                s += str
            }
            
            return self + s
        }
        
        return self
    }
    
    var encodeXmlString: String{

//        var retVal = self.stringByReplacingOccurrencesOfString("&",withString: "&amp;")
//        retVal = retVal.stringByReplacingOccurrencesOfString("<",withString: "&lt;")
//        retVal = retVal.stringByReplacingOccurrencesOfString(">",withString: "&gt;")
//        retVal = retVal.stringByReplacingOccurrencesOfString("\'",withString: "&apos;")
//        retVal = retVal.stringByReplacingOccurrencesOfString("\"",withString: "&quot;")
        
        return self.stringByReplacingOccurrencesOfString("&",withString: "&amp;")
    }
    
    var decodeXmlString: String{
        
        var retVal = self.stringByReplacingOccurrencesOfString("&lt;",withString: "<")
        retVal = retVal.stringByReplacingOccurrencesOfString("&gt;",withString: ">")
        retVal = retVal.stringByReplacingOccurrencesOfString("&amp;",withString: "&")
        retVal = retVal.stringByReplacingOccurrencesOfString("&apos;",withString: "\'")
        retVal = retVal.stringByReplacingOccurrencesOfString("&quot;",withString: "\"")
        
        return retVal
    }
}


extension Double {
    
    //四捨五入到小數點第二位(前一位數是偶數時是五捨六入)
//    func toString(precision : Int) -> String {
//        return String(format: "%.\(precision)f", self)
//    }
    
    func Round(precision : Int16) -> Double {
        let x = NSDecimalNumber(string: "\(self)")
        let y = NSDecimalNumber(int: 1)
        
        //小數點第二位四捨五入進位
        let behavior = NSDecimalNumberHandler(roundingMode: NSRoundingMode.RoundPlain, scale: precision, raiseOnExactness: true, raiseOnOverflow: true, raiseOnUnderflow: true, raiseOnDivideByZero: true)
        
        return x.decimalNumberByDividingBy(y, withBehavior: behavior).doubleValue
    }
    
    func ToString(precision : Int16) -> String {
        return String(format: "%.\(precision)f", self)
    }
}

extension NSData {
    public var stringValue: String {
        return NSString(data: self, encoding: NSUTF8StringEncoding)! as String
    }
    
    func GetResizeImage(scale:CGFloat) -> UIImage?{
        
        if let img = UIImage(data: self){
            
            let width = img.size.width
            let height = img.size.height
            
            UIGraphicsBeginImageContextWithOptions(CGSizeMake(width * scale, height * scale), false, 1)
            img.drawInRect(CGRectMake(0, 0, width * scale, height * scale))
            
            let newImage = UIGraphicsGetImageFromCurrentImageContext()
            
            UIGraphicsEndImageContext()
            
            return UIImage(data: UIImageJPEGRepresentation(newImage, 0.5)!)!
        }
        
        return nil
    }
}

public func <(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedAscending
}

public func ==(a: NSDate, b: NSDate) -> Bool {
    return a.compare(b) == NSComparisonResult.OrderedSame
}

extension NSDate: Comparable { }


//extension JSON {
//    public var arrayStringValue: [String] {
//        get {
//            var value = [String]()
//            
//            for elem in arrayValue{
//                if !elem.stringValue.isEmpty{
//                    value.append(elem.stringValue)
//                }
//            }
//            
//            return value
//        }
//    }
//}
