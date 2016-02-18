//
//  VideoCoreData.swift
//  NewTaipei
//
//  Created by Cloud on 11/13/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class VideoCoreDataClass{
    
    var appDelegate : AppDelegate
    var mocMain : NSManagedObjectContext!
    
    var privateContext : NSManagedObjectContext!
    
    init(){
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        mocMain = appDelegate.managedObjectContext!
        
        privateContext = NSManagedObjectContext(
            concurrencyType: .PrivateQueueConcurrencyType)
        privateContext.persistentStoreCoordinator =
            mocMain.persistentStoreCoordinator
    }
    
    func Reset(){
        mocMain.reset()
        privateContext.reset()
    }
    
    //Core Data using
    func SaveCatchData(video:VideoItem) {
        
        //let fetchRequest = NSFetchRequest(entityName: "Student")
        //fetchRequest.predicate = NSPredicate(format: "dsns=%@ and id=%@", student.DSNS, student.ID)
        
        //    var needInsert = true
        //
        //    if let fetchResults = managedObjectContext.executeFetchRequest(fetchRequest, error: nil) as? [NSManagedObject] {
        //        if fetchResults.count != 0 {
        //
        //            var managedObject = fetchResults[0]
        //            //managedObject.setValue(student.Name, forKey: "name")
        //            managedObject.setValue(student.ClassName, forKey: "class_name")
        //            managedObject.setValue(student.ContactPhone, forKey: "phone")
        //            managedObject.setValue(UIImagePNGRepresentation(student.Photo), forKey: "photo")
        //
        //            needInsert = false
        //        }
        //    }
        
        //if needInsert || forceInsert{
        let myEntityDescription = NSEntityDescription.entityForName("Video", inManagedObjectContext: mocMain)
        
        let myObject = NSManagedObject(entity: myEntityDescription!, insertIntoManagedObjectContext: mocMain)
        
        myObject.setValue(video.Id, forKey: "id")
        myObject.setValue(video.Title, forKey: "title")
        myObject.setValue(video.StreamUrl, forKey: "url")
        myObject.setValue(video.KeyWords.joinWithSeparator(";"), forKey: "keywords")
        
        do {
            //myObject.setValue(UIImagePNGRepresentation(student.Photo), forKey: "photo")
            //}
        
            try mocMain.save()
        } catch _ {
        }
    }
    
    //Core Data using
    func LoadCatchData() -> [VideoItem]{
        
        var retVal = [VideoItem]()
        
        let fetchRequest = NSFetchRequest(entityName: "Video")
        
        //var error: NSError?
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        for obj in results {
            
            let id = obj.valueForKey("id") as! String
            let title = obj.valueForKey("title") as! String
            let url = obj.valueForKey("url") as! String
            let keywords = obj.valueForKey("keywords") as! String
            
            let keywordsArr = keywords.componentsSeparatedByString(";")
            //let image = obj.valueForKey("image") as! UIImage
            
            let vi = VideoItem(Id: id, Title: title, StreamUrl: url, KeyWords: keywordsArr)
            
            retVal.append(vi)
            
            //_studentData.append(Student(Photo: UIImage(data: photo), ClassName : class_name, Name: name, Phone: phone))
        }
        
        return retVal
    }
    
    //Core Data using
    func LoadCatchImage(item:VideoItem) -> UIImage?{
        
        let fetchRequest = NSFetchRequest(entityName: "Video")
        fetchRequest.predicate = NSPredicate(format: "id=%@", item.Id)
        
        //var error: NSError?
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
        
        if results.count > 0{
            
            if let image = results[0].valueForKey("image") as? UIImage{
                return image
            }
            
        }
        
        return nil
    }
    
    //Core Data using
    func UpdateCatchImage(item:VideoItem,img:UIImage?){
        
        privateContext.performBlock { () -> Void in
            
            let fetchRequest = NSFetchRequest(entityName: "Video")
            fetchRequest.predicate = NSPredicate(format: "id=%@", item.Id)
            
            //var error: NSError?
            
            let results = (try! self.privateContext.executeFetchRequest(fetchRequest)) as! [NSManagedObject]
            
            if results.count > 0{
                
                results[0].setValue(img, forKey: "image")
                
                do{
                   try self.privateContext.save()
                }
                catch{
                    
                }
                
            }
        }
    }
    
    //Core Data using
    func DeleteAll() {
        
        let fetchRequest = NSFetchRequest(entityName: "Video")
        
        let results = (try! mocMain.executeFetchRequest(fetchRequest)) as![NSManagedObject]
        
        for obj in results {
            mocMain.deleteObject(obj)
        }
        
        do {
            try mocMain.save()
        } catch _ {
        }
    }
}
