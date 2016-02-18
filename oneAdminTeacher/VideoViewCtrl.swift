//
//  VideoViewCtrl.swift
//  NewTaipei
//
//  Created by Cloud on 11/12/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import Foundation

class VideoViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    @IBOutlet weak var progressBar: UIProgressView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    var _SegmentItems = [String]()
    
    var Datas = [VideoItem]()
    
    var CurrentDatas = [VideoItem]()
    
    var DisplayDatas = [VideoItem]()
    
    var PT : ProgressTimer!
    
    let GetImgUrl = "http://stream.ntpc.edu.tw/images/%@.jpg"
    
    @IBAction func SegmentSelected(sender: AnyObject) {
        
        if let type = segment.titleForSegmentAtIndex(segment.selectedSegmentIndex){
            
            self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
            
            if type == "全部影片"{
                
                CurrentDatas = Datas
            }
            else{
                
                CurrentDatas = self.Datas.filter({ data in
                    
                    if data.KeyWords.contains(type){
                        return true
                    }
                    
                    return false
                })
            }
            
            DisplayDatas = CurrentDatas
            
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        PT = ProgressTimer(progressBar: progressBar)
        
        segment.removeAllSegments()
        segment.translatesAutoresizingMaskIntoConstraints = true
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        
        self.navigationItem.title = "影音服務"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        let reloadBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "ReloadData")
        
        self.navigationItem.rightBarButtonItem = reloadBtn
        
        segment.frame.size.height = 40.0
        segment.frame.origin.x = 0
        segment.frame.origin.y = 0
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if Datas.count > 0{
            return
        }
        
        Datas = VideoCoreData.LoadCatchData()
        DisplayDatas = Datas
        
        if Datas.count == 0{
            ReloadData()
        }
        else{
            ResetSegmentItem()
        }
        
    }
    
    func ReloadData(){
        
        Datas = [VideoItem]()
        CurrentDatas = [VideoItem]()
        DisplayDatas = [VideoItem]()
        
        self.tableView.reloadData()
        
        VideoCoreData.DeleteAll()
        
        PT.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let tmp = self.GetData()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.Datas = tmp
                self.DisplayDatas = self.Datas
                
                for data in self.Datas{
                    VideoCoreData.SaveCatchData(data)
                }
                
                self.ResetSegmentItem()
                
                self.PT.StopProgress()
            })
        })
        
    }
    
    func ResetSegmentItem(){
        
        _SegmentItems.removeAll(keepCapacity: false)
        
        for data in Datas{
            
            for keyword in data.KeyWords{
                
                if !_SegmentItems.contains(keyword){
                    
                    _SegmentItems.append(keyword)
                }
            }
        }
        
        segment.removeAllSegments()
        
        var index = 0
        for s in _SegmentItems{
            segment.insertSegmentWithTitle("\(s)", atIndex: index, animated: false)
            index++
        }
        
        segment.insertSegmentWithTitle("全部影片", atIndex: 0, animated: false)
        
        var besSize = segment.sizeThatFits(CGSize.zero)
        
        if besSize.width < Global.ScreenSize.width {
            besSize.width = Global.ScreenSize.width
        }
        
        scrollView.contentSize = CGSizeMake(besSize.width , 0)
        segment.frame.size.width = besSize.width
        
//        if besSize.width > Global.ScreenSize.width{
//            scrollView.contentSize = CGSizeMake(besSize.width + 16 , 28)
//            segment.frame.size.width = besSize.width
//        }
//        else{
//            scrollView.contentSize = CGSizeMake(besSize.width - 8 , 28)
//            segment.frame.size.width = besSize.width - 16
//        }
        
        segment.hidden = false
        
        scrollView.contentOffset = CGPointMake(0 - self.scrollView.contentInset.left, 0)
        
        if segment.numberOfSegments > 0{
            segment.selectedSegmentIndex = 0
            SegmentSelected(self)
        }
    }
    
    func GetData() -> [VideoItem]{
        
        var retVal = [VideoItem]()
        
        let target = "https://odata.ntpc.edu.tw/api/videos.xml/"
        
        if let encoding = target.UrlEncoding{
            
            let rsp = HttpClient.GetWithHeader(encoding)
            
            var xml: AEXMLDocument?
            do {
                xml = try AEXMLDocument(xmlData: rsp!)
            } catch _ {
                xml = nil
            }
            
            if let videos = xml?.root["Video"].all{
                
                for video in videos{
                    
                    let id = video["id"].stringValue
                    let title = video["head"]["title"].stringValue
                    let contentLocation = video["head"]["contentLocation"].stringValue
                    
                    if contentLocation.hasSuffix(".wmv") || contentLocation.hasSuffix(".asf"){
                        continue
                    }
                    
                    var Keywords = [String]()
                    
                    if let keywords = video["head"]["keywords"]["d4p1:string"].all{
                        
                        for k in keywords{
                            Keywords.append(k.stringValue)
                        }
                        
                    }
                    
                    let vi = VideoItem(Id: id, Title: title, StreamUrl: contentLocation, KeyWords: Keywords)
                    
                    retVal.append(vi)
                }
            }
        }
        
        return retVal
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return DisplayDatas.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = DisplayDatas[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell") as! VideoCell
        
//        if cell == nil{
//            
//            cell = UITableViewCell(style: UITableViewCellStyle.Value1, reuseIdentifier: "aaa")
//        }
        
        cell.TitleLabel.text = data.Title
        
        cell.BelongLabel.text = data.KeyWords.joinWithSeparator(",")
        
        cell.ImageView.image = data.Image
        
        if data.Image == nil {
            
            dispatch_async(dispatch_get_main_queue(), {
                
                if let img = VideoCoreData.LoadCatchImage(data){
                    data.Image = img
                    cell.ImageView.image = img
                }
                else{
                    
                    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                        
                        //預覽圖
                        let getImgUrl : String = NSString(format: self.GetImgUrl, data.Title) as String
                        
                        var img : UIImage!
                        
                        if let rsp = try? HttpClient.Get(getImgUrl.UrlEncoding!){
                            img = rsp.GetResizeImage(0.1)
                        }
                        
                        dispatch_async(dispatch_get_main_queue(), {
                            
                            if img != nil{
                                
                                data.Image = img
                                
                                let ncell = self.tableView.cellForRowAtIndexPath(indexPath) as? VideoCell
                                
                                ncell?.ImageView.image = img
                                
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
                                    VideoCoreData.UpdateCatchImage(data,img: img)
                                })
                            }
                            
                        })
                    })
                }
                
            })
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = DisplayDatas[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("VideoPlayerViewCtrl") as! VideoPlayerViewCtrl
        
        nextView.BaseData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    //Mark : SearchBar
    func searchBarSearchButtonClicked(searchBar: UISearchBar){
        searchBar.resignFirstResponder()
        self.view.endEditing(true)
        
        Search(searchBar.text!)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        Search(searchText)
    }
    
    func Search(searchText:String){
        
        if searchText == "" {
            self.DisplayDatas = self.CurrentDatas
        }
        else{
            
            let founds = self.CurrentDatas.filter({ v in
                
                if let _ = v.Title.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if v.KeyWords.contains(searchText){
                    return true
                }
                
                return false
            })
            
            self.DisplayDatas = founds
        }
        
        self.tableView.reloadData()
        
    }

}

class VideoItem{
    
    var Id : String
    var Title : String
    var StreamUrl : String
    var KeyWords : [String]
    var Image : UIImage!
    
    init(Id: String, Title: String, StreamUrl: String, KeyWords: [String]){
        self.Id = Id
        self.Title = Title
        self.StreamUrl = StreamUrl
        self.KeyWords = KeyWords
        self.Image = nil
    }
}
