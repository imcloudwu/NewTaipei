//
//  SettingCoreData.swift
//  NewTaipei
//
//  Created by Cloud on 12/2/15.
//  Copyright © 2015 ischool. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class SettingCoreData{
    //Core Data using
    static func SaveCatchData(setting:Setting) {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            
            //update
            if fetchResults.count != 0 {
                
                let managedObject = fetchResults[0]
                
                managedObject.setValue(setting.Registed, forKey: "registed")
            }
            else{
                //insert
                let myEntityDescription = NSEntityDescription.entityForName("Setting", inManagedObjectContext: managedObjectContext)
                
                let myObject = NSManagedObject(entity: myEntityDescription!, insertIntoManagedObjectContext: managedObjectContext)
                
                myObject.setValue(setting.Registed, forKey: "registed")
            }
        }
        
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
    
    //Core Data using
    static func LoadCatchData() -> Setting?{
        
        var retVal : Setting?
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        if let fetchResults = (try? managedObjectContext.executeFetchRequest(fetchRequest)) as? [NSManagedObject] {
            
            if fetchResults.count != 0 {
                
                let managedObject = fetchResults[0]
                
                retVal = Setting(Registed: false)
                
                if let registed = managedObject.valueForKey("registed") as? Bool{
                    
                    retVal?.Registed = registed
                }
            }
        }
        
        return retVal
    }
    
    //Core Data using
    static func DeleteAll() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let managedObjectContext = appDelegate.managedObjectContext!
        let fetchRequest = NSFetchRequest(entityName: "Setting")
        
        let results = (try! managedObjectContext.executeFetchRequest(fetchRequest)) as![NSManagedObject]
        
        for obj in results {
            managedObjectContext.deleteObject(obj)
        }
        
        do {
            try managedObjectContext.save()
        } catch _ {
        }
    }
}

struct Setting{
    var Registed : Bool
}
