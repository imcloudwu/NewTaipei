//
//  MessageViewCtrl.swift
//  oneAdminTeacher
//
//  Created by Cloud on 7/22/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//
import UIKit
import Parse
import Bolts

class MessageViewCtrl: UIViewController,UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate {
    
    var Colors = [UIColor]()
    
    var messageData = [MessageItem]()
    var CurrentDatas = [MessageItem]()
    var DisplayMessage = [MessageItem]()
    
    var _tempSeleted = [MessageItem]()
    
    var _dateFormate = NSDateFormatter()
    var _timeFormate = NSDateFormatter()
    var _boldFont = UIFont.boldSystemFontOfSize(18.0)
    var _normalFont = UIFont.systemFontOfSize(16.0)
    
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var noDataLabel: UILabel!
    @IBOutlet weak var trashBtn: UIButton!
    
    var progressTimer : ProgressTimer!
    
    var _today : String!
    
    var isFirstLoad = true
    var onInBox = true
    var UnReadCount = 0
    var ViewTitle = "我的訊息"
    
//    let MsgIcon = UIImage(named: "Message Filled-32 White.png")
//    let VotedIcon = UIImage(named: "Starred Ticket Filled-32.png")
//    let VoteIcon = UIImage(named: "Starred Ticket-32.png")
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var refreshControl : UIRefreshControl!
    
    @IBAction func trashBtnClick(sender: AnyObject) {
        
        let count = self._tempSeleted.count
        
        let alert = UIAlertController(title: "確認要永久刪除 \(count) 筆項目嗎?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        
        alert.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        alert.addAction(UIAlertAction(title: "確認", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
            
            for m in self._tempSeleted{
                NotificationService.DeleteTempMessage(m.Id, accessToken: Global.AccessToken, callback: nil)
            }
            
            self._tempSeleted.removeAll()
            
            Global.MyToast.ToastMessage(self.view, msg: "已刪除 \(count) 筆項目", callback: ({
                self.GotoTrash()
            }))
            
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        trashBtn.hidden = true
        
        trashBtn.layer.masksToBounds = true
        trashBtn.layer.cornerRadius = trashBtn.frame.width / 2
        
        self.InitColors()
        
        self.ResetBadge()
        
        let sideMenuBtn = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        self.navigationItem.leftBarButtonItem = sideMenuBtn
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu 2-26.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "MessageMenu")
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "")
        self.refreshControl.addTarget(self, action: "ReloadData", forControlEvents: UIControlEvents.ValueChanged)
        self.tableView.addSubview(refreshControl)
        
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        _dateFormate.dateFormat = "yyyy/MM/dd"
        _timeFormate.dateFormat = "HH:mm"
        
        _today = _dateFormate.stringFromDate(NSDate())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchBar.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//    override func viewDidUnload() {
//        NotificationService.SetNewMessageDelegate(nil)
//    }
    
    override func viewWillAppear(animated: Bool) {
        SetViewTitle()
    }
    
    override func viewDidAppear(animated: Bool) {
        
        NotificationService.SetNewMessageDelegate { () -> () in
            self.ReloadData()
        }
        
        if isFirstLoad || NotificationService.NeedReload{
            NotificationService.ExecuteNewMessageDelegate()
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        NotificationService.SetNewMessageDelegate(nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func InitColors(){
        
        var tmps = [UIColor]()
        
//        tmps.append(UIColor(red: 255/255.0, green: 152/255.0, blue: 0/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 202/255.0, green: 168/255.0, blue: 245/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 62/255.0, green: 124/255.0, blue: 177/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 108/255.0, green: 150/255.0, blue: 157/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 100/255.0, green: 94/255.0, blue: 157/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 93/255.0, green: 115/255.0, blue: 126/255.0, alpha: 1.0))
//        tmps.append(UIColor(red: 100/255.0, green: 182/255.0, blue: 172/255.0, alpha: 1.0))
        
        tmps.append(UIColor(red: 145/255.0, green: 70/255.0, blue: 136/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 82/255.0, green: 82/255.0, blue: 163/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 60/255.0, green: 119/255.0, blue: 119/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 112/255.0, green: 112/255.0, blue: 56/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 129/255.0, green: 65/255.0, blue: 65/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 255/255.0, green: 88/255.0, blue: 10/255.0, alpha: 1.0))
        tmps.append(UIColor(red: 1/255.0, green: 152/255.0, blue: 89/255.0, alpha: 1.0))
        
        Colors = tmps
    }
    
    func ResetBadge(){
        PFInstallation.currentInstallation().badge = 0
        PFInstallation.currentInstallation().saveInBackground()
    }
    
    func SetViewTitle(){
        
        var unread = 0
        
        for msg in self.CurrentDatas{
            unread += msg.IsNew ? 1 : 0
        }
        
        UnReadCount = unread
        
        self.navigationItem.title = UnReadCount > 0 && ViewTitle == "收件訊息" ? "\(ViewTitle) ( \(UnReadCount) 封未讀 )" : "\(ViewTitle)"
    }
    
    func ReloadData(){
        
        self.isFirstLoad = false
        
        self.refreshControl.endRefreshing()
        
        self.progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            let syncData = self.GetNewMessageData()
            
            for msg in syncData{
                MessageCoreData.SaveCatchData(msg)
            }
            
            self.messageData = MessageCoreData.LoadCatchData()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self.DisplayMessage = self.messageData
                
                if self.DisplayMessage.count > 0{
                    self.noDataLabel.hidden = true
                }
                else{
                    self.noDataLabel.hidden = false
                }
                
                if self.onInBox{
                    self.GotoInbox()
                }
                else{
                    self.GotoTrash()
                }
                
                self.progressTimer.StopProgress()
            })
        })
        
    }
    
    func GetNewMessageData() -> [MessageItem]{
        
        var retVal = [MessageItem]()
        
        let localCount = MessageCoreData.GetCount()
        
        //計算要更新的數量
        var count = NotificationService.GetMessageCount(Global.AccessToken,defalut: localCount) - localCount
        
        if count < 0{
            MessageCoreData.DeleteAll()
            count = NotificationService.GetMessageCount(Global.AccessToken,defalut: localCount) - localCount
        }
        
        if count == 0{
            return retVal
        }
        
        var mod = count % 10
        
        if mod > 0 {
            mod = 1
        }
        
        for i in 1...(count / 10) + mod{
            
            let data = NotificationService.GetMessage("\(i)", accessToken: Global.AccessToken)
            
            retVal += ParseMessage(data)
        }
        
        return retVal
    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func MessageMenu(){
        
        let menu = UIAlertController(title: "你想要使用？", message: "", preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
        
        menu.addAction(UIAlertAction(title: "收件匣", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.GotoInbox()
        }))
        
        menu.addAction(UIAlertAction(title: "垃圾桶", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            self.GotoTrash()
        }))
        
        if !self.onInBox{
            
            menu.addAction(UIAlertAction(title: "全部選擇", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                
                self._tempSeleted = self.CurrentDatas
                self.tableView.reloadData()
            }))
            
        }
        
        self.presentViewController(menu, animated: true, completion: nil)
    }
    
    func GotoInbox(){
        
        _tempSeleted.removeAll()
        
        trashBtn.hidden = true
        
        self.onInBox = true
        
        self.CurrentDatas = self.messageData
        self.DisplayMessage = self.messageData
        self.ViewTitle = "收件訊息"
        self.SetViewTitle()
        self.tableView.reloadData()
    }
    
    func GotoTrash(){
        
        trashBtn.hidden = false
        
        self.onInBox = false
        
        let rsp = NotificationService.GetTempMessages(Global.AccessToken)
        
        let tmpData = ParseMessage(rsp)

        self.CurrentDatas = tmpData
        self.DisplayMessage = tmpData
        self.ViewTitle = "待刪訊息 : \(tmpData.count)"
        self.SetViewTitle()
        self.tableView.reloadData()
    }
    
//    func GotoOutbox(){
//        
//        self.onInBox = false
//        
//        var tmpData = [MessageItem]()
//        
//        for mi in self.messageData{
////            if mi.IsSender{
////                tmpData.append(mi)
////            }
//        }
//        
//        self.DisplayMessage = tmpData
//        self.ViewTitle = "寄件訊息"
//        self.SetViewTitle()
//        self.tableView.reloadData()
//    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return DisplayMessage.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = DisplayMessage[indexPath.row]
        
        let date = _dateFormate.stringFromDate(data.Date)
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell") as! MessageCell
        cell.Title.font = data.IsNew ? _boldFont : _normalFont
        cell.Title.text = data.Subject
        cell.Date.text = _today == date ? _timeFormate.stringFromDate(data.Date) : date
        cell.Date.textColor = data.IsNew ? UIColor(red: 19 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1) : UIColor.lightGrayColor()
        cell.Content.text = data.Body
        
        cell.Sender.font = data.IsNew ? _boldFont : _normalFont
        cell.Sender.text = data.Sender
        
        if !data.Sender.isEmpty{
            let firstChar = (data.Sender as NSString).substringToIndex(1)
            cell.IcomFrame.backgroundColor = Colors[firstChar.hash % Colors.count]
            cell.IconLabel.text = firstChar
        }
        else{
            cell.IconLabel.text = ""
        }
        
        if _tempSeleted.contains(data){
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
        else{
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        
        cell.gestureRecognizers?.removeAll()
        
        //長按刪除
        cell.tag = indexPath.row
        
        //UILongPressGestureRecognizer
        let longPress = UILongPressGestureRecognizer(target: self, action: "LongPress:")
        longPress.minimumPressDuration = 0.5
        
        cell.addGestureRecognizer(longPress)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = DisplayMessage[indexPath.row]
        
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! MessageCell
        
        if data.IsNew{
            
            NotificationService.SetRead(data.Id, accessToken: Global.AccessToken)
            
            data.IsNew = false
            self.SetViewTitle()
            
            cell.Sender.font = _normalFont
            cell.Title.font = _normalFont
            cell.Date.textColor = data.IsNew ? UIColor(red: 19 / 255, green: 144 / 255, blue: 255 / 255, alpha: 1) : UIColor.lightGrayColor()
            
            MessageCoreData.SaveCatchData(data)
        }
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("NewMessageDetail") as! NewMessageDetail
        
        nextView.MessageData = data
        nextView.IconColor = cell.IcomFrame.backgroundColor
        nextView.IconText = cell.IconLabel.text
        
//        if data.IsSender && ViewTitle == "寄件訊息"{
//            nextView.SenderMode = true
//        }
        
        self.navigationController?.pushViewController(nextView, animated: true)
    }
    
    //Mark : Delete Function
    func LongPress(sender:UILongPressGestureRecognizer){
        
        if sender.state == UIGestureRecognizerState.Began{
            
            let cell = sender.view as! MessageCell
            
            let data = DisplayMessage[cell.tag]
            
            if self.onInBox{
                
                let menu = UIAlertController(title: "要刪除 \(data.Sender) : \(data.Subject) 嗎?", message: "", preferredStyle: UIAlertControllerStyle.Alert)
                
                menu.addAction(UIAlertAction(title: "取消", style: UIAlertActionStyle.Cancel, handler: nil))
                
                menu.addAction(UIAlertAction(title: "是", style: UIAlertActionStyle.Destructive, handler: { (action) -> Void in
                    
                    NotificationService.TempDelete(data.Id, accessToken: Global.AccessToken, callback: { () -> () in
                        
                        MessageCoreData.DeleteMessage(data)
                        
                        self.messageData = MessageCoreData.LoadCatchData()
                        
                        Global.MyToast.ToastMessage(self.view, msg: "訊息已被移到垃圾桶", callback: nil)
                        
                        self.GotoInbox()
                    })
                }))
                
                self.presentViewController(menu, animated: true, completion: nil)
            }
            else{
                
                if _tempSeleted.contains(data){
                    
                    var index = 0
                    
                    for t in _tempSeleted{
                        if t == data{
                            break
                        }
                        
                        index++
                    }
                    
                    _tempSeleted.removeAtIndex(index)
                    
                    cell.accessoryType = UITableViewCellAccessoryType.None
                }
                else{
                    
                    _tempSeleted.append(data)
                    
                    cell.accessoryType = UITableViewCellAccessoryType.Checkmark
                }
            }
        }
    }
    
    func ParseMessage(data:NSData?) -> [MessageItem]{
        
        var retVal = [MessageItem]()
        
        if let ndata = data{
            
            //取得訊息
            let jsons = JSON(data: ndata)
            
            let format:NSDateFormatter = NSDateFormatter()
            format.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            //format.timeZone = NSTimeZone(name: "Asia/Taipei")
            
            for (_,obj) in jsons {
                
                let receive_time = obj["receive_time"].stringValue
                let id = obj["id"].stringValue
                let sender = obj["from"].stringValue
                let type = obj["from_type"].stringValue
                let subject = obj["subject"].stringValue
                let body = obj["body"].stringValue
                let ip = obj["ip"].stringValue
                
                let has_read = obj["has_read"].stringValue
                let isNew = has_read == "undefined" || has_read.isEmpty
                
                let parseDate = format.dateFromString(receive_time)
                
                if let date = parseDate{
                    
                    let mi = MessageItem(id: id, date: date, isNew: isNew, type: type, subject: subject, body: body, sender: sender, ip: ip)
                    
                    retVal.append(mi)
                }
            }
        }
        
        return retVal.sort({ $0.Date > $1.Date })
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
            self.DisplayMessage = self.CurrentDatas
        }
        else{
            
            let founds = self.CurrentDatas.filter({ m in
                
                if let _ = m.Subject.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if let _ = m.Sender.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                return false
            })
            
            self.DisplayMessage = founds
        }
        
        self.tableView.reloadData()
        
    }

    
}

class MessageItem : Equatable{
    var Id : String
    var Date : NSDate
    var IsNew : Bool
    var Type : String
    var Subject : String
    var Body : String
    var Sender : String
    var Ip : String
    //var Title : String
    //var Content : String
    //var Redirect : String
    //var DsnsName : String
    //var Name : String
    //var IsSender : Bool
    //var IsReceiver : Bool
    
    //var Voted : Bool
    
    init(id: String, date: NSDate, isNew: Bool, type: String, subject: String, body: String, sender: String, ip: String){
        
        self.Id = id
        self.Date = date
        self.IsNew = isNew
        self.Type = type
        self.Subject = subject
        self.Body = body
        self.Sender = sender
        self.Ip = ip
        
    }
    
//    init(id: String, date: NSDate, isNew: Bool, title: String, content: String, redirect: String, dsnsName: String, name: String, isSender: Bool, isReceiver: Bool, type: String,voted:Bool){
//        Id = id
//        Date = date
//        IsNew = isNew
//        Title = title
//        Content = content
//        Redirect = redirect
//        DsnsName = dsnsName
//        Name = name
//        IsSender = isSender
//        IsReceiver = isReceiver
//        
//        Type = type
//        Voted = voted
//    }
    
//    convenience init(id: String, date: NSDate, isNew: Bool, title: String, content: String, redirect: String, dsnsName: String, name: String, isSender: Bool, isReceiver: Bool, type: String) {
//        
//        self.init(id: id, date: date, isNew: isNew, title: title, content: content, redirect: redirect, dsnsName: dsnsName, name: name, isSender: isSender, isReceiver: isReceiver, type: type, voted: false)
//    }
}

func ==(lhs: MessageItem, rhs: MessageItem) -> Bool {
    return lhs.Id == rhs.Id
}
