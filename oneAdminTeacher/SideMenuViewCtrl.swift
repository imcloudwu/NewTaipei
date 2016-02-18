//
//  SideMenuViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/10/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit
import Parse

class SideMenuViewCtrl: UIViewController{
    
    @IBOutlet weak var MyPhoto: UIImageView!
    @IBOutlet weak var MyName: UILabel!
    @IBOutlet weak var MyEmail: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MyPhoto.layer.cornerRadius = MyPhoto.frame.width / 2
        MyPhoto.layer.masksToBounds = true
        
        MyPhoto.layer.borderWidth = 3.0
        MyPhoto.layer.borderColor = UIColor.whiteColor().CGColor
        
//        var background = UIImageView(image: UIImage(named: "sidebackground.jpg"))
//        background.frame = self.view.bounds
//        background.contentMode = UIViewContentMode.ScaleToFill
//        self.view.insertSubview(background, atIndex: 0)
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        MyName.text = Global.MyName
        MyEmail.text = Global.MyEmail
        
        MyPhoto.image = Global.MyPhoto
    }
    
    @IBAction func Btn1(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("SchoolQuery")
        
        ChangeContentView(nextView!)
    }
    
    @IBAction func Btn2(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("VideoQuery")
        
        ChangeContentView(nextView!)
    }
    
    @IBAction func MsgBtn(sender: AnyObject) {
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("MessageQuery")
        
        ChangeContentView(nextView!)
    }
    
    @IBAction func Btn3(sender: AnyObject) {
        
        let alert = UIAlertController(title: "確認要登出嗎？", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            self.Logout()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
//        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("Message") as! UIViewController
//        
//        ChangeContentView(nextView)
    }
    
    func Logout(){
        
        HttpClient.Get("http://pts.ntpc.edu.tw/oauth/ntpc_logout",successCallback:{ (response) -> Void in
            print("Logout")
        })
        
        Keychain.delete("refreshToken")
        
        Global.Reset()
        
        DisableSideMenu()
        
        NotificationService.UnRegister(PFInstallation.currentInstallation().objectId, accessToken: Global.AccessToken)
        
        let storage : NSHTTPCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in storage.cookies!
        {
            storage.deleteCookie(cookie)
        }
        
        NSUserDefaults.standardUserDefaults()
        
        let backView = self.storyboard?.instantiateViewControllerWithIdentifier("StartView") as! UINavigationController
        
        ChangeContentView(backView)
    }
    
}

struct MenuItem {
    var Name : String
}
