////
////  CourseTimeViewCtrl.swift
////  EmbaAdmin
////
////  Created by Cloud on 11/6/15.
////  Copyright (c) 2015 ischool. All rights reserved.
////
//
//import UIKit
//
//class CourseTimeViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource {
//    
//    @IBOutlet weak var tableView: UITableView!
//    
//    var CourseInfoItemData : CourseInfoItem!
//    
//    var _DateParser = NSDateFormatter()
//    var _DateFormate = NSDateFormatter()
//    var _TimeFormate = NSDateFormatter()
//    
//    var Datas = [SectionItem]()
//    var Displays = [String:[SectionItem]]()
//    var PlacesAndTeachers = [String]()
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        
//        _DateParser.dateFormat = "yyyy-MM-dd HH:mm:ss"
//        _DateFormate.dateFormat = "yyyy-MM-dd"
//        _TimeFormate.dateFormat = "HH:mm"
//        
//        tableView.delegate = self
//        tableView.dataSource = self
//        
//        // Do any additional setup after loading the view, typically from a nib.
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
//    
//    override func viewDidAppear(animated: Bool) {
//        
//        Datas = GetData()
//        
//        for data in Datas{
//            
//            let title = data.Title
//            
//            if Displays[title] == nil{
//                Displays[title] = [SectionItem]()
//                PlacesAndTeachers.append(title)
//            }
//            
//            Displays[title]?.append(data)
//        }
//        
//        tableView.reloadData()
//    }
//    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String?{
//        return PlacesAndTeachers[section]
//    }
//    
//    func numberOfSectionsInTableView(tableView: UITableView) -> Int{
//        return PlacesAndTeachers.count
//    }
//    
//    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
//        
//        let title = PlacesAndTeachers[section]
//        
//        if let count = Displays[title]?.count{
//            return count
//        }
//        
//        return 0
//    }
//    
//    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
//        
//        var cell = tableView.dequeueReusableCellWithIdentifier("SectionItemCell") as? UITableViewCell
//        
//        if cell == nil{
//            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "SectionItemCell")
//        }
//        
//        let title = PlacesAndTeachers[indexPath.section]
//        
//        if let datas : [SectionItem] = Displays[title]{
//            
//            let data = datas[indexPath.row]
//            
//            cell?.textLabel?.text = GetDescription(data)
//        }
//        
//        return  cell!
//    }
//    
//    func GetData() -> [SectionItem]{
//        
//        var retVal = [SectionItem]()
//        
//        var con = GetCommonConnect("test.emba.ntu.edu.tw")
//        var err : DSFault!
//        
//        var rsp = con.SendRequest("main.QuerySection", bodyContent: "<Request><Condition><RefCourseID>\(CourseInfoItemData.CourseID)</RefCourseID></Condition></Request>", &err)
//        
//        //println(rsp)
//        
//        if err != nil{
//            ShowErrorAlert(self,"查詢發生錯誤",err.message)
//            return retVal
//        }
//        
//        var nserr:NSError?
//        var xml = AEXMLDocument(xmlData: rsp.dataValue, error: &nserr)
//        
//        if nserr != nil{
//            return retVal
//        }
//        
//        if let sections = xml?.root["Response"]["Section"].all{
//            for section in sections{
//                
//                let place = section["Place"].stringValue
//                let teacherName = section["TeacherName"].stringValue
//                
//                let starttime = section["Starttime"].stringValue
//                let endtime = section["Endtime"].stringValue
//                
//                let startDateTime = _DateParser.dateFromString(starttime)
//                let endDateTime = _DateParser.dateFromString(endtime)
//                
//                var si = SectionItem(Starttime: startDateTime!, Endtime: endDateTime!, Place: place, TeacherName: teacherName)
//                
//                retVal.append(si)
//            }
//        }
//        
//        retVal.sort({ $0.Starttime < $1.Starttime })
//        
//        return retVal
//
//    }
//    
//    func GetDescription(sectionItem:SectionItem) -> String{
//        
//        var retVal = ""
//        
//        retVal += _DateFormate.stringFromDate(sectionItem.Starttime)
//        
//        retVal += " (\(GetWeekDay(sectionItem.Starttime)))"
//        
//        retVal += "     \(_TimeFormate.stringFromDate(sectionItem.Starttime)) ~ \(_TimeFormate.stringFromDate(sectionItem.Endtime))"
//        
//        return retVal
//    }
//    
//    func GetWeekDay(date:NSDate) -> String{
//        
//        let myWeekday = NSCalendar.currentCalendar().components(NSCalendarUnit.CalendarUnitWeekday, fromDate: date).weekday
//        
//        switch myWeekday{
//        case 1:
//            return "日"
//        case 2:
//            return "ㄧ"
//        case 3:
//            return "二"
//        case 4:
//            return "三"
//        case 5:
//            return "四"
//        case 6:
//            return "五"
//        default:
//            return "六"
//        }
//    }
//    
//    
//}
//
//struct SectionItem{
//    
//    var Starttime : NSDate
//    var Endtime : NSDate
//    var Place : String
//    var TeacherName : String
//    
//    var Title : String{
//        return "地點 : \(Place) / 老師 : \(TeacherName)"
//    }
//    
//}
