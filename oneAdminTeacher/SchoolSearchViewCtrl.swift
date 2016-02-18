//
//  SchoolSearchViewCtrl
//  EmbaAdmin
//
//  Created by Cloud on 9/3/15.
//  Copyright (c) 2015 ischool. All rights reserved.
//

import UIKit

class SchoolSearchViewCtrl: UIViewController,UITableViewDelegate,UITableViewDataSource,UISearchBarDelegate {
    
    @IBOutlet weak var segment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var progress: UIProgressView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let PhoneOn = UIImage(named: "Phone-50b.png")
    let PhoneOff = UIImage(named: "Phone-50.png")
    
    let AddressOn = UIImage(named: "Location Filled-50b.png")
    let AddressOff = UIImage(named: "Location Filled-50.png")
    
    let PublicOn = UIImage(named: "Globe-50b.png")
    let PublicOff = UIImage(named: "Globe-50.png")
    
    var progressTimer : ProgressTimer!
    
    //var _DisplayStudent = [EmbaStudent]()
    
    var _BaseDatas = [SchoolItem]()
    
    var _FirstFilterDatas = [SchoolItem]()
    
    var _DisplaySchool = [SchoolItem]()
    
    @IBAction func segmentSelectedChange(sender: AnyObject) {
        
        if segment.selectedSegmentIndex == 0{
            
            let tmp = _BaseDatas.filter({ t in
                
                if t.KeyWords.contains("幼兒園"){
                    return true
                }
                
                return false
            })
            
            _FirstFilterDatas = tmp
            _DisplaySchool = tmp
        }
        else if segment.selectedSegmentIndex == 1{
            
            let tmp = _BaseDatas.filter({ t in
                
                if t.KeyWords.contains("國小"){
                    return true
                }
                
                return false
            })
            
            _FirstFilterDatas = tmp
            _DisplaySchool = tmp
        }
        else if segment.selectedSegmentIndex == 2{
            
            let tmp = _BaseDatas.filter({ t in
                
                if t.KeyWords.contains("國中"){
                    return true
                }
                
                return false
            })
            
            _FirstFilterDatas = tmp
            _DisplaySchool = tmp
        }
        else if segment.selectedSegmentIndex == 3{
            
            let tmp = _BaseDatas.filter({ t in
                
                if t.KeyWords.contains("高中"){
                    return true
                }
                
                return false
            })
            
            _FirstFilterDatas = tmp
            _DisplaySchool = tmp
        }
        else{
            _FirstFilterDatas = _BaseDatas
            _DisplaySchool = _BaseDatas
        }
        
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension
        
        let reloadBtn = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "ReloadData")
        
        self.navigationItem.rightBarButtonItem = reloadBtn
        
        progressTimer = ProgressTimer(progressBar: progress)
        
        self.navigationItem.title = "學校通訊"
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "Menu-24.png"), style: UIBarButtonItemStyle.Plain, target: self, action: "ToggleSideMenu")
        
        searchBar.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        self.navigationController?.interactivePopGestureRecognizer?.enabled = false
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        
        if _BaseDatas.count == 0{
            ReloadData()
        }
        
    }
    
    func ReloadData(){
        
        self.tableView.contentOffset = CGPointMake(0, 0 - self.tableView.contentInset.top)
        
        progressTimer.StartProgress()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {
            
            //var tmp = self.GetEmbaData(value)
            let tmp = self.GetData()
            
            dispatch_async(dispatch_get_main_queue(), {
                
                self._DisplaySchool = tmp
                self._BaseDatas = tmp
                
                self.noDataLabel.hidden = self._DisplaySchool.count > 0
                
                //self.tableView.reloadData()
                self.segmentSelectedChange(self)
                self.progressTimer.StopProgress()
            })
        })
    }
    
    func GetData() -> [SchoolItem]{
        
        let before = CFAbsoluteTimeGetCurrent()
        
        var retVal = [SchoolItem]()
            
            let target = "https://odata.ntpc.edu.tw/api/schools.xml/"
        
            //let url = NSString(format: target, value) as String
            
            //println(url)
        
        if let encoding = target.UrlEncoding{
            
            var rsp : NSData?
            
            do {
                rsp = try HttpClient.Get(encoding)
            } catch _ {
                return retVal
            }
            
            var xml: AEXMLDocument?
            do {
                xml = try AEXMLDocument(xmlData: rsp!)
            } catch _ {
                xml = nil
            }
            
            if let Schools = xml?.root["School"].all{
                
                for school in Schools{
                    
                    let alias = school["alias"].stringValue
                    let address = school["address"].stringValue
                    let city = school["city"].stringValue
                    let district = school["district"].stringValue
                    
                    let phone = school["phone"].stringValue
                    
                    var keyWords = [String]()
                    
                    if let types = school["types"]["d3p1:string"].all{
                        
                        for t in types{
                            
                            keyWords.append(t.stringValue)
                            
                            //println(sss)
                        }
                    }
                    
                    let si = SchoolItem(Alias: alias, Address: address, City: city, District: district, KeyWords: keyWords, Phone : phone)
                    
                    retVal.append(si)
                }
            }

        }
        
        let span = CFAbsoluteTimeGetCurrent() - before
        print("Get School Data Time：\(span)")
        
        return retVal
        
        
    }
    
//    func GetEmbaData(value:String) -> [EmbaStudent]{
//        
//        var mergeData = [String:EmbaStudent]()
//        
//        var con = GetCommonConnect("test.emba.ntu.edu.tw")
//        var err : DSFault!
//        
//        var rsp = con.sendRequestWithXmlType("main.QueryStudent", bodyContent: "<Request><Condition><Or><StudentName>\(value)</StudentName><Company>\(value)</Company><EduSchoolName>\(value)</EduSchoolName><ClassName>\(value)</ClassName></Or></Condition></Request>", &err)
//        
//        if err != nil{
//            ShowErrorAlert(self,"查詢發生錯誤",err.message)
//            return mergeData.values.array
//        }
//            
////        var nserr: NSError?
////        var xml = AEXMLDocument(xmlData: rsp, error: &nserr)
//        
//        var xml = AEXMLDocument(root: rsp)
//        
////        if nserr != nil{
////            ShowErrorAlert(self, "Xml解析失敗", "\(nserr?.localizedDescription)")
////            return retVal
////        }
//        
//        if let students = xml.root["Response"]["Student"].all {
//            for student in students{
//                let name = student["Name"].stringValue
//                let className = student["ClassName"].stringValue
//                let freshmanPhoto = GetImageFromBase64String(student["FreshmanPhoto"].stringValue, UIImage(named: "User-100.png"))
//                
//                let id = student["Id"].stringValue
//                let englishName = student["EnglishName"].stringValue
//                let birthdate = student["Birthdate"].stringValue
//                let idNumber = student["IdNumber"].stringValue
//                let birthPlace = student["BirthPlace"].stringValue
//                let studentNumber = student["StudentNumber"].stringValue
//                let gender = student["Gender"].stringValue
//                let enrollYear = student["EnrollYear"].stringValue
//                let schoolName = student["SchoolName"].stringValue
//                let department = student["Department"].stringValue
//                
//                let emails = student["EmailList"].xmlString
//                
//                let phoneData = PhoneData(SmsPhone: student["SmsPhone"].stringValue, PermanentPhone: student["PermanentPhone"].stringValue, ContactPhone: student["ContactPhone"].stringValue)
//                
//                let addressData = AddressData(MailingAddress: student["MailingAddress"].xmlString, PermanentAddress: student["PermanentAddress"].xmlString, OtherAddress: student["OtherAddress"].xmlString)
//                
//                let company = Company(Name: student["CompanyName"].stringValue, Position: student["Position"].stringValue)
//                
//                if let stu = mergeData[id]{
//                    
//                    stu.Companys.append(company)
//                }
//                else{
//                    
//                    var companys = [Company]()
//                    companys.append(company)
//                    
//                    mergeData[id] = EmbaStudent(Id: id, Name: name, EnglishName: englishName, ClassName: className, Birthdate: birthdate, BirthPlace: birthPlace, StudentNumber: studentNumber, IdNumber: idNumber, Gender: gender, EnrollYear: enrollYear, SchoolName: schoolName, Department: department,  Emails: emails, Photo: freshmanPhoto, Companys: companys, Phone: phoneData, Address: addressData)
//                }
//            }
//        }
//        
//        return mergeData.values.array
//    }
    
    func ToggleSideMenu(){
        let app = UIApplication.sharedApplication().delegate as! AppDelegate
        
        app.centerContainer?.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return _DisplaySchool.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        
        let data = _DisplaySchool[indexPath.row]
        
        let cell = self.tableView.dequeueReusableCellWithIdentifier("SchoolCell") as! SchoolCell
        
        //cell.accessoryType = UITableViewCellAccessoryType.DisclosureIndicator
        
        //cell.Photo.image = data.Photo
        cell.Name.text = data.Alias
        cell.District.text = data.District
        
        if data.Phone.isEmpty{
            cell.PhoneIcon.image = PhoneOff
        }
        else{
            cell.PhoneIcon.image = PhoneOn
        }
        
        if data.Address.isEmpty{
            cell.AddressIcon.image = AddressOff
        }
        else{
            cell.AddressIcon.image = AddressOn
        }
        
        if data.KeyWords.contains("公立"){
            cell.PublicIcon.image = PublicOn
        }
        else{
            cell.PublicIcon.image = PublicOff
        }
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        
        let data = _DisplaySchool[indexPath.row]
        
        let nextView = self.storyboard?.instantiateViewControllerWithIdentifier("SchoolMapViewCtrl") as! SchoolMapViewCtrl
        
        nextView.BaseData = data
        
        self.navigationController?.pushViewController(nextView, animated: true)
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
            self._DisplaySchool = self._FirstFilterDatas
        }
        else{
            
            let founds = self._FirstFilterDatas.filter({ s in
                
                if let _ = s.Alias.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if let _ = s.City.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if let _ = s.District.lowercaseString.rangeOfString(searchText.lowercaseString){
                    return true
                }
                
                if s.KeyWords.contains(searchText){
                    return true
                }
                
                return false
            })
            
            self._DisplaySchool = founds
        }
        
        self.tableView.reloadData()
        
    }
    
}

struct SchoolItem {
    var Alias : String
    var Address : String
    var City : String
    var District : String
    var KeyWords : [String]
    var Phone : String
}

//class EmbaStudent{
//    
//    var Id : String
//    var Name : String
//    var EnglishName : String
//    var ClassName : String
//    var Birthdate : String
//    var BirthPlace : String
//    var StudentNumber : String
//    var IdNumber : String
//    var Gender : String
//    var EnrollYear : String
//    var SchoolName : String
//    var Department : String
//    var Photo : UIImage!
//    var Emails : String
//    var Companys : [Company]
//    
//    var Phone : PhoneData!
//    var Address : AddressData!
//    
//    init(Id: String, Name: String, EnglishName: String, ClassName: String, Birthdate: String, BirthPlace: String, StudentNumber: String, IdNumber: String, Gender: String, EnrollYear: String, SchoolName: String, Department: String, Emails: String, Photo: UIImage!, Companys: [Company], Phone: PhoneData!, Address: AddressData!){
//        
//        self.Id = Id
//        self.Name = Name
//        self.EnglishName = EnglishName
//        self.ClassName = ClassName
//        self.Companys = Companys
//        self.Birthdate = Birthdate
//        self.BirthPlace = BirthPlace
//        self.StudentNumber = StudentNumber
//        self.IdNumber = IdNumber
//        self.Gender = Gender
//        self.EnrollYear = EnrollYear
//        self.SchoolName = SchoolName
//        self.Department = Department
//        self.Photo = Photo
//        self.Emails = Emails
//        
//        self.Phone = Phone
//        self.Address = Address
//    }
//}
//
//struct Company{
//    var Name : String
//    var Position : String
//}
//
//struct PhoneData {
//    var SmsPhone : String
//    var PermanentPhone : String
//    var ContactPhone : String
//}
//
//struct AddressData {
//    var MailingAddress : String
//    var PermanentAddress : String
//    var OtherAddress : String
//}
