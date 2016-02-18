//
//  NotificationService.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/27/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Parse

public class NotificationService{
    
    public static var Domain = "pns.ntpc.edu.tw"
    
    private static var registerUrl : String = "http://\(Domain)/private/mobile/register_token"
    
    private static var unRegisterUrl : String = "https://\(Domain)/private/mobile/remove_token"
    
    private static var getMessageUrl : String = "https://\(Domain)/private/mobile/get_my_messages?page_no=%@&access_token=%@"
    
    private static var getMessageByIdUrl : String = "https://1campus.net/notification/api/get/id/%@/token/%@"
    
    private static var getMessageCountUrl : String = "http://\(Domain)/private/mobile/get_my_messages_count?access_token=%@"
    
    private static var setReadUrl : String = "https://\(Domain)/private/mobile/set_read_history"
    
    private static var tempDeleteMessageUrl : String = "https://\(Domain)/private/mobile/temp_delete_message"
    
    private static var deleteMessageUrl : String = "https://\(Domain)/private/mobile/permanent_delete_message"
    
    private static var getTempMessageUrl : String = "https://\(Domain)/private/mobile/get_temp_deleted_messages?access_token=%@"
    
    private static var deleteTempMessageUrl : String = "https://\(Domain)/private/mobile/permanent_delete_message"
    
    private static var sendMessageUrl : String = "https://1campus.net/notification/api/post/token/%@"
    
    private static var replyUrl : String = "https://1campus.net/notification/api/put/%@/reply/token/%@"
    
    private static var newMessageDelegate : (() -> ())?
    
    private static var mustReload = false
    
    static var NeedReload : Bool{
        get{
            return mustReload
        }
    }
    
    static func SetNewMessageDelegate(callback:(()->())?){
        newMessageDelegate = callback
    }
    
    static func ExecuteNewMessageDelegate(){
        
        if newMessageDelegate != nil{
            mustReload = false
            newMessageDelegate!()
        }
        else{
            mustReload = true
        }
    }
    
    //刪除暫存訊息
    static func DeleteTempMessage(msgId:String,accessToken:String,callback:(() -> ())?){
        
        let req = "{\"msg_id\": \"\(msgId)\",\"access_token\": \"\(accessToken)\"}"
    
        HttpClient.Post(deleteTempMessageUrl, json: req, successCallback: { (response) -> Void in
            
            callback?()
            
            }, errorCallback: { (error) -> Void in
                
                callback?()
                
            }, prepareCallback: nil)
    }
    
    //取得暫刪訊息
    static func GetTempMessages(accessToken:String) -> NSData{
        
        let url = NSString(format: getTempMessageUrl, accessToken)
        
        var rsp : NSData?
        
        do{
            rsp = try HttpClient.Get(url as String)
        }
        catch _{
            rsp = nil
        }
        
        if let result = rsp{
            return result
        }
        return NSData()
    }
    
    //暫時刪除訊息
    static func TempDelete(msgId:String,accessToken:String,callback:()->()){
        
        let req = "{\"msg_id\": \"\(msgId)\",\"access_token\": \"\(accessToken)\"}"
        
        HttpClient.Post(tempDeleteMessageUrl, json: req, successCallback: { (response) -> Void in
            
            callback()
            
            }, errorCallback: { (error) -> Void in
                
                callback()
                
            }, prepareCallback: nil)
    }
    
    //刪除訊息
    static func Delete(msgId:String,accessToken:String,callback:()->()){
        
        let req = "{\"msg_id\": \"\(msgId)\",\"access_token\": \"\(accessToken)\"}"
        
        HttpClient.Post(deleteMessageUrl, json: req, successCallback: { (response) -> Void in
            
            callback()
            
            }, errorCallback: { (error) -> Void in
                
                callback()
                
            }, prepareCallback: nil)
    }
    
    //註冊裝置 step1
    static func Register(accessToken:String,callback:()->()){
        
        //已註冊過直接呼叫回調
        if let setting : Setting = SettingCoreData.LoadCatchData() where setting.Registed {
            
            callback()
        }
        else{
            
            let installation = PFInstallation.currentInstallation()
            
            //var objId : String!
            
            if let id = installation.objectId{
                //objId = id
                
                self.Register(id, accessToken: accessToken, callback: callback)
            }
            else{
                installation.saveInBackgroundWithBlock({ (finished, err) -> Void in
                    if let nid = installation.objectId{
                        //objId = nid
                        
                        self.Register(nid, accessToken: accessToken, callback: callback)
                    }
                })
            }
        }
    }
    
    //註冊裝置 step2
    static func Register(objId:String,accessToken:String,callback:()->()){
        
        let req = "{\"obj_id\": \"\(objId)\",\"access_token\": \"\(accessToken)\"}"
        
        //let url = NSString(string: registerUrl)
        
        HttpClient.Post(registerUrl, json: req, successCallback: { (response) -> Void in
            //print(response)
            
            SettingCoreData.SaveCatchData(Setting(Registed: true))
            
            callback()
            
            }, errorCallback: { (error) -> Void in
                //println("failed")
                
                callback()
                
            }, prepareCallback: nil)
        
        callback()
        
    }
    
    //反註冊裝置
//    static func UnRegister(deviceToken:String?,accessToken:String){
//        
//        if let dt = deviceToken{
//            let req = "{\"deviceType\": \"ios\",\"deviceToken\": \"\(dt)\"}"
//            
//            let url = NSString(format: unRegisterUrl, accessToken)
//            
//            try! HttpClient.Put(url as String, body: req)
//        }
//    }
    
    static func UnRegister(objectId:String?,accessToken:String){
        
        if let obj_id = objectId{
            
            let req = "{\"obj_id\": \"\(obj_id)\",\"access_token\": \"\(accessToken)\"}"
            
            HttpClient.Post(unRegisterUrl, json: req, successCallback: { (response) -> Void in
                print(response)
            })
            
        }
    }
    
    //取得訊息數量
    static func GetMessageCount(accessToken:String,defalut:Int) -> Int{
        
        let url = NSString(format: getMessageCountUrl, accessToken)
        
        var rsp : NSData?
        
        do{
            rsp = try HttpClient.Get(url as String)
        }
        catch _{
            rsp = nil
        }
        
        //println(NSString(data: rsp!, encoding: NSUTF8StringEncoding))
        
        if let data = rsp{
            
            let json = JSON(data: data)
            
            let count = json["msg_count"].intValue
            
            return count
        }
        
        return defalut
    }
    
    //取得訊息
    static func GetMessage(page:String,accessToken:String) -> NSData{
        
        let url = NSString(format: getMessageUrl, page, accessToken)
        
        var rsp : NSData?
        
        do{
            rsp = try HttpClient.Get(url as String)
        }
        catch _{
            rsp = nil
        }
        
        if let result = rsp{
            return result
        }
        
        return NSData()
    }
    
    //取得指定訊息
    static func GetMessageById(id:String,accessToken:String) -> NSData{
        
        let url = NSString(format: getMessageByIdUrl, id, accessToken)
        
        var rsp : NSData?
        
        do{
            rsp = try HttpClient.Get(url as String)
        }
        catch _{
            rsp = nil
        }
        
        if let result = rsp{
            return result
        }
        return NSData()
    }
    
    //設為已讀
    static func SetRead(msgId:String,accessToken:String){
        
        //let url = NSString(format: setReadUrl, accessToken)
        
        //try! HttpClient.Put(url as String, body: "[\"\(msgId)\"]")
        
        let req = "{\"message_id\": \"\(msgId)\",\"access_token\": \"\(accessToken)\"}"
        
//        let _ = try? HttpClient.Post(setReadUrl, body: req)
//        
//        HttpClient.Post(setReadUrl, json: req, successCallback: { (response) -> Void in
//            print(response)
//        })
        
        HttpClient.Post(setReadUrl, json: req, successCallback: { (response) -> Void in
            print(response)
            }, errorCallback: { (error) -> Void in
                print(error)
            }, prepareCallback: nil)
    }
    
    //發送訊息
    static func SendMessage(schoolName:String,type:String,sender:String,redirect:String,msg:String,receivers:[TeacherAccount],options:[String],accessToken:String){
        
        var template = ""
        
        for receiver in receivers{
            
            if receiver == receivers.first{
                template += "["
            }
            
            if receiver != receivers.last{
                template += "{\"uuid\":\"\(receiver.UUID)\",\"name\":\"\(receiver.Name)\"},"
            }
            else{
                template += "{\"uuid\":\"\(receiver.UUID)\",\"name\":\"\(receiver.Name)\"}]"
            }
            
        }
        
        var optionString = ""
        var optionTemplate = ""
        
        for option in options{
            if option == options.first{
                optionString += "["
            }
            
            if option != options.last{
                optionString += "\"\(option)\","
            }
            else{
                optionString += "\"\(option)\"]"
            }
        }
        
        if optionString != ""{
            optionTemplate = ",\"options\": \(optionString)"
        }
        
        //字串取代
        let replace_msg = msg.stringByReplacingOccurrencesOfString("\n",withString: "\\n")
        
        let sampleBody = "{\"message\":\"\(replace_msg)\",\"type\":\"\(type)\"\(optionTemplate),\"sender\":\"\(sender)\",\"redirect\":\"\(redirect)\",\"group\":{\"dsnsname\":\"\(schoolName)\"},\"to\":\(template)}"
        
        let url = NSString(format: sendMessageUrl, accessToken)
        
        HttpClient.Post(url as String, json: sampleBody, successCallback: { (response) -> Void in
            //do nothing
            self.ExecuteNewMessageDelegate()
        }, errorCallback: { (error) -> Void in
            //do nothing
            print(error)
        }, prepareCallback: nil)
    }
    
    //回覆問卷
    static func ReplySingle(msgId:String,accessToken:String,answerIndex:Int){
        
        let url = NSString(format: replyUrl, msgId, accessToken)
        
        try! HttpClient.Put(url as String, body: "{ \"reply\": \(answerIndex) }")
    }
    
    //回覆問卷
    static func ReplyMultiple(msgId:String,accessToken:String,answers:[Int]){
        
        let url = NSString(format: replyUrl, msgId, accessToken)
        
        try! HttpClient.Put(url as String, body: "{ \"reply\": \(answers.description) }")
    }
}
