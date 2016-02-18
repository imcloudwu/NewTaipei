//
//  WebViewCtrl.swift
//  NewTaipei
//
//  Created by Cloud on 11/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation
import MediaPlayer

class VideoPlayerViewCtrl: UIViewController{
    
    //@IBOutlet weak var webView: UIWebView!
    
    var BaseData : VideoItem!
    
    var moviePlayer : MPMoviePlayerController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //webView.delegate = self
        
        self.SetWatchedRecord()
        
        let target = BaseData.StreamUrl
        
        if target.hasSuffix(".wmv") || target.hasSuffix(".asf"){
            
            let alert = UIAlertController(title: "此影片是wmv格式,無法在此裝置上播放", message: "", preferredStyle: UIAlertControllerStyle.Alert)
            
            alert.addAction(UIAlertAction(title: "確定", style: UIAlertActionStyle.Default, handler: { (a) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        else{
            
            let url:NSURL = NSURL(string: target.UrlEncoding!)!
            
            moviePlayer = MPMoviePlayerController(contentURL: url)
            
            self.view.addSubview(moviePlayer!.view)
            
            moviePlayer?.fullscreen = true
            
            moviePlayer?.controlStyle = MPMovieControlStyle.Embedded
        }
        
//        let value = UIInterfaceOrientation.LandscapeLeft.rawValue
//        UIDevice.currentDevice().setValue(value, forKey: "orientation")
        

        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        SetVideoFrame()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func didRotateFromInterfaceOrientation(fromInterfaceOrientation: UIInterfaceOrientation) {
        SetVideoFrame()
    }
    
    func SetVideoFrame(){
        
        moviePlayer?.view.frame = CGRect(x: 0, y: 0, width: Global.ScreenSize.width, height: Global.ScreenSize.width)
        moviePlayer?.view.center = self.view.center
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if parent == nil {
            //println("really?")
            moviePlayer?.stop()
            moviePlayer = nil
        }
    }
    
    func SetWatchedRecord(){
        
        let req = "{\"video_id\": \"\(BaseData.Id)\",\"access_token\": \"\(Global.AccessToken)\"}"
        
        HttpClient.Post("https://pts.ntpc.edu.tw/private/mobile/set_video_history", json: req, successCallback: {(response) -> Void in
            print(response)
        })
    }
    
    
}

