//
//  MessageCoreData.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/7/24.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class MessageCoreDataClass{
    
    //static var LockQueue = dispatch_queue_create("PhotoCoreDataClassLockQueue", nil)
    
    var appDelegate : AppDelegate
    var mocMain : NSManagedObjectContext!
    
    init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        mocMain = appDelegate.managedObjectContext!
    }
    
    func Reset(){
        mocMain.reset()
    }
    
    //Core Data using
    func SaveCatchData(msg:MessageItem) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.predicate = NSPredicate(format: "id=%@", msg.Id)
        
        var needInsert = true
        
        //update
        if let fetchResults = (try? mocMain.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            if fetchResults.count != 0 {
                
                let managedObject = fetchResults[0]
                
                //被改成已讀的才必須要更新
                if !msg.IsNew{
                    managedObject.setValue(false, forKey: "isNew")
                }
                
                //已經投過票必須要更新
//                if msg.Voted{
//                    managedObject.setValue(msg.Voted, forKey: "voted")
//                }
                
                needInsert = false
            }
        }
        
        //insert
        if needInsert {
            let myEntityDescription = NSEntityDescription.entityForName("Message", inManagedObjectContext: mocMain)
            
            let myObject = NSManagedObject(entity: myEntityDescription!, insertIntoManagedObjectContext: mocMain)
            
            myObject.setValue(msg.Id, forKey: "id")
            myObject.setValue(msg.Date, forKey: "date")
            myObject.setValue(msg.IsNew, forKey: "isNew")
            myObject.setValue(msg.Subject, forKey: "subject")
            myObject.setValue(msg.Body, forKey: "body")
            //myObject.setValue(msg.Redirect, forKey: "redirect")
            //myObject.setValue(msg.DsnsName, forKey: "dsnsName")
            //myObject.setValue(msg.Name, forKey: "name")
            //myObject.setValue(msg.IsSender, forKey: "sender")
            //myObject.setValue(msg.IsReceiver, forKey: "receiver")
            myObject.setValue(msg.Type, forKey: "type")
            //myObject.setValue(msg.Voted, forKey: "voted")
            myObject.setValue(msg.Ip, forKey: "ip")
            myObject.setValue(msg.Sender, forKey: "sender")
        }
        
        do {
            try mocMain.save()
        } catch _ {
        }
    }
    
    //Core Data using
    func LoadCatchData() -> [MessageItem]{
        
        var retVal = [MessageItem]()
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        
        var results : [NSManagedObject]!
        
        do{
            let r = try mocMain.executeFetchRequest(fetchRequest)
            results = r as! [NSManagedObject]
        }
        catch{
            results = [NSManagedObject]()
        }
        
        for obj in results {
            let id = obj.valueForKey("id") as! String
            let date = obj.valueForKey("date") as! NSDate
            let isNew = obj.valueForKey("isNew") as! Bool
            let subject = obj.valueForKey("subject") as! String
            let body = obj.valueForKey("body") as! String
            //let redirect = obj.valueForKey("redirect") as! String
            //let dsnsName = obj.valueForKey("dsnsName") as! String
            //let name = obj.valueForKey("name") as! String
            //let isSender = obj.valueForKey("sender") as! Bool
            //let isReceiver = obj.valueForKey("receiver") as! Bool
            let type = obj.valueForKey("type") as! String
            //let voted = obj.valueForKey("voted") as! Bool
            
            let sender = obj.valueForKey("sender") as! String
            let ip = obj.valueForKey("ip") as! String
            
            let mi = MessageItem(id: id, date: date, isNew: isNew, type: type, subject: subject, body: body, sender: sender, ip: ip)
            
            retVal.append(mi)
            
//            retVal.append(MessageItem(id: id, date: date, isNew: isNew, title: title, content: content, redirect: redirect, dsnsName: dsnsName, name: name, isSender: isSender, isReceiver: isReceiver, type: type, voted: voted))
            
            //_studentData.append(Student(Photo: UIImage(data: photo), ClassName : class_name, Name: name, Phone: phone))
        }
        
        //這個會爆炸...
        //retVal.sortInPlace({ $0.Date > $1.Date })
        
        retVal = retVal.sort({ $0.Date > $1.Date })
        
        return retVal
    }
    
    //Core Data using
    func DeleteAll() {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        for obj in results {
            mocMain.deleteObject(obj)
        }
        
        do {
            try mocMain.save()
        } catch _ {
        }
    }
    
    //Core Data using
    func DeleteMessage(msg:MessageItem) {
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        fetchRequest.predicate = NSPredicate(format: "id=%@", msg.Id)
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        for obj in results {
            mocMain.deleteObject(obj)
        }
        
        do {
            try mocMain.save()
        } catch _ {
        }
    }
    
    func GetCount() -> Int{
        
        let fetchRequest = NSFetchRequest(entityName: "Message")
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        return results.count
    }
}